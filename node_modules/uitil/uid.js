let CHARSET = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".split("");

// generates pseudo-unique identifier, modeled on Purple Numbers
export function nid(max = 9007199254740991) { // ≙ `Number.MAX_SAFE_INTEGER`
	let i = Math.random() * max;
	return base62encode(Math.round(i));
}

// adapted from Base62.js
function base62encode(int) {
	let i = int;
	let res = "";
	while(i > 0) {
		res = CHARSET[i % 62] + res;
		i = Math.floor(i / 62);
	}
	return int === 0 ? CHARSET[0] : res;
}
