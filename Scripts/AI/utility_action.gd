class_name UtilityAction
extends Node

enum CombiningMethod { MULTIPLY, AVERAGE, ADDITIVE_CLAMP }

@export var action_name: String = "Action"
@export var base_weight: float = 1.0
@export var combining_method: CombiningMethod = CombiningMethod.MULTIPLY

func is_executable() -> bool:
	return true

func enter(entity: CharacterBody2D) -> void:
	# Code to trigger entity animation & pathfinding target
	pass

func execute_tick(entity: CharacterBody2D, delta: float) -> void:
	# Run continuous processes (eating, sleeping animation steps)
	pass

func exit() -> void:
	pass

func evaluate_action(entity: CharacterBody2D) -> float:
	var considerations: Array[Node] = get_children()
	if considerations.is_empty():
		return base_weight

	var scores: Array[float] = []
	for node in considerations:
		if node is UtilityConsideration:
			scores.append(node.get_score(entity))

	if scores.is_empty():
		return 0.0

	var final_score: float = 1.0
	match combining_method:
		CombiningMethod.MULTIPLY:
			# If any critical need is 0, the final score becomes 0
			for s in scores:
				final_score *= s
			final_score *= base_weight
			
		CombiningMethod.AVERAGE:
			var sum: float = 0.0
			for s in scores:
				sum += s
			final_score = (sum / scores.size()) * base_weight
			
		CombiningMethod.ADDITIVE_CLAMP:
			var sum: float = 0.0
			for s in scores:
				sum += s
			final_score = clampf(sum, 0.0, 1.0) * base_weight

	return final_score
