class_name UtilityAI
extends Node

signal action_changed(old_action: String, new_action: String)

@export var is_active: bool = true
@export var tick_rate: float = 1.0 # Times evaluated per second

var current_action: UtilityAction = null
var current_action_score: float = 0.0
var time_since_last_tick: float = 0.0

@onready var host_entity: CharacterBody2D = get_parent()

func _ready() -> void:
	if not host_entity:
		push_error("UtilityAI: Parent must be a CharacterBody2D entity!")
		is_active = false

func _process(delta: float) -> void:
	if not is_active:
		return
		
	time_since_last_tick += delta
	if time_since_last_tick >= tick_rate:
		time_since_last_tick = 0.0
		evaluate_decisions()

func evaluate_decisions() -> void:
	var best_action: UtilityAction = null
	var best_score: float = -1.0
	
	# Loop through all child Custom Utility Action nodes
	for child in get_children():
		if child is UtilityAction and child.is_executable():
			var score: float = child.evaluate_action(host_entity)
			if score > best_score:
				best_score = score
				best_action = child
				
	# Apply state transitions if action changes
	if best_action != current_action:
		var previous_name: String = current_action.name if current_action else "None"
		if current_action:
			current_action.exit()
		
		current_action = best_action
		current_action_score = best_score
		
		if current_action:
			current_action.enter(host_entity)
			action_changed.emit(previous_name, current_action.name)
	else:
		if current_action:
			current_action.execute_tick(host_entity, tick_rate)
