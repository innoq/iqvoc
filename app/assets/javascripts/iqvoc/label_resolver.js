var labelResolver = (function($) {

"use strict";

// XXX: DEBUG
$.get = function(uri, callback) {
	callback({ label: "Hello World" });
}

return function(context) {
	$("a.unlabeled", context).each(processNode);
};

function retrieveLabel(uri, el, callback) {
	$.get(uri, function(data, status, xhr) {
		el.text(data.label);
		el.removeClass("unlabeled");
	});
}

function processNode(i, node) {
	var el = $(node);
	var uri = el.attr("href");
	retrieveLabel(uri, el);
}

}(jQuery))
