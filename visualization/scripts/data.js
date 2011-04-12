var MOCKDATA;

(function($) {

var planets = [
	{
		labels: ["Mercury", "Merkur"]
	}, {
		labels: ["Venus", "Venus"]
	}, {
		labels: ["Earth", "Erde"],
		moons: [{
			labels: ["Moon", "Mond"]
		}]
	}, {
		labels: ["Mars", "Mars"]
	}, {
		labels: ["Jupiter", "Jupiter"]
	}, {
		labels: ["Saturn", "Saturn"]
	}, {
		labels: ["Uranus", "Uranus"]
	}, {
		labels: ["Neptune", "Neptun"]
	}
];

var star = {
	labels: ["Sun", "Sonne"]
};

MOCKDATA = {
	origin: "_concept_" + star.labels[0],
	labels: $.map(star.labels, function(label, i) {
		return {
			origin: "_label_" + i,
			value: label
		};
	}),
	relations: $.map(planets, function(planet, i) {
		var sats = planet.moons;
		var concept = {
			origin: "_concept_" + i,
			label: planet.labels[0],
			labels: planet.labels,
			relations: !sats ? undefined : $.map(sats, function(moon, j) {
				return {
					origin: "_concept_" + i + "-" + j,
					label: moon.labels[0]
				};
			})
		};
		return concept;
	})
};

}(jQuery));
