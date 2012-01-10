/*jslint vars: true, unparam: true, browser: true */
/*global jQuery */

var IQVOC = (function($) {

"use strict";

var dynamicAuth = function(container) {
	container = container.nodeType ? container : $(container)[0];
	var authLink = $("a", container),
		uri = authLink.attr("href");
	if(uri.indexOf("/new.html") !== -1) {
		var menu = $("ul", container),
			label = authLink.text() + " &#9660;";
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

var createNote = function(ev) {
	var container = $(this).closest("fieldset"),
		source = $("ol li:last-child", container);

	// special case for usage notes
	// a usage note contains a select box instead of a textarea
	// FIXME: Hardcoded UMT stuff
	var isUsageNote = source.find("label:first")[0].getAttribute("for");
	isUsageNote = isUsageNote ? isUsageNote.match(/^concept_note_umt_usage_notes/) : false;

	if(source.is(":hidden")) {
		source.show();
		return false;
	}

	var clone = source.clone();

	var count = source.find(isUsageNote ? "select" : "textarea")[0].id
			.match(/_(\d+)_/)[1];
	count = String(parseInt(count, 10) + 1);
	var newIdCount = "_" + count + "_",
		newNameCount = "[" + count + "]";

	clone.find("label")[0]
		.setAttribute("for", (source.find("label")[0].getAttribute("for") || "")
				.replace(/_\d+_/, newIdCount));

	// clone.find("input")
	// .attr("id", source.find("input[type=hidden]").attr("id").replace(/_\d+_/, newIdCount))
	// .attr("name", source.find("input[type=hidden]").attr("name").replace(/\[\d+\]/, newNameCount));

	var src, el;
	if(!isUsageNote) {
		src = source.find("textarea")[0];
		el = clone.find("textarea").val("")[0];
		el.id = src.id.replace(/_\d+_/, newIdCount);
		el.name = src.name.replace(/\[\d+\]/, newNameCount);
	}
	src = source.find("select")[0];
	el = clone.find("select")[0];
	el.id = src.id.replace(/_\d+_/, newIdCount);
	el.name = src.name.replace(/\[\d+\]/, newNameCount);

	clone.addClass("new");
	$("ol", container).append(clone);

	return false;
};

// work around apparent capybara-webkit issue:
// https://github.com/thoughtbot/capybara-webkit/issues/43
var Storage = localStorage || null;
if(Storage === null) {
	Storage = {};
	Storage.getItem = function() { return null; };
	Storage.setItem = $.noop;
}

return {
	Storage: Storage,
	dynamicAuth: dynamicAuth,
	enhancedDropdown: enhancedDropdown,
	createNote: createNote
};

}(jQuery));

jQuery(document).ready(function($) {
	"use strict";

	var locale = $("head meta[name=i18n-locale]").attr("content");

	IQVOC.enhancedDropdown(".menu");
	IQVOC.dynamicAuth("#auth_controls");

	if(IQVOC.visualization) {
		IQVOC.visualization.init("infovis", function(container) {
			if(IQVOC.Storage.getItem("visualization") === "enlarged") {
				container.data("widget").toggleSize(true);
			}
		});
	}

	// language selection
	var langWidget = $("ul.lang-widget")[0];
	// primary language (converting links to radio buttons)
	$("a", langWidget).each(function(i, node) {
		var link = $(node),
			el = link.closest("li"),
			btn = $('<input type="radio" name="primary_language">');
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
	var toggleSections = function(langSelected) {
		$(".translation[lang]").each(function(i, node) {
			var el = $(node),
				lang = el.attr("lang");
			if(lang !== locale && $.inArray(lang, langSelected) === -1) {
				el.addClass("hidden");
			} else {
				el.removeClass("hidden");
			}
		});
	};
	var updateNoteLangs = function(langSelected) {
		$(".inline_note.new select").each(function(i, sel) { // NB: new notes only!
			$(sel).find("option").each(function(i, opt) {
				var el = $(opt),
					lang = el.val();
				if(lang !== locale && $.inArray(lang, langSelected) === -1) {
					el.remove();
				}
			});
		});
	};
	$(document).bind("lang_selected", function(ev, data) {
		toggleSections(data.langs);
		updateNoteLangs(data.langs);
	});
	var langSelector = new IQVOC.LanguageSelector(langWidget, "lang_selected");
	if($("#concept_new, #concept_edit").length) { // edit mode
		// disable secondary language selection to avoid excessive state complexity
		$(":checkbox", langSelector.container).prop("disabled", true);
	}

	// entity selection (edit mode)
	$("input.entity_select").each(function(i, node) {
		IQVOC.EntitySelector(node);
	});

	// Label editing (inline notes)
	$("fieldset.note_relation ol li.inline_note.new").hide();
	$("fieldset.note_relation input[type=button]").click(function(ev) {
		IQVOC.createNote.apply(this, arguments);
		langSelector.notify(); // trigger updateNoteLangs -- XXX: hacky!?
	});
	$("li.inline_note input:checkbox").change(function(ev) {
		var action = this.checked ? "addClass" : "removeClass";
		$(this).closest("li")[action]("deleted");
	});

	// Datepicker
	$.datepicker.setDefaults($.datepicker.regional[locale]);
	$("input.datepicker").datepicker({ dateFormat: "yy-mm-dd" });

	// Dashboard table row highlighting and click handling
	$("tr.highlightable")
		.hover(function(ev) {
			var action = ev.type === "mouseenter" ? "addClass" : "removeClass";
			$(this)[action]("hover");
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
	$("select.search_type").change(function() {
		var result_type_filter = $("li.result_type_filter");
		if($(this).val().match(/labeling/)) {
			result_type_filter.show();
		}
		else {
			result_type_filter.hide();
		}
	});
	$("select.search_type").change();

	// hierarchical tree view
	$("ul.hybrid-treeview").each(function() {
		var url = $(this).attr("data-url"),
			container = this;
		$(this).treeview({
			collapsed: true,
			toggle: function() {
				var el = $(this);
				if(el.hasClass("hasChildren")) {
					var childList = el.removeClass("hasChildren").find("ul");
					$.fn.treeviewLoad({ url: url }, this.id, childList, container);
				}
			}
		});
	});
});

