class_name AdoptionCenter
extends Node

# Score modifiers
const AGE_PREFERENCE_PASS: float = 15.0
const TEMPERAMENT_PASS: float = 25.0
const DIETARY_PASS: float = 20.0

func calculate_match_score(pet: PetData, adopter: AdopterProfile) -> float:
	var base_score: float = 100.0
	
	# Compatibility 1: Temperament Match 
	if pet.temperament == adopter.preferred_temperament:
		base_score += TEMPERAMENT_PASS
	else:
		base_score -= 15.0
		
	# Compatibility 2: Specific dietary/health check vs Adopter historical budget
	if pet.is_sick and adopter.historical_income < 3000.0:
		# Sickness medical expenses requires higher finances
		base_score -= 30.0
		
	# Compatibility 3: Pet energy levels vs Adopter environment
	if pet.energy > 80.0 and adopter.housing_type_size == "Apartment":
		# Energetic pets suffer in small apartments!
		base_score -= 25.0
		
	# Compatibility 4: Anxious pets with wild family children
	if pet.temperament == PetData.Temperament.ANXIOUS and adopter.child_friendly:
		base_score -= 20.0
		
	return clampf(base_score, 0.0, 100.0)

# Trigger post-adoption survey queues
func simulate_post_adoption_wellbeing(match_score: float) -> Dictionary:
	var rand_roll: float = randf() * 100.0
	var returned_to_shelter: bool = false
	var comments: String = "Living happy and content!"
	
	# Match quality dictates returned chances
	if match_score < 45.0:
		# High probability (60%) of return if poor match
		if rand_roll < 60.0:
			returned_to_shelter = true
			comments = "The pet was highly anxious and destroyed my furniture; my apartment is too noisy."
		else:
			comments = "Struggling but keeping them safely."
			
	elif match_score >= 45.0 and match_score < 75.0:
		if rand_roll < 15.0:
			returned_to_shelter = true
			comments = "Unfortunately, we didn't bond well with the animal. Returning them."
		else:
			comments = "Doing well. The training takes work but we are fully committed."
			
	return {
		"returned": returned_to_shelter,
		"status_report": comments
	}
