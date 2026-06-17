class_name PlayerController
extends CharacterBody2D

signal interaction_triggered(interactive_node: Node)

@export_category("Locomotion")
@export var movement_speed: float = 145.0
@export var acceleration: float = 0.35

@export_category("Interaction Configuration")
@export var reach_distance: float = 32.0

@onready var interaction_cast: RayCast2D = $InteractionRayCast
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var current_held_item: Dictionary = {}
var facing_direction: String = "down" # Tracks the last direction faced

func _physics_process(_delta: float) -> void:
	# 1. Capture keyboard input mapping directionals
	var dir_x: float = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var dir_y: float = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	var input_vector: Vector2 = Vector2(dir_x, dir_y).normalized()
	
	# 2. Smoothly apply velocity using acceleration & friction lerps
	if input_vector != Vector2.ZERO:
		velocity = velocity.lerp(input_vector * movement_speed, acceleration)
		update_interaction_direction(input_vector)
		update_facing_direction(input_vector)
		play_animation("walk")
	else:
		velocity = velocity.lerp(Vector2.ZERO, 0.45)
		play_animation("idle")
		
	# 3. Godot 4.6 standard safe locomotion call
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	# Trigger Interaction
	if event.is_action_pressed("interact"):
		trigger_raycast_interaction()
		
	# Quick-access bound hotkeys for modular viewport windows
	if event.is_action_pressed("toggle_garden_menu"):
		UIManager.toggle_menu_window("garden")
	elif event.is_action_pressed("toggle_vet_ops"):
		UIManager.toggle_menu_window("veterinary")
	elif event.is_action_pressed("toggle_staff_payroll"):
		UIManager.toggle_menu_window("staff_payroll")
	elif event.is_action_pressed("toggle_crafting"):
		UIManager.toggle_menu_window("crafting")
	elif event.is_action_pressed("toggle_inventory"):
		UIManager.toggle_menu_window("inventory")

func update_interaction_direction(direction: Vector2) -> void:
	if interaction_cast:
		interaction_cast.target_position = direction * reach_distance
		# Rotate interaction ray visual assist
		interaction_cast.rotation = direction.angle() - PI/2

func update_facing_direction(direction: Vector2) -> void:
	# Check direction quadrant to update our facing state string
	if abs(direction.x) > abs(direction.y):
		facing_direction = "sideways"
		# Flip the sprite based on whether we are moving left or right
		sprite.flip_h = direction.x < 0
	else:
		if direction.y < 0:
			facing_direction = "up"
		else:
			facing_direction = "down"

func play_animation(base_animation_name: String) -> void:
	# Dynamically construct the animation name (e.g. "idle_down", "pickup_sideways")
	var full_anim_name = base_animation_name.to_lower() + "_" + facing_direction
	sprite.play(full_anim_name)

func trigger_raycast_interaction() -> void:
	if not interaction_cast or not interaction_cast.is_colliding():
		return
		
	var target = interaction_cast.get_collider()
	if target:
		interaction_triggered.emit(target)
		if target.has_method("on_interacted"):
			target.on_interacted(self)
