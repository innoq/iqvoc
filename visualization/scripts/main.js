/*jslint browser: true */
/*global $jit */

(function($) {

var labelType, nativeTextSupport, useGradients, animate;

// basic settings -- XXX: cargo-culted from JIT examples
(function() {
	var ua = navigator.userAgent,
		iOS = ua.match(/iPhone/i) || ua.match(/iPad/i),
		typeOfCanvas = typeof HTMLCanvasElement,
		nativeCanvasSupport = (typeOfCanvas === "object" || typeOfCanvas === "function"),
		textSupport = nativeCanvasSupport
				&& (typeof document.createElement("canvas").getContext("2d").fillText === "function");
	// settings based on the fact that ExCanvas provides text support for IE
	// and that as of today iPhone/iPad current text support is lame
	labelType = (!nativeCanvasSupport || (textSupport && !iOS)) ? "Native" : "HTML";
	nativeTextSupport = labelType === "Native";
	useGradients = nativeCanvasSupport;
	animate = !(iOS || !nativeCanvasSupport);
}());

var init = function() { // TODO: namespace!
	var ht,
		container = document.getElementById("infovis"); // XXX: hardcoded!?

	ht = new $jit.Hypertree({
		injectInto: container,

		width: container.offsetWidth,
		height: container.offsetHeight,

		// styles
		Node: {
			overridable: true,
			transform: false, // XXX: DEBUG temporary workaround to avoid tiny label label symbols
			dim: 9,
			color: "#F00"
		},
		Edge: {
			lineWidth: 2,
			color: "#088"
		},

		// add text and attach event handlers to labels
		onCreateLabel: function(domEl, node) {
			domEl.innerHTML = node.name; // TODO: use jQuery?
			$jit.util.addEvent(domEl, "click", function(ev) {
				ht.onClick(node.id);
			});
		},

		// change node styles when labels are placed/moved
		onPlaceLabel: function(domEl, node) {
			var style = domEl.style; // TODO: use jQuery
			style.display = '';
			style.cursor = 'pointer';
			if(node._depth <= 1) {
				style.fontSize = "0.8em";
				style.color = "#ddd";
			} else if(node._depth === 2) {
				style.fontSize = "0.7em";
				style.color = "#555";
			} else {
				style.display = 'none';
			}
			var left = parseInt(style.left, 10);
			var width = domEl.offsetWidth;
			style.left = (left - width / 2) + 'px';
		}
	});

	var data = transformData(MOCKDATA); // XXX: DEBUG
	ht.loadJSON(data);
	ht.refresh();
	$(document).ready(function() { ht.onClick("_concept_2"); }); // XXX: DEBUG; for demo purposes only
};

// create a JIT-compatible JSON tree structure from a concept representation
var transformData = function(concept) {
	var relations = $.map(concept.relations, function(rel, i) {
		var node = {
			id: rel.origin,
			name: rel.label,
			data: {
				type: "concept",
				$color: "#A00"
			}
		};
		var relations = !rel.relations ? undefined : $.map(rel.relations, function(rel, j) { // TODO (dynamically, on click?)
			return {
				id: rel.origin,
				name: rel.label
			}
		});
		var labels = !rel.labels ? undefined : $.map(rel.labels, function(label, j) {
			return {
				id: "_" + j + label,
				name: label,
				data: {
					type: "label",
					$type: "triangle",
					$color: "#00A"
				}
			}
		});
		if(labels && relations) {
			node.children = labels.concat(relations);
		} else if(labels || relations) {
			node.children = labels || relations;
		}
		return node;
	});
	var labels = $.map(concept.labels, function(label, i) {
		return {
			id: label.origin,
			name: label.value,
			data: {
				type: "label",
				$type: "triangle",
				$color: "#00A"
			}
		};
	});
	return {
		id: concept.origin,
		name: concept.labels[0].value, // XXX: hack; canonical label should be provided by server
		//data: {}, // TODO?
		children: relations.concat(labels)
	};
};

init(); // XXX: should not be run by the module itself

return {
	init: init // TODO: rename?
};

}(jQuery));
