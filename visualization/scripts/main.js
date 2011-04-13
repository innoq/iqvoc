/*jslint browser: true */
/*global $jit */

(function($) {

var init = function() { // TODO: namespace!
	var viz,
		container = document.getElementById("infovis"); // XXX: hardcoded!?

	viz = new $jit.RGraph({
		injectInto: container,

		width: container.offsetWidth,
		height: container.offsetHeight,

		// concentric circle as background (cargo-culted from RGraph example)
		background: {
			"CanvasStyles": {
				"strokeStyle": "#AAA",
				"shadowBlur": 50,
				"shadowColor": "#EEE"
			}
		},
		// styles
		levelDistance: 100,
		Node: {
			overridable: true,
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
				viz.onClick(node.id);
			});
		},

		// change node styles when labels are placed/moved
		onPlaceLabel: function(domEl, node) {
			var style = {
				display: "block",
				cursor: "pointer"
			};
			if(node._depth <= 1) {
				style.fontSize = "0.8em";
				style.color = "#DDD";
			} else if(node._depth === 2) {
				style.fontSize = "0.7em";
				style.color = "#555";
			} else {
				style.display = "none";
			}
			$(domEl).css(style);
		},

		onBeforePlotLine: function(adj) {
			if(adj.nodeTo.data.etype === "label") {
				adj.nodeTo.pos.rho = adj.nodeTo.pos.rho * 0.9; // XXX: hacky!?
				adj.nodeTo.data.$type = "square";
				adj.nodeTo.data.$color = "#00D";
				adj.data.$alpha = 0.5;
				adj.data.$color = "#00A";
			}
		}
	});

	viz.loadJSON(MOCKDATA); // XXX: DEBUG
	viz.refresh();
	$(document).ready(function() { viz.onClick("3"); }); // XXX: DEBUG; for demo purposes only
};

init(); // XXX: should not be run by the module itself

return {
	init: init // TODO: rename?
};

}(jQuery));
