class_name Worker
extends Entity

@export var worker_stats: WorkerStats

func _initialize_entity() -> void:
	data_profile = worker_stats
	if worker_stats:
		# Example: override base_speed dynamically from your Resource files
		if "movement_speed" in worker_stats:
			base_speed = worker_stats.movement_speed
