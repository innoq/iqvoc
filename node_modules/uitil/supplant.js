// performs string substitution of named parameters enclosed in `{…}`
// adapted from Douglas Crockford <http://javascript.crockford.com/remedial.html>
export default function supplant(str, params) {
	return str.indexOf("{") === -1 ? str : str.replace(/\{([^{}]*)\}/g, (match, key) => {
		let res = params[key];
		return typeof res === "string" || typeof res === "number" ? res : match;
	});
}
