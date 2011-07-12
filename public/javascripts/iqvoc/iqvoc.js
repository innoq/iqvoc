/*jslint vars: true, unparam: true, browser: true */
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

var createNote = function(ev) {
	var container = $(this).closest("fieldset");
	var source = $("ol li:last-child", container);

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
	var newIdCount = "_" + count + "_";
	var newNameCount = "[" + count + "]";

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
