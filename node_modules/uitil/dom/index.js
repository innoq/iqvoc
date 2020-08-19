// NB: not necessary when using ES6 spread syntax: `[...nodes].map(…)`
export function find(node, selector) {
	if(node.substr) { // for convenience
		[selector, node] = [node, selector];
	}
	let nodes = node.querySelectorAll(selector);
	return toArray(nodes);
}

export function replaceNode(oldNode, ...newNodes) {
	let container = oldNode.parentNode;
	newNodes.forEach(node => {
		container.insertBefore(node, oldNode);
	});
	container.removeChild(oldNode);
}

export function prependChild(node, container) {
	container.insertBefore(node, container.firstChild);
}

export function removeNode(node) {
	node.parentNode.removeChild(node);
}

let { slice } = Array.prototype;
export let toArray = items => slice.call(items);
