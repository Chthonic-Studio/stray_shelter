class_name PlayerController
extends CharacterBody2D

signal interaction_triggered(interactive_node: Node)
signal ui_toggle_requested(window_name: String)

@export_category("Locomotion")
@export var movement_speed: float = 145.0
@export var acceleration: float = 0.35

@export_category("Interaction Configuration")
@export var reach_distance: float = 32.0

@onready var interaction_cast: RayCast2D = $InteractionRayCast
@onready var sprite: Sprite2D = $Sprite2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var current_held_item: Dictionary = {}

func _physics_process(_delta: float) -> void:
	# 1. Capture keyboard input mapping directionals
	var dir_x: float = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var dir_y: float = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	var input_vector: Vector2 = Vector2(dir_x, dir_y).normalized()
	
	# 2. Smoothly apply velocity using acceleration & friction lerps
	if input_vector != Vector2.ZERO:
		velocity = velocity.lerp(input_vector * movement_speed, acceleration)
		update_interaction_direction(input_vector)
		play_movement_animation(true)
	else:
		velocity = velocity.lerp(Vector2.ZERO, 0.45)
		play_movement_animation(false)
		
	# 3. Godot 4.6 standard safe locomotion call
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	# Trigger Interaction
	if event.is_action_pressed("interact"):
		trigger_raycast_interaction()
		
	# Quick-access bound hotkeys for modular viewport windows
	if event.is_action_pressed("toggle_garden_menu"):
		ui_toggle_requested.emit("garden")
	elif event.is_action_pressed("toggle_vet_ops"):
		ui_toggle_requested.emit("veterinary")
	elif event.is_action_pressed("toggle_staff_payroll"):
		ui_toggle_requested.emit("staff_payroll")
	elif event.is_action_pressed("toggle_crafting"):
		ui_toggle_requested.emit("crafting")

func update_interaction_direction(direction: Vector2) -> void:
	if interaction_cast:
		interaction_cast.target_position = direction * reach_distance
		# Rotate interaction ray visual assist
		interaction_cast.rotation = direction.angle() - PI/2

func play_movement_animation(is_moving: bool) -> void:
	if not anim_player: return
	
	if is_moving:
		# Check direction quadrant to select appropriate sprite sheet frames
		if abs(velocity.x) > abs(velocity.y):
			sprite.flip_h = velocity.x < 0
			anim_player.play("walk_sideways")
		else:
			if velocity.y < 0:
				anim_player.play("walk_up")
			else:
				anim_player.play("walk_down")
	else:
		anim_player.play("idle")

func trigger_raycast_interaction() -> void:
	if not interaction_cast or not interaction_cast.is_colliding():
		return
		
	var target = interaction_cast.get_collider()
	if target:
		interaction_triggered.emit(target)
		if target.has_method("on_interacted"):
			target.on_interacted(self)
