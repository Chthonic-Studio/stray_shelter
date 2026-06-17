class_name Worker
extends Entity

@export var worker_data: WorkerData

func _ready() -> void:
	if not worker_data:
		push_warning("Worker node '", name, "' is missing WorkerData!")
		return
