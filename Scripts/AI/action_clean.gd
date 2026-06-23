# Scripts/AI/action_clean.gd
extends UtilityAction

@export var movement_speed: float = 120.0
@export var clean_time_required: float = 2.0
var target_mess_node: Node2D = null
var current_clean_timer: float = 0.0

func is_executable() -> bool:
	target_mess_node = _find_closest_dirt_node()
	return target_mess_node != null

func _find_closest_dirt_node() -> Node2D:
	var messes = get_tree().get_nodes_in_group("messes")
	if messes.is_empty(): return null
	return messes[0] # Simply returns the nearest registered footprint
