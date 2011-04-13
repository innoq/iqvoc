/*jslint browser: true */
/*global $jit */

(function($) {

var LEVELDISTANCE = 100;

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
				"shadowBlur": 50
				//"shadowColor": "#EEE" // XXX: fills entire background in Chrome!?
			}
		},
		// styles
		levelDistance: LEVELDISTANCE,
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
				adj.nodeTo.data.$type = "square";
				adj.nodeTo.data.$color = "#00D";
				adj.data.$alpha = 0.5;
				adj.data.$color = "#00A";
			}
		}
	});

	viz.loadJSON(MOCKDATA); // XXX: DEBUG
	viz.refresh();
};

// hijack setPos method to reduce the relative distance for label nodes -- XXX: modifies all Node instances!
var _setPos = $jit.Graph.Node.prototype.setPos;
$jit.Graph.Node.prototype.setPos = function(value, type) {
	if(this.data.etype === "label") {
		value.rho = value.rho - (LEVELDISTANCE * 0.5);
	}
	return _setPos.apply(this, arguments);
};

init(); // XXX: should not be run by the module itself

return {
	init: init // TODO: rename?
};

}(jQuery));
