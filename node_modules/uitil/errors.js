// creates a new `Error` subclass
export function makeError(name) {
	let cls = class extends CustomError {};
	cls.prototype.name = name;
	return cls;
}

// NB: Babel transpiler does not support subclassing built-in types
//     with ES6 class syntax (cf. http://stackoverflow.com/q/33870684),
//     so we provide a dummy subclass (using ES5 syntax) for other
//     subclasses to inherit from, thus using ES6 syntax at one remove
function CustomError(message) {
	this.message = message;
	this.stack = (new Error()).stack; // `Error` provides stack trace
}
CustomError.prototype = Object.create(Error.prototype);
