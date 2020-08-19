// adapted from David Walsh <https://davidwalsh.name/javascript-once>
export default function once(ctx, fn) {
	if(fn === undefined) { // shift arguments
		fn = ctx;
		ctx = null;
	}

	let res;
	return function() {
		if(fn) {
			res = fn.apply(ctx, arguments);
			fn = null;
		}
		return res;
	};
}
