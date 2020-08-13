// binds the specified `methods`, as identified by their names, to the given `ctx` object
export default function bindMethodContext(ctx, ...methods) {
	methods.forEach(name => {
		ctx[name] = ctx[name].bind(ctx);
	});
}
