extends Node
class_name UtilityAction

@export var action_name: String = "Idle"
@export var considerations: Array[NodePath]

func evaluate() -> float:
	var score = 1.0
	for consideration_path in considerations:
		var consideration = get_node(consideration_path) as UtilityConsideration
		if consideration:
			score *= consideration.evaluate()
	return score

# Returns true if the action is completed, false if it's still running
func execute(entity: Node, delta: float) -> bool:
	print("Executing action: ", action_name, " on ", entity.name)
	
	# By default, actions complete immediately. 
	# Overriding scripts should return false to keep the action running across multiple frames.
	return true
