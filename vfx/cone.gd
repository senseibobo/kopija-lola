extends VisualEffect


func apply_args(args):
	.apply_args(args)
	process_material.spread = args[VFX.ARGS_SIZE] if VFX.ARGS_SIZE in args else 5.0
