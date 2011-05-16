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

var EntitySelector = function(node) {
	this.el = $(node).hide();
	this.container = $('<div class="entity_select" />').data("widget", this);
	this.delimiter = ",";
	this.entities = this.getSelection();
	this.uriTemplate = this.el.data("entity-uri");

	var self = this;

	var selection = $.map(this.el.data("entities"), function(entity, i) {
		return self.createEntity(entity);
	});
	selection = $("<ul />").append(selection);

	var exclude = this.el.data("exclude") || null;
	var img = $('<img src="/images/iqvoc/spinner.gif" class="hidden" />');
	var input = $("<input />").autocomplete({
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
				callback(data);
				img.addClass("hidden");
			});
		},
		search: function(ev, ui) { img.removeClass("hidden"); },
		select: this.onSelect
	});

	this.container.append(input).append(img).append(selection)
		.insertAfter(node).prepend(node);
};
$.extend(EntitySelector.prototype, {
	onSelect: function(ev, ui) {
		var el = $(this).val("");
		var widget = el.closest(".entity_select").data("widget");
		if(widget.add(ui.item.value)) {
			var entity = widget.
					createEntity({ id: ui.item.value, name: ui.item.label });
			widget.container.find("ul").append(entity);
		}
		return false;
	},
	onDelete: function(ev) {
		var el = $(this);
		var entity = el.closest("li");
		var widget = el.closest(".entity_select").data("widget");
		widget.remove(entity.data("id"));
		entity.remove();
		ev.preventDefault();
	},
	createEntity: function(entity) {
		var uri = this.uriTemplate.replace("%7Bid%7D", entity.id); // XXX: not very generic
		var link = $('<a target="_blank" />').attr("href", uri).text(entity.name);
		var btn = $('<a href="javascript:;" class="btn">x</a>') // "btn" to avoid fancy "button" class -- XXX: hacky workaround!?
			.click(this.onDelete);
		return $("<li />").data("id", entity.id).append(link).append(btn)[0];
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

return {
	dynamicAuth: dynamicAuth,
	enhancedDropdown: enhancedDropdown,
	EntitySelector: EntitySelector,
	createNote: createNote
};

}(jQuery)); // /module IQVOC

jQuery(document).ready(function($) {
	"use strict";

	var locale = $("head meta[name=i18n-locale]").attr("content");

	IQVOC.enhancedDropdown(".menu");
	IQVOC.dynamicAuth("#auth_controls");

	// language selection -- TODO: move to separate module
	var langWidget = $("ul.lang-widget")[0];
	// primary language (converting links to radio buttons)
	$("a", langWidget).map(function(i, node) {
		var link = $(node);
		var el = link.closest("li");
		var btn = $('<input type="radio" name="primary_language">');
		if(link.hasClass("current")) {
			btn[0].checked = true;
		}
		var label = $("<label />").append(btn).append(link);
		el.append(label);
		return label[0];
	});
	$("input:radio", langWidget).live("change", function(ev) {
		window.location = $(this).closest("label").find("a").attr("href");
	});
	// secondary language
	$("input:checkbox[value=" + locale + "]", langWidget).closest("li").remove();
	var toggleSections = function(langSelected) {
		$(".translation[lang]").each(function(i, node) {
			var el = $(node);
			var lang = el.attr("lang");
			if(lang !== locale && $.inArray(lang, langSelected) === -1) {
				el.addClass("hidden");
			} else {
				el.removeClass("hidden");
			}
		});
	};
	$(document).bind("lang_selected", function(ev, data) {
		toggleSections(data.langs);
	});
	new IQVOC.LanguageSelector(langWidget, "lang_selected");

	$("input.entity_select").each(function(i, node) {
		new IQVOC.EntitySelector(node);
	});

	// Label editing (inline notes)
	$("fieldset.note_relation ol li.inline_note.new").hide();
	$("fieldset.note_relation input[type=button]").click(IQVOC.createNote);
	$("li.inline_note input:checkbox").change(function(ev) {
		var action = this.checked ? "addClass" : "removeClass";
		$(this).closest("li")[action]("deleted");
	});

	// Datepicker
	$.datepicker.setDefaults($.datepicker.regional[locale]);
	$("input.datepicker").datepicker();

	// Dashboard table row highlighting and click handling
	$("tr.highlightable")
		.hover(function(ev) {
			$(this).toggleClass("hover");
		})
		.click(function(ev) {
			window.location = $(this).attr("data-url");
		});

	// Search
	$("button#language_select_all").click(function() {
		$("input[type=checkbox].lang_check").attr("checked", true);
	});
	$("button#language_select_none").click(function() {
		$("input[type=checkbox].lang_check").attr("checked", false);
	});

	// hierarchical tree view
	$("ul.hybrid-treeview").each(function() {
		var url = $(this).attr("data-url");
		var container = this;
		$(this).treeview({
			collapsed: true,
			toggle: function() {
				var $this = $(this);
				if($this.hasClass("hasChildren")) {
					var childList = $this.removeClass("hasChildren").find("ul");
					$.fn.treeviewLoad({ url: url }, this.id, childList, container);
				}
			}
		});
	});

	// New Label (Inflectional search)
	$("form#new_label input#label_value").keyup(function() {
		var notification = $("p.label_warning");
		$.ajax({
			type: "GET",
			url: $(this).attr("data-remote"),
			dataType: "json",
			data: {
				query: $(this).val()
			},
			success: function(data) {
				if(data) {
					var msg = notification.attr("data-msg");
					notification.html(msg + " " + data.label.value).show();
				} else {
					notification.hide();
				}
			}
		});
	});
});
