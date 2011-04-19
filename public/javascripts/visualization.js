/*jslint browser: true, nomen: false */
/*global jQuery, $jit, IQVOC, HTMLCanvasElement */

jQuery(document).ready(function() {
	IQVOC.visualization.init("infovis");
});

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

var init = function(container) {
	var uri = $("head link[type='application/json']").attr("href"); // XXX: could just use window.location (minus extension)!?
	$.getJSON(uri, function(data, status, xhr) {
		data = transformData(data);
		spawn(container, data);
	});
};

// container can be an ID or a DOM element
var spawn = function(container, data) {
	var viz;
	container = container.nodeType ? container : document.getElementById(container);

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
			$(domEl).html(node.name);
			$jit.util.addEvent(domEl, "click", function(ev) {
				viz.onClick(node.id);
			});
		},

		// change node styles when labels are placed/moved
		onPlaceLabel: function(domEl, node) {
			var css = {}, classes = ["level" + node._depth];
			if(node.data.dummy) {
				classes.push("hidden");
			}
			if(node.data.etype === "label") {
				classes.push("label");
				css.height = css.lineHeight = node.Node.height + "px";
			}
			$(domEl).addClass(classes.join(" ")).css(css);

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
				adj.data.$color = "#00A";
				adj.data.$alpha = 0.5;
			} else {
				var node = adj.nodeTo; // nodeTo is always the inner node!?
				var alpha = determineTransparency(node._depth);
				if(alpha) {
					node.setData("alpha", alpha);
					adj.setData("alpha", alpha);
				}
			}
		}
	});

	viz.loadJSON(data);
	viz.refresh();
};

// create a JIT-compatible JSON tree structure from a concept representation
var transformData = function(concept) {
	return generateConceptNode(concept);
};

// generate node from iQvoc concept representation
var generateConceptNode = function(concept) {
	if(typeof concept.labels === "number") {
		concept.labels = generateDummyLabels(concept.labels);
	}
	if(typeof concept.relations === "number") {
		concept.relations = generateDummyConcepts(concept.relations);
	}
	var labels = $.map(concept.labels || [], generateLabelNode);
	var relations = $.map(concept.relations || [], generateConceptNode);
	return {
		id: concept.origin,
		name: "&nbsp", // XXX: hacky; better solved with CSS!?
		children: labels.concat(relations),
		data: { dummy: concept.dummy }
	};
};

// generate node from iQvoc label representation
var generateLabelNode = function(label) {
	// TODO: support for non-XL labels
	return {
		id: label.origin,
		name: label.value,
		data: { etype: "label", dummy: label.dummy }
		// TODO: relations to other concepts (XL only)
	};
};

// generate dummy iQvoc label representations
var generateDummyConcepts = function(count) {
	return $.map(new Array(count), function(item, i) {
		return { origin: Math.random(), dummy: true };
	});
};

// generate dummy iQvoc label representations
var generateDummyLabels = function(count) {
	return $.map(new Array(count), function(item, i) {
		return { origin: Math.random(), value: "", dummy: true };
	});
};

var determineTransparency = function(depth) {
	if(depth === 2) {
		return 0.6;
	} else if(depth > 2) {
		return 0.3;
	}
};

// hijack setPos method to reduce the relative distance for label nodes -- XXX: modifies all Node instances!
var _setPos = $jit.Graph.Node.prototype.setPos;
$jit.Graph.Node.prototype.setPos = function(value, type) {
	if(this.data.etype === "label") {
		value.rho = value.rho - (LEVELDISTANCE * 0.5);
	}
	return _setPos.apply(this, arguments);
};

return {
	init: init
};

}(jQuery));
