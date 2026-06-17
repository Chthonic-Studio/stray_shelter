class_name Entity
extends CharacterBody2D

@export_group("Movement Configuration")
@export var base_speed: float = 100.0
@export var arrival_tolerance: float = 4.0

@export_group("AI Mapping")
## Automatically grabs a local UtilityAI child node if configured
@onready var utility_ai: UtilityAI = get_node_or_null("UtilityAI")

# Shared navigation tracking
var current_path: Array[Vector2] = []
var target_waypoint: Vector2 = Vector2.ZERO
var is_moving: bool = false

# Polymorphic slot to store specific stats (WorkerStats, PetData, etc.)
var data_profile: Resource

func _ready() -> void:
	_initialize_entity()

## Abstract virtual method. Overridden by concrete subclasses to bind unique resources.
func _initialize_entity() -> void:
	pass

## Global entry point for external scripts or UtilityActions to move this unit
func move_to_destination(global_target: Vector2) -> void:
	current_path = LocalPathfinder.get_pixel_path(global_position, global_target)
	if current_path.size() > 0:
		is_moving = true
		_advance_waypoint()
	else:
		stop()

func _advance_waypoint() -> void:
	if current_path.size() > 0:
		target_waypoint = current_path.pop_front()
	else:
		stop()

func stop() -> void:
	target_waypoint = Vector2.ZERO
	velocity = Vector2.ZERO
	is_moving = false

func _physics_process(_delta: float) -> void:
	if not is_moving or target_waypoint == Vector2.ZERO:
		return
		
	var direction: Vector2 = global_position.direction_to(target_waypoint)
	velocity = direction * base_speed
	move_and_slide()
	
	if global_position.distance_to(target_waypoint) < arrival_tolerance:
		_advance_waypoint()
