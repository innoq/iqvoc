IQVOC.labelResolver = (function($) {

"use strict";

return function(context) {
	$("a.unlabeled", context).each(processNode);
};

function retrieveLabel(conceptURL, el, callback) {
  var datasets = $("body").data("datasets");
  var proxy = $("body").data("remote-label-path");

	var conceptBaseURL = getBaseURI(conceptURL);

	// try to get remote label if conceptBaseURL is a iqvoc instance
	if(conceptBaseURL in datasets) {
		$.get(proxy, { concept_url: conceptURL }, function(data, status, xhr) {
			el.text(data.label);
			el.removeClass("unlabeled");
		});
	}
}

function processNode(i, node) {
	var el = $(node);
	var uri = el.attr("href");
	retrieveLabel(uri, el);
}

function getBaseURI(url) {
	var uri = new URI(url);
	var parts = {
		protocol: uri.protocol(),
		hostname: uri.host()
	};
	return URI.build(parts);
}

}(jQuery));
