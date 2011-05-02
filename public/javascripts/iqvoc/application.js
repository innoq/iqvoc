/*jslint browser: true, unparam: true */
/*global jQuery */

var IQVOC = (function($) {

var dynamicAuth = function(container) {
	container = container.nodeType ? container : $(container)[0];
	var authLink = $("a", container);
	var uri = authLink.attr("href");
	if(uri.indexOf("/new.html") !== -1) {
		authLink.addClass("button");
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

// augment Son of Suckerfish drop-down menus
var enhancedDropdown = function(container) {
	container = container.jquery ? container : $(container);
	container.children("li").hover(function(ev) {
		clearTimeout(IQVOC.ddtimer);
		$(this).addClass("hover")
			.find("ul").not(".hidden").slideDown();
	}, function(ev) {
		var el = $(this);
		var collapse = function() {
			el.find("ul").slideUp(function() {
				el.removeClass("hover");
			});
		};
		clearTimeout(IQVOC.ddtimer);
		IQVOC.ddtimer = setTimeout(collapse, 600); // XXX: singleton
	}).find("ul").hide();

};

var addWidget = function(index, elem) {
	if (!elem) {
		return;
	}

	elem = $(elem);
	elem.val("");
	var queryUrl = elem.attr("data-query-url");
	var options = $.parseJSON(elem.attr("data-options"));
	var excludes = elem.attr("data-exclude") || "";
	excludes = excludes.split(";");
	// Widget UI text translations get yielded into a meta tag in the head section of the page.
	// Parse them and merge the JSON hash with the default options.
	var translations = $.parseJSON($("meta[name=widget-translations]").attr("content"));

	options = $.extend(translations, options);
	options.onResult = excludes.length === 0 ? null : function(results) {
		return $.grep(results, function(item) {
			return $.inArray(item.id, excludes) === -1;
		});
	};

	elem.tokenInputNew(queryUrl, options);
};

var createNote = function(ev) {
	var container = $(this).closest("fieldset");
	var source = $("ol li:last-child", container);

	// special case for usage notes
	// a usage note contains a select box instead of a textarea
	// FIXME: Hardcoded UMT stuff
	var isUsageNote = source.find("label:first").attr("for").
			match(/^concept_note_umt_usage_notes/);

	if (source.is(":hidden")) {
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

	if (!isUsageNote) {
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
	addWidget: addWidget, // TODO: rename; too generic / insufficiently descriptive
	createNote: createNote
};

}(jQuery)); // /module IQVOC

jQuery(document).ready(function($) {
	var locale = $("meta[name=i18n-locale]").attr("content");

	IQVOC.enhancedDropdown(".menu");
	IQVOC.dynamicAuth("#auth_controls");

	$("input.token_input_widget").each(IQVOC.addWidget);

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

	$("ul.hybrid-treeview").each(function() {
		var url = $(this).attr("data-url");
		var container = this;
		$(this).treeview({
			collapsed: true,
			toggle: function() {
				var $this = $(this);
				if ($this.hasClass("hasChildren")) {
					var childList = $this.removeClass("hasChildren").find("ul");
					$.fn.treeviewLoad({ "url": url }, this.id, childList, container);
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
			success: function (data) {
				if (data) {
					var msg = notification.attr("data-msg");
					notification.html(msg + " " + data.label.value).show();
				} else {
					notification.hide();
				}
			}
		});
	});
});
