/*jslint browser: true */
/*global localStorage, jQuery, IQVOC */

IQVOC.LanguageSelector = (function($) {

var getSelection, setSelection;

// namespace is used for both localStorage and the event being triggered
var LanguageSelector = function(container, namespace) {
	this.container = container;
	this.namespace = namespace;

	$(container).addClass("widget").data("widget", this);

	this.langs = getSelection(namespace);
	this.checkboxes = $("input:checkbox", container)
			.live("change", this.onChange);

	if(this.langs.length === 0) {
		this.reset();
	} else {
		var self = this;
		this.checkboxes.each(function(i, node) {
			var el = $(node);
			if($.inArray(el.val(), self.langs) !== -1) {
				el.attr("checked", "checked");
			} else {
				el.removeAttr("checked");
			}
		});
		$(document).trigger(namespace, { langs: this.langs });
	}
};
$.extend(LanguageSelector.prototype, {
	onChange: function(ev) {
		var el = $(this);
		var widget = el.closest(".widget").data("widget");
		if(el.attr("checked")) {
			widget.add(el.val());
		} else {
			widget.remove(el.val());
		}
		if(widget.langs.length === 0) {
			widget.reset(true);
		}
	},
	reset: function(animate) {
		var cbs = this.checkboxes;
		if(animate) {
			var self = this;
			var i = cbs.length;
			cbs.fadeOut().fadeIn(function() {
				i -= 1;
				if(i === 0) {
					self.reset();
				}
			});
		} else {
			this.langs = $.map(cbs, function(node, i) {
				return $(node).val();
			});
			cbs.attr("checked", "checked");
			setSelection(this.langs, this.namespace);
		}
	},
	add: function(value) {
		if($.inArray(value, this.langs) === -1) {
			this.langs.push(value);
			setSelection(this.langs, this.namespace);
		}
	},
	remove: function(value) {
		var pos = $.inArray(value, this.langs);
		if(pos !== -1) {
			this.langs.splice(pos, 1);
			setSelection(this.langs, this.namespace);
		}
	}
});

getSelection = function(namespace) {
	var langs = localStorage.getItem(namespace);
	return langs ? langs.split(",") : [];
};

setSelection = function(langs, namespace) {
	localStorage.setItem(namespace, langs.join(","));
	$(document).trigger(namespace, { langs: langs });
};

return LanguageSelector;

}(jQuery));


jQuery(document).ready(function($) {
	var sections = $("[lang]"),
		container = $(".lang-widget")[0];

	var toggleSections = function(langSelected) {
		sections.each(function(i, node) {
			var el = $(node);
			if($.inArray(el.attr("lang"), langSelected) === -1) {
				el.addClass("hidden");
			} else {
				el.removeClass("hidden");
			}
		});
	};

	$(document).bind("lang_selected", function(ev, data) {
		if(data.langs.length) {
			toggleSections(data.langs);
		}
	});
	new IQVOC.LanguageSelector(container, "lang_selected");
});
