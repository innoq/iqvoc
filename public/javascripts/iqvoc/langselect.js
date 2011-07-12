/*jslint vars: true, unparam: true, browser: true */
/*global jQuery, IQVOC */

IQVOC.LanguageSelector = (function($) {

"use strict";

var getSelection, setSelection;

// namespace is used for both localStorage and the event being triggered
var LanguageSelector = function(container, namespace) {
	this.container = container;
	this.namespace = namespace;
	this.langs = getSelection(namespace);
	this.checkboxes = $("input:checkbox", container)
		.live("change", this.onChange);

	$(container).addClass("widget").data("widget", this);
	this.init();
};
$.extend(LanguageSelector.prototype, {
	onChange: function(ev) {
		var el = $(this),
			widget = el.closest(".widget").data("widget");
		if(this.checked) {
			widget.add(el.val());
		} else {
			widget.remove(el.val());
		}
	},
	init: function() {
		if(this.langs === null) {
			this.langs = $.map(this.checkboxes, function(node, i) {
				return $(node).val();
			});
		}
		var self = this;
		this.checkboxes.each(function(i, node) {
			node.checked = $.inArray($(node).val(), self.langs) !== -1;
		});
		this.notify();
	},
	notify: function() {
		$(document).trigger(this.namespace, { langs: this.langs });
	},
	add: function(value) {
		if($.inArray(value, this.langs) === -1) {
			this.langs.push(value);
			setSelection(this.langs, this.namespace, this);
		}
	},
	remove: function(value) {
		var pos = $.inArray(value, this.langs);
		if(pos !== -1) {
			this.langs.splice(pos, 1);
			setSelection(this.langs, this.namespace, this);
		}
	}
});

getSelection = function(namespace) {
	var langs = IQVOC.Storage.getItem(namespace);
	return langs === null ? null : (langs ? langs.split(",") : []);
};

setSelection = function(langs, namespace, context) {
	IQVOC.Storage.setItem(namespace, langs.join(","));
	context.notify();
};

return LanguageSelector;

}(jQuery));
