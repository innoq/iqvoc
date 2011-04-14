/*jslint browser: true, nomen: false */
/*global jQuery, $jit, IQVOC, HTMLCanvasElement */

// basic settings -- XXX: cargo-culted from JIT examples
var labelType, nativeTextSupport, useGradients, animate; // XXX: useless globals!?
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

IQVOC.visualization = (function($) {

var LEVELDISTANCE = 100;

var init = function() {
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
			dim: 5,
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
			if(node.data.etype === "label") {
				css.height = css.lineHeight = node.Node.height + "px";
				css.padding = "0 2px";
				css.backgroundColor = node.data.$color;
			}
			if(node._depth <= 1) {
				css.fontSize = "0.8em";
				css.color = "#DDD";
			} else if(node._depth === 2) {
				css.fontSize = "0.7em";
				css.color = "#555";
			} else {
				css.display = "none";
			}
			$(domEl).css(css);

			// ensure label is centered on the symbol
			var style = domEl.style;
			var x = parseInt(style.left, 10);
			var y = parseInt(style.top, 10);
			style.top = (y - domEl.offsetHeight / 2) + "px";
			style.left = (x - domEl.offsetWidth / 2) + "px";
		},

		onBeforePlotLine: function(adj) {
			if(adj.nodeTo.data.etype === "label") {
				adj.nodeTo.data.$type = "square";
				adj.nodeTo.data.$color = "#EEE";
				adj.data.$lineWidth = adj.Edge.lineWidth / 2;
				adj.data.$alpha = 0.5;
				adj.data.$color = "#00A";
			}
		}
	});

	viz.loadJSON({ id: 0, name: 0 }); // XXX: DEBUG
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
