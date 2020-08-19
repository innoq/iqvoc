export function selectLast(node, selector) {
	let nodes = node.querySelectorAll(selector);
	let { length } = nodes;
	return length ? nodes[length - 1] : null;
}
