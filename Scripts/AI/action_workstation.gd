# Scripts/AI/action_work_station.gd
extends UtilityAction

# Custom action for Worker AI: Go to assigned workstation and perform duties.
# Inherits from UtilityAction.

@export var movement_speed: float = 110.0

var is_station_blocked: bool = false
var target_station_node: Node2D = null

func _ready() -> void:
	action_name = "Work at Station"

func is_executable() -> bool:
	# Action is valid if they have an assigned workstation and it's not occupied by the player
	if not target_station_node:
		_find_assigned_workstation()
		
	if not target_station_node:
		return false
		
	return not target_station_node.is_occupied_by_player

func evaluate_action(entity: CharacterBody2D) -> float:
	if not is_executable():
		return 0.0
		
	# Standard calculation: Multiply considerations
	return evaluate()

func _find_assigned_workstation() -> void:
	if has_node("/root/JobManager") and get_parent() and get_parent().get_parent():
		var host = get_parent().get_parent() # host worker entity
		var job_mgr = get_node("/root/JobManager")
		for station_name in job_mgr.assigned_workers.keys():
			if job_mgr.assigned_workers[station_name] == host:
				target_station_node = job_mgr.workstations.get(station_name)
				break

func enter(entity: CharacterBody2D) -> void:
	_find_assigned_workstation()
	if target_station_node and entity.has_node("CustomRayPathfinder2D"):
		entity.get_node("CustomRayPathfinder2D").set_destination(target_station_node.global_position)

func execute(entity: Node, delta: float) -> bool:
	if not target_station_node:
		return true # End action if target lost
		
	if target_station_node.is_occupied_by_player:
		# Player took over! Instantly fail so worker shifts to secondary chores
		return true 
		
	var global_pos: Vector2 = entity.global_position
	var target_pos: Vector2 = target_station_node.global_position
	var distance: float = global_pos.distance_to(target_pos)
	
	if distance > 20.0:
		# Navigate towards station using Pathfinder
		var steer_dir: Vector2 = Vector2.ZERO
		if entity.has_node("CustomRayPathfinder2D"):
			steer_dir = entity.get_node("CustomRayPathfinder2D").compute_steering_velocity(delta)
		else:
			steer_dir = (target_pos - global_pos).normalized()
			
		entity.velocity = steer_dir * movement_speed
		entity.move_and_slide()
		
		# Animate walking
		if entity.has_method("play_animation"):
			entity.play_animation("walk")
			
		return false # Still running
	else:
		# Stood at station! Perform duties
		entity.velocity = Vector2.ZERO
		if entity.has_method("play_animation"):
			entity.play_animation("idle")
			
		# Tick duties (Simulate helping clinic patient or matching adopters)
		# Accumulate shift fatigue
		if "worker_data" in entity and entity.worker_data:
			entity.worker_data.fatigue = clampf(entity.worker_data.fatigue + 0.01 * delta, 0.0, 1.0)
			
		return false # Stay working until AI evaluates a higher priority need (or gets kicked)

func execute_tick(entity: CharacterBody2D, tick_rate: float) -> void:
	# Supporting alternative tick rate call
	execute(entity, tick_rate)

func exit() -> void:
	target_station_node = null
