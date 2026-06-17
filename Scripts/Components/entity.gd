extends CharacterBody2D
class_name Entity

@export var utility_ai: NodePath

# Hybrid FSM implementation
enum State {
	IDLE,
	EVALUATING,
	PERFORMING_ACTION
}

var current_state: State = State.EVALUATING
var current_action: UtilityAction = null
var think_timer: float = 0.0
const THINK_INTERVAL: float = 1.5 # 

func _process(delta: float) -> void:
	match current_state:
		State.IDLE:
			# Entity is waiting for an external trigger or event
			pass
			
		State.EVALUATING:
			think_timer -= delta
			if think_timer <= 0.0:
				_run_utility_ai()
				think_timer = THINK_INTERVAL
				
		State.PERFORMING_ACTION:
			if current_action:
				# Execute the action. If it returns true, it has completed.
				var is_finished = current_action.execute(self, delta)
				if is_finished:
					# Action finished, go back to evaluating what to do next
					change_state(State.EVALUATING)

func _run_utility_ai() -> void:
	if not utility_ai:
		return
		
	var ai = get_node(utility_ai) as UtilityAI
	if ai:
		var best_action = ai.evaluate_best_action()
		if best_action:
			current_action = best_action
			change_state(State.PERFORMING_ACTION)
		else:
			# No valid actions found, default to IDLE
			change_state(State.IDLE)

func change_state(new_state: State) -> void:
	# Add any state entry/exit logic here if needed in the future
	current_state = new_state
