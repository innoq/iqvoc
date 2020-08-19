// generates a DOM element
// `params` describe attributes and/or properties, as determined by the
// respective type (string or boolean attributes vs. arbitrary properties)
// if a `ref` parameter is provided, it is expected to contain a `[refs, id]`
// tuple; `refs[id]` will be assigned the respective DOM node
// `children` is an array of strings or DOM elements
export function createElement(tag, params, ...children) {
	params = params || {};
	let node = document.createElement(tag);
	Object.keys(params).forEach(param => {
		let value = params[param];
		// special-casing for node references
		if(param === "ref") {
			let [registry, name] = value;
			registry[name] = node;
			return;
		}
		// boolean attributes (e.g. `<input … autofocus>`)
		if(value === true) {
			value = "";
		} else if(value === false) {
			return;
		}
		// attributes vs. properties
		if(value.substr) {
			node.setAttribute(param, value);
		} else {
			node[param] = value;
		}
	});

	children.forEach(child => {
		if(child.substr || (typeof child === "number")) {
			child = document.createTextNode(child);
		}
		node.appendChild(child);
	});

	return node;
}

// tag expression for HTML template literals
// NB:
// * returns a single DOM element
// * discards blank values (`undefined`, `null`, `false`) to allow for
//   conditionals with boolean operators (`condition && value`)
export function html2dom(parts, ...values) {
	let html = parts.reduce((memo, part, i) => {
		let val = values[i];
		let blank = val === undefined || val === null || val === false;
		return memo.concat(blank ? [part] : [part, val]);
	}, []).join("");

	let tmp = document.createElement("div");
	tmp.innerHTML = html.trim();
	return tmp.childNodes[0];
}
