export function parseURIParams(queryString) {
	if(!queryString.trim()) {
		return {};
	}

	return queryString.split("&").reduce((memo, param) => {
		if(param.trim()) {
			let [key, value] = param.split("=").map(decodeURIComponent);
			if(!memo[key]) {
				memo[key] = [];
			}
			// NB: accounts for boolean parameters where presence suffices
			memo[key].push(value === undefined ? true : value);
		}
		return memo;
	}, {});
}
