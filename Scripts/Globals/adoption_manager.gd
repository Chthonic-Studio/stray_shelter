extends Node

# AutoLoad name registers as: AdoptionManager
signal adoption_finalized(pet_data: PetData, adopter: AdopterProfile)
signal adoption_returned(pet_data: PetData, reason: String)

func calculate_compatibility_compatibility(pet: PetData, adopter: AdopterProfile) -> float:
	if not pet or not adopter:
		return 0.0
		
	var rating: float = 100.0
	
	# check 1: Species preferred match
	if pet.species != adopter.preferred_species:
		rating -= 20.0
		
	# check 2: Temperament compatibility
	if pet.temperament == adopter.preferred_temperament:
		rating += 15.0
	else:
		rating -= 15.0
		
	# check 3: Chronically ill vs. adopter budget
	if pet.is_sick:
		if not adopter.willing_to_treat_sick:
			rating -= 40.0
		if adopter.monthly_income < 3000.0:
			rating -= 25.0 # can't support veterinary medical bills
			
	# check 4: High active energy vs. tight apartment housing bounds
	if pet.energy > 80.0 and adopter.housing_type == "Apartment":
		rating -= 30.0
		
	# check 5: Anxious animal with noisy households (children)
	if pet.temperament == PetData.Temperament.ANXIOUS and adopter.is_child_friendly:
		rating -= 15.0
		
	return clampf(rating, 0.0, 100.0)

func process_placement_decision(pet: PetData, adopter: AdopterProfile) -> Dictionary:
	var score: float = calculate_compatibility_compatibility(pet, adopter)
	var processed_data: Dictionary = {
		"eligible": score >= 50.0,
		"score": score,
		"notes": "Adoption matching rate acceptable!"
	}
	
	if score < 50.0:
		processed_data["notes"] = "Unsatisfactory. Adopter lacks appropriate yard space or budget for pet needs."
	elif score >= 85.0:
		processed_data["notes"] = "Sought match! The household perfectly complements the animal's needs."
		
	return processed_data

func trigger_weekly_wellbeing_survey(pet: PetData, adopter: AdopterProfile) -> void:
	var score: float = calculate_compatibility_compatibility(pet, adopter)
	var random_roll: float = randf() * 100.0
	
	# Lower scores increase return probability
	if score < 45.0:
		if random_roll < 65.0:
			# Returned to shelter!
			emit_signal("adoption_returned", pet, "Returned: Adopter reported severe behavioral compatibility struggles.")
	elif score < 75.0:
		if random_roll < 12.0:
			emit_signal("adoption_returned", pet, "Returned: Family circumstances shifted suddenly.")
