/*jslint vars: true, browser: true, white: true */
/*global jQuery, IQVOC */

IQVOC.quicksearch = (function($) {

"use strict";

var defaults = {
	minLength: 3,
	autoFocus: true,
	source: getConcepts,
	focus: function(ev, ui) { ev.preventDefault(); },
	select: onSelect
};

function onSelect(ev, ui) {
	document.location = ui.item.value;
}

function getConcepts(req, callback) {
	var form = $(this.element).closest("form");
	$.ajax({
		type: form.attr("method"),
		url: form.attr("action"),
		data: form.serialize(),
		success: function(data, status, xhr) {
			callback(extractConcepts(data));
		}
	});
}

function extractConcepts(html) {
	// disable scripts (adapted from jQuery's `load`)
	var rscript = /<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi;
	html = html.replace(rscript, "");

	var concepts = $("<div />").append(html).find("ul.concepts li");
	concepts = concepts.map(function(i, node) {
		var el = $("a", node);
		return { value: el.attr("href"), label: $.trim(el.text()) };
	});

	return Array.prototype.slice.call(concepts, 0);
}

return function(selector, options) {
	options = options ? $.extend(defaults, options) : defaults;
	$(selector).autocomplete(options);
};

}(jQuery));
