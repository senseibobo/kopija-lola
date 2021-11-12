extends Particles2D
class_name VisualEffect

export var duration : float = 2.0


func _ready():
	emitting = true

func _process(delta):
	duration -= delta
	if duration <= 0: queue_free()
	
func apply_args(args):
	rotation = PI+args[VFX.ARGS_ROTATION] if VFX.ARGS_ROTATION in args else 0.0
	
