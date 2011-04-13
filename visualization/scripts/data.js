var MOCKDATA;

(function($) {

var planets = [
	{
		name: "Mercury",
		data: { altNames: ["Merkur"] }
	}, {
		name: "Venus"
	}, {
		name: "Earth",
		data: { altNames: ["Erde"] },
		children: [{
			id: null,
			name: "Moon",
			data: { altNames: ["Mond"] }
		}]
	}, {
		name: "Mars"
	}, {
		name: "Jupiter"
	}, {
		name: "Saturn"
	}, {
		name: "Uranus"
	}, {
		name: "Neptune",
		data: { altNames: ["Neptun"] }
	}
];
// add IDs, turn labels into children
planets = $.map(planets, function(planet, i) {
	planet.id = (i + 1).toString(); // NB: Sun is 0
	var children = planet.children || [];
	if(planet.data && planet.data.altNames) {
		$.each(planet.data.altNames, function(j, name) {
			children.unshift({
				id: "_" + i + "_" + j,
				name: name,
				data: { etype: "label" }
			});
		});
		planet.children = children;
	}
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
