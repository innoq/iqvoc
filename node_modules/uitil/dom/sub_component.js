/* eslint-env browser */
import CustomTag from "./custom_tag";

// usage:
//
//    class MyComponent extends SubComponent {
//        static get containerComponent() {
//            return "my-container-component";
//        }
//
//        deferredConnectedCallback(container) {
//            // here `container` element is guaranteed to be upgraded
//        }
//
//        …
//    }
//
// (note that `SubComponent` inherits from `CustomTag` for convenience)
export default class SubComponent extends CustomTag {
	connectedCallback() {
		this.containerComponent.
			then(container => void this.deferredConnectedCallback(container));
	}

	get containerComponent() {
		let tag = this.constructor.containerComponent;
		let container = this.closest(tag);
		if(!container) {
			let el = this.nodeName.toLowerCase();
			throw new Error(`missing container element <${tag}> for <${el}>`);
		}

		return customElements.whenDefined(tag). // ensures element was upgraded
			then(_ => awaitUpgrade(container)); // ensures instance was upgraded
	}
}

// polls container element until it is upgraded
// NB: this is different from `whenDefined` as it targets the respective element
//     instance rather than the global tag registration
function awaitUpgrade(node, attempts = 0) {
	return node.connectedCallback ? Promise.resolve(node) : new Promise(resolve => {
		setTimeout(_ => {
			awaitUpgrade(node, attempts + 1).then(resolve);
		}, attempts * 10);
	});
}
