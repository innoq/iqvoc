/*jslint browser: true */
/*global $jit */

(function($) {

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
			transform: false, // XXX: DEBUG temporary workaround to avoid tiny label symbols
			dim: 9,
			color: "#F00"
		},
		Edge: {
			overridable: true,
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
			style.display = "";
			style.cursor = "pointer";
			if(node._depth <= 1) {
				style.fontSize = "0.8em";
				style.color = "#ddd";
			} else if(node._depth === 2) {
				style.fontSize = "0.7em";
				style.color = "#555";
			} else {
				style.display = "none";
			}
			var left = parseInt(style.left, 10);
			var width = domEl.offsetWidth;
			style.left = (left - width / 2) + "px";
		},

		onBeforePlotLine: function(adj) {
			if(adj.nodeTo.data.etype === "label") {
				//adj.nodeTo.pos.rho = adj.nodeTo.pos.rho * 0.9; // XXX: hacky?
				adj.nodeTo.data.$type = "square";
				adj.nodeTo.data.$color = "#00A";
				adj.data.$alpha = 0.5;
				adj.data.$type = "arrow";
				adj.data.$color = "#00A";
			}
		}
	});

	ht.loadJSON(MOCKDATA); // XXX: DEBUG
	ht.refresh();
	$(document).ready(function() { ht.onClick("3"); }); // XXX: DEBUG; for demo purposes only
};

init(); // XXX: should not be run by the module itself

return {
	init: init // TODO: rename?
};

}(jQuery));
