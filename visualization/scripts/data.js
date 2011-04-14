var MOCKDATA;

(function($) {

var planets = [
	{
		data: { altNames: ["Mercury", "Merkur"] }
	}, {
		data: { altNames: ["Venus"] }
	}, {
		data: { altNames: ["Earth", "Erde"] },
		children: [{
			id: "_m0",
			name: "&nbsp;",
			data: { altNames: ["Moon", "Mond"] }
		}]
	}, {
		data: { altNames: ["Mars"] },
		children: [
			{
				id: "_m1",
				name: "&nbsp;",
				data: { altNames: ["Phobos"] }
			}, {
				id: "_m2",
				name: "&nbsp;",
				data: { altNames: ["Deimos"] }
			}
		]
	}, {
		data: { altNames: ["Jupiter"] }
	}, {
		data: { altNames: ["Saturn"] }
	}, {
		data: { altNames: ["Uranus"] }
	}, {
		data: { altNames: ["Neptune", "Neptun"] }
	}
];

var star = {
	data: { altNames: ["Sun", "Sonne"] }
};

// create a node from raw data -- XXX: modifies nested objects in place
var transformData = function(item, i) {
	var id = i + 1;
	var names = item.data.altNames;

	var children = item.children || [];
	$.each(names, function(j, name) {
		children.unshift({ // TODO: use recursion to transform data automatically
			id: "_" + id + "_" + j,
			name: name,
			data: { etype: "label" }
		});
	});

	return {
		id: id.toString(),
		name: "&nbsp;",
		children: children
	};
};

planets = $.map(planets, transformData);
star = transformData(star, -1);

MOCKDATA = $.extend(star, {
	children: star.children.concat(planets)
});

}(jQuery));
