class_name CustomRayPathfinder2D
extends Node2D

@export_category("Pathfinder Settings")
@export var reach_threshold: float = 16.0
@export var lookahead_distance: float = 38.0
@export var avoidance_force: float = 1.6
@export var sliding_drift_force: float = 0.8 # Sideways force to slide past obstacles

# 8 Vector orientation points for circular raycast sweeps
var ray_directions: Array[Vector2] = []
var ray_interest: Array[float] = []
var ray_danger: Array[float] = []

var target_position: Vector2 = Vector2.ZERO
var current_heading: Vector2 = Vector2.ZERO

@onready var parent_entity: CharacterBody2D = get_parent()

func _ready() -> void:
	# Populate 8 cardinal/diagonal compass vectors
	for i in range(8):
		var angle = i * 2 * PI / 8
		ray_directions.append(Vector2(cos(angle), sin(angle)))
		ray_interest.append(0.0)
		ray_danger.append(0.0)

func set_destination(destination: Vector2) -> void:
	target_position = destination

func compute_steering_velocity(delta: float) -> Vector2:
	if not parent_entity:
		return Vector2.ZERO
		
	var global_pos: Vector2 = parent_entity.global_position
	var distance_to_target: float = global_pos.distance_to(target_position)
	
	if distance_to_target < reach_threshold:
		return Vector2.ZERO
		
	# 1. Clear array buffers
	for i in range(8):
		ray_interest[i] = 0.0
		ray_danger[i] = 0.0
		
	# 2. Assign interest coefficients towards destination
	var target_dir: Vector2 = (target_position - global_pos).normalized()
	for i in range(8):
		var alignment: float = ray_directions[i].dot(target_dir)
		ray_interest[i] = maxf(0.0, alignment)
		
	# 3. Cast 2D Rays around the character boundary to record obstacles (Danger maps)
	var space_state = get_world_2d().direct_space_state
	for i in range(8):
		var ray_vector: Vector2 = ray_directions[i] * lookahead_distance
		var query = PhysicsRayQueryParameters2D.create(global_pos, global_pos + ray_vector, 1) # Layer 1 is Walk walls
		query.exclude = [parent_entity.get_rid()] # exclude self
		
		var result = space_state.intersect_ray(query)
		if not result.is_empty():
			var obstacle_pos = result.position
			var distance = global_pos.distance_to(obstacle_pos)
			# Danger weight is higher the closer the wall obstacle is
			var danger_factor: float = 1.0 - (distance / lookahead_distance)
			ray_danger[i] = danger_factor
			
	# 4. Integrate Sliding drift forces for crowd dynamics (Push units apart when overlapping)
	var drifting_shove: Vector2 = Vector2.ZERO
	var query_circle = PhysicsShapeQueryParameters2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = 20.0 # Proximity radius
	query_circle.shape = circle_shape
	query_circle.transform = parent_entity.global_transform
	query_circle.collision_mask = 2 # Layer 2 holds NPCs and pets

	var overlapping_bodies = space_state.intersect_shape(query_circle)
	for body_dict in overlapping_bodies:
		var other_body = body_dict.collider
		if other_body and other_body != parent_entity:
			var push_away: Vector2 = (global_pos - other_body.global_position)
			var length = push_away.length()
			if length > 0.1:
				# Sideways drift shoving
				drifting_shove += (push_away.normalized() / length) * sliding_drift_force
				
	# 5. Calculate chosen steering vector (Interest - Danger)
	var chosen_direction: Vector2 = Vector2.ZERO
	for i in range(8):
		if ray_danger[i] > 0.0:
			# Subtract danger alignment
			ray_interest[i] = clampf(ray_interest[i] - ray_danger[i] * avoidance_force, 0.0, 1.0)
		chosen_direction += ray_directions[i] * ray_interest[i]
		
	# Combine steering direction, push drifting force, and previous heading weight
	chosen_direction = chosen_direction.normalized()
	if chosen_direction == Vector2.ZERO:
		# Fallback: slide opposite the highest danger vector
		var worst_idx: int = -1
		var max_danger: float = -1.0
		for i in range(8):
			if ray_danger[i] > max_danger:
				max_danger = ray_danger[i]
				worst_idx = i
		if worst_idx != -1:
			chosen_direction = -ray_directions[worst_idx]
			
	current_heading = current_heading.lerp(chosen_direction, 0.25).normalized()
	var final_velocity: Vector2 = (current_heading + drifting_shove)
	return final_velocity
