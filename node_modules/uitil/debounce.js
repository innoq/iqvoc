// limits the rate of `fn` invocations
// `delay` is the rate limit in milliseconds
// `ctx` (optional) is the function's execution context (i.e. `this`)
// `fn` is the respective function
// adapted from StuffJS <https://github.com/bengillies/stuff-js>
export default function debounce(delay, ctx, fn) {
	if(fn === undefined) { // shift arguments
		fn = ctx;
		ctx = null;
	}

	let timer;
	return function() {
		let args = arguments;
		if(timer) {
			clearTimeout(timer);
			timer = null;
		}
		timer = setTimeout(_ => {
			fn.apply(ctx, args);
			timer = null;
		}, delay);
	};
}
