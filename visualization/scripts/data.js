var MOCKDATA;

(function($) {

var planets = [
	{
		data: { altNames: ["Mercury", "Merkur"] }
	}, {
		data: { altNames: [""] }
	}, {
		data: { altNames: ["Earth", "Erde"] },
		children: [{
			id: "_m0",
			name: "Moon",
			data: { altNames: ["Moon", "Mond"] }
		}]
	}, {
		data: { altNames: ["Mars"] },
		children: [
			{
				id: "_m1",
				name: "Phobos"
			}, {
				id: "_m2",
				name: "Deimos"
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
// add IDs, turn labels into children
planets = $.map(planets, function(planet, i) {
	planet.id = (i + 1).toString(); // NB: Sun is 0

	var names = planet.data.altNames;
	planet.name = names[0];

	var children = planet.children || [];
	$.each(names, function(j, name) {
		children.unshift({
			id: "_" + i + "_" + j,
			name: name,
			data: { etype: "label" }
		});
	});
	planet.children = children;

	return planet;
});

var star = {
	id: "0",
	name: "Sun",
	data: { altNames: ["Sonne"] }
};

MOCKDATA = $.extend({}, star, {
	children: planets
});

}(jQuery));
