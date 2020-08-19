import { toArray } from "./";

export function html2dom(html) {
	let tmp = document.createElement("html");
	tmp.innerHTML = html;

	let root = document.createDocumentFragment(); // allows for DOM queries
	toArray(tmp.childNodes).forEach(node => {
		root.appendChild(node);
	});
	return root;
}
