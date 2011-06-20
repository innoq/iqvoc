/*jslint strict: true, unparam: true, browser: true */
/*global jQuery, IQVOC */

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

	// hierarchical tree view
	$("ul.hybrid-treeview").each(function() {
		var url = $(this).attr("data-url");
		var container = this;
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
