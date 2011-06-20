/*jslint strict: true, unparam: true, browser: true */
/*global jQuery */

var IQVOC = (function($) {

"use strict";

var dynamicAuth = function(container) {
	container = container.nodeType ? container : $(container)[0];
	var authLink = $("a", container);
	var uri = authLink.attr("href");
	if(uri.indexOf("/new.html") !== -1) {
		var menu = $("ul", container);
		var label = authLink.text() + " &#9660;";
		authLink.click(function(ev) {
			authLink.html(label);
			menu.removeClass("hidden").slideDown()
				.find("li").load(uri + " #new_user_session");
			ev.preventDefault();
		});
	}
};

var collapseDropdown = function(node) {
	var el = $(node || this);
	el.find("ul").slideUp(function() {
		el.removeClass("hover");
	});
};

// augments Son of Suckerfish drop-down menus
var enhancedDropdown = function(container) {
	container = container.jquery ? container : $(container);
	var menuItems = $("> li", container),
		ddtimer;
	menuItems.find("ul").hide();
	menuItems.live({
		mouseenter: function(ev) {
			clearTimeout(ddtimer);
			menuItems.not(this).filter(".hover").each(function(i, node) {
				collapseDropdown(node);
			});
			$(this).addClass("hover")
				.find("ul").not(".hidden").slideDown();
		},
		mouseleave: function(ev) {
			clearTimeout(ddtimer);
			ddtimer = setTimeout(jQuery.proxy(collapseDropdown, this), 600);
		}
	});
};

var EntitySelector = function(node) { // TODO: move into separate module
	this.el = $(node).hide(); // XXX: rename
	this.container = $('<div class="entity_select" />').data("widget", this);
	this.delimiter = ",";
	this.singular = this.el.data("singular") || false;
	this.entities = this.getSelection();
	this.uriTemplate = this.el.data("entity-uri");

	var self = this;

	var selection = $.map(this.el.data("entities"), function(entity, i) {
		return self.createEntity(entity);
	});
	selection = $('<ul class="entity_list" />').append(selection);

	var exclude = this.el.data("exclude") || null;
	var img = $('<img src="/images/iqvoc/spinner.gif" class="hidden" />');
	this.input = $("<input />").autocomplete({
		minLength: 3,
		source: function(req, callback) {
			var uri = self.el.data("query-url");
			$.getJSON(uri, { query: req.term }, function(data, status, xhr) { // TODO: error handling
				var excludes = self.getSelection()
					.concat(exclude ? [exclude] : []);
				data = $.map(data, function(entity, i) {
					return $.inArray(entity.id, excludes) !== -1 ? null :
							{ value: entity.id, label: entity.name };
				});
				self.input.autocomplete("option", "autoFocus", data.length === 1);
				callback(data);
				img.addClass("hidden");
			});
		},
		search: function(ev, ui) { img.removeClass("hidden"); },
		focus: function(ev, ui) { return false; },
		select: this.onSelect
	});

	this.container.append(this.input).append(img).append(selection)
		.insertAfter(node).prepend(node);

	if(this.singular && this.entities.length) {
		this.input.hide();
	}
};
$.extend(EntitySelector.prototype, {
	onSelect: function(ev, ui) {
		var el = $(this).val("");
		var widget = el.closest(".entity_select").data("widget");
		if(widget.add(ui.item.value)) {
			var entity = widget.
					createEntity({ id: ui.item.value, name: ui.item.label });
			widget.container.find("ul").append(entity);
			if(widget.singular) {
				widget.input.hide();
			}
		}
		return false;
	},
	onDelete: function(ev) {
		var el = $(this);
		var entity = el.closest("li");
		var widget = el.closest(".entity_select").data("widget");
		widget.remove(entity.data("id"));
		entity.remove();
		if(widget.singular) {
			widget.input.show();
		}
		ev.preventDefault();
	},
	createEntity: function(entity) {
		var el;
		if(this.uriTemplate) {
			var uri = this.uriTemplate.replace("%7Bid%7D", entity.id); // XXX: not very generic
			el = $('<a target="_blank" />').attr("href", uri).text(entity.name);
		} else {
			el = $('<span />').text(entity.name);
		}
		var btn = $('<a href="javascript:;" class="btn">x</a>') // "btn" to avoid fancy "button" class -- XXX: hacky workaround!?
			.click(this.onDelete);
		return $("<li />").data("id", entity.id).append(el).append(btn)[0];
	},
	add: function(entity) {
		if($.inArray(entity, this.entities) === -1) {
			this.entities.push(entity);
			this.setSelection();
			return true;
		} else {
			return false;
		}
	},
	remove: function(entity) {
		var pos = $.inArray(entity, this.entities);
		if(pos !== -1) {
			this.entities.splice(pos, 1);
			this.setSelection();
		}
	},
	setSelection: function() {
		this.el.val(this.entities.join(this.delimiter));
	},
	getSelection: function() {
		return $.map(this.el.val().split(this.delimiter), function(entity, i) {
			return entity ? $.trim(entity) : null;
		});
	}
});

var createNote = function(ev) {
	var container = $(this).closest("fieldset");
	var source = $("ol li:last-child", container);

	// special case for usage notes
	// a usage note contains a select box instead of a textarea
	// FIXME: Hardcoded UMT stuff
	var isUsageNote = source.find("label:first").attr("for").
			match(/^concept_note_umt_usage_notes/);

	if(source.is(":hidden")) {
		source.show();
		return false;
	}

	var clone = source.clone();

	var count = source.find(isUsageNote ? "select" : "textarea").attr("id").
			match(/_(\d)_/)[1];
	count = parseInt(count, 10) + 1;
	var newIdCount = "_" + count + "_";
	var newNameCount = "[" + count + "]";

	clone.find("label")
		.attr("for", source.find("label").attr("for").replace(/_\d_/, newIdCount));

	// clone.find("input")
	// .attr("id", source.find("input[type=hidden]").attr("id").replace(/_\d_/, newIdCount))
	// .attr("name", source.find("input[type=hidden]").attr("name").replace(/\[\d\]/, newNameCount));

	if(!isUsageNote) {
		clone.find("textarea")
			.val("")
			.attr("id", source.find("textarea").attr("id").replace(/_\d_/, newIdCount))
			.attr("name", source.find("textarea").attr("name").replace(/\[\d\]/, newNameCount));
	}
	clone.find("select")
		.attr("id", source.find("select").attr("id").replace(/_\d_/, newIdCount))
		.attr("name", source.find("select").attr("name").replace(/\[\d\]/, newNameCount));

	clone.addClass("new");

	$("ol", container).append(clone);

	return false;
};

// work around apparent capybara-webkit issue:
// https://github.com/thoughtbot/capybara-webkit/issues/43
var Storage = localStorage;
if(Storage === null) {
	Storage = {};
	Storage.getItem = function() { return null; };
	Storage.setItem = $.noop;
}

return {
	Storage: Storage,
	dynamicAuth: dynamicAuth,
	enhancedDropdown: enhancedDropdown,
	EntitySelector: EntitySelector,
	createNote: createNote
};

}(jQuery));
