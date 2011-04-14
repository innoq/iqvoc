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
			var css = {
				display: "block",
				cursor: "pointer"
			};
			if(node._depth <= 1) {
				css.fontSize = "0.8em";
				css.color = "#DDD";
			} else if(node._depth === 2) {
				css.fontSize = "0.7em";
				css.color = "#555";
			} else {
				css.display = "none";
			}

			var style = domEl.style;
			//var x = parseInt(style.left, 10);
			var y = parseInt(style.top, 10);
			//var width = domEl.offsetWidth;
			style.top = (y + 10) + "px";
			//style.left = (x - width / 2) + "px";

			$(domEl).css(css);
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
