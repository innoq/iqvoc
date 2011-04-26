/*jslint browser: true */
/*global localStorage, jQuery */

jQuery(document).ready(function($) {

var sections = $("[lang]"),
	checkboxes = $(".lang-widget input:checkbox");

var getSelection = function() {
	var langs = localStorage.getItem("lang_selected");
	return langs ? langs.split(",") : [];
};

var setSelection = function(langs) {
	localStorage.setItem("lang_selected", langs.join(","));
};

var setCheckboxes = function(langSelected) {
	console.log("setCB", langSelected);
	if(langSelected.length) {
		checkboxes.removeAttr("checked");
	} else {
		checkboxes.attr("checked", "checked");
	}
	$.each(langSelected, function(i, lang) {
		checkboxes.filter("[value=" + lang + "]").attr("checked", "checked");
	});
};

var toggleSections = function(langSelected) {
	console.log("toggle", langSelected, sections);
	sections.each(function(i, node) {
		var el = $(node);
		if(langSelected.length && $.inArray(el.attr("lang"), langSelected) === -1) {
			el.addClass("hidden");
		} else {
			el.removeClass("hidden");
		}
	});
};

var init = function() {
	var langSelected = getSelection();
	console.log("init", langSelected);
	toggleSections(langSelected);
	setCheckboxes(langSelected);
};

checkboxes.live("change", function(ev) {
	var el = $(this);
	var langs = getSelection();
	var pos = langs.indexOf(el.val());
	console.log("changed", langs, pos, this);
	if(el.attr("checked")) {
		if(pos === -1) {
			langs.push(el.val());
		}
	} else {
		langs.splice(pos, 1);
	}
	setSelection(langs);
	setCheckboxes(langs);
	toggleSections(langs);
	console.log("changed", getSelection());
});

init();

});
