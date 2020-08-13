// determines whether the given DOM element resides within the viewport, based
// on vertical position (i.e. does not take into account other factors like
// horizontal position or styling)
// adapted from http://stackoverflow.com/a/7557433
export default function isVisible(node, tolerance = 0) {
	let box = node.getBoundingClientRect();
	let viewportHeight = window.innerHeight || document.documentElement.clientHeight;
	return box.bottom >= 0 - tolerance && box.top <= viewportHeight + tolerance;
}
