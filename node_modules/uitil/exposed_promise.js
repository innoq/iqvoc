export default function exposedPromise(fn) {
	let _resolve, _reject;
	let prom = new Promise((resolve, reject) => {
		_resolve = resolve;
		_reject = reject;

		if(fn) { // mimic `Promise` signature
			fn(resolve, reject);
		}
	});

	prom.resolve = _resolve;
	prom.reject = _reject;
	return prom;
}
