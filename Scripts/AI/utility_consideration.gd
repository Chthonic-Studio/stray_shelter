class_name UtilityConsideration
extends Node

enum CurveType { LINEAR, STEP, EXPONENTIAL, LOGISTIC }

@export_category("Evaluation Settings")
@export var stat_to_check: String = "hunger"
@export var inverse: bool = false
@export var curve_type: CurveType = CurveType.LINEAR

@export_category("Curve Parameters")
@export var exponent: float = 2.0
@export var slope: float = 1.0
@export var offset: float = 0.0

func get_score(entity: CharacterBody2D) -> float:
	# Safely lookup property in the pet data composition
	var pet_stats = entity.get_node_or_null("PetStats")
	if not pet_stats or not "data" in pet_stats:
		return 0.0
		
	var pet_data: PetData = pet_stats.data
	if not stat_to_check in pet_data:
		return 0.0
		
	# Normalized raw stat (0.0 to 1.0 value)
	var raw_val: float = pet_data.get(stat_to_check) / 100.0
	var input: float = 1.0 - raw_val if inverse else raw_val
	
	var evaluated_score: float = 0.0
	match curve_type:
		CurveType.LINEAR:
			evaluated_score = clampf(slope * input + offset, 0.0, 1.0)
			
		CurveType.STEP:
			evaluated_score = 1.0 if input >= offset else 0.0
			
		CurveType.EXPONENTIAL:
			evaluated_score = clampf(pow(input, exponent) * slope + offset, 0.0, 1.0)
			
		CurveType.LOGISTIC:
			# Standard S-Curve: 1 / (1 + e^(-k * (x - x0)))
			var k: float = slope * 10.0
			var x0: float = offset if offset != 0.0 else 0.5
			var denom: float = 1.0 + exp(-k * (input - x0))
			evaluated_score = clampf(1.0 / denom, 0.0, 1.0)
			
	return evaluated_score
