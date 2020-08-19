// returns a random integer within the given bounds (both inclusive)
// adapted from
// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Math/random
export function randomInt(min, max) {
	return Math.floor(Math.random() * (max - min + 1)) + min;
}
