class_name HealthComponent
extends Node

signal death_triggered(reason: String)
signal sickness_healed()

@onready var host_entity: CharacterBody2D = get_parent()

# Sickness settings
var current_disease: String = ""
var disease_potency: float = 0.0 # severity increase per minute
var medical_urgency: float = 0.0 # 0 to 100

func _process(delta: float) -> void:
	var stats = host_entity.get_node_or_null("PetStats") as Node
	if not stats or not stats.data: return
	var pet_data: PetData = stats.data
	
	# Aging Mechanics & Natural Expiration Sickness Triggering
	if pet_data.age_months > 160.0: # Senior / Elderly limit (approx 13 yrs)
		# Accumulate chronic wear-and-tear risks
		if randf() < 0.00001 * (pet_data.age_months - 160.0):
			contract_disease("Chronic Renal Sickness", 0.05)
			
	if pet_data.is_sick:
		vitals_degradation(pet_data, delta)

func contract_disease(disease_name: String, severity_rate: float) -> void:
	var stats = host_entity.get_node_or_null("PetStats")
	if not stats: return
	var pet_data: PetData = stats.data
	
	current_disease = disease_name
	disease_potency = severity_rate
	pet_data.is_sick = true
	pet_data.clinical_history.append("Diagnosed with " + disease_name)

func vitals_degradation(pet_data: PetData, delta: float) -> void:
	# Degrades health rapidly if left untreated in the shelter
	pet_data.severity = clampf(pet_data.severity + disease_potency * delta * 0.1, 0.0, 100.0)
	pet_data.energy = clampf(pet_data.energy - 5.0 * delta, 0.0, 100.0)
	
	if pet_data.severity >= 100.0:
		expire_pet("Sickness: " + current_disease)

# Veterinary Operation Board (Invoked by Vet Room interactives)
func perform_medical_procedure(vet_qualification: float, critical_supplies_present: bool) -> bool:
	var stats = host_entity.get_node_or_null("PetStats")
	if not stats: return false
	var pet_data: PetData = stats.data
	
	# Procedure Success probability calculation
	var survival_modifier: float = 1.0
	if pet_data.age_months > 140.0:
		survival_modifier -= 0.25 # Elderly risk
	if not critical_supplies_present:
		survival_modifier -= 0.40 # Missing tools risk
		
	# Survival rate calculation: Base on doctor qualification (0.0 to 1.0)
	var base_survival: float = lerp(0.35, 0.98, vet_qualification) * survival_modifier
	var rolls: float = randf()
	
	if rolls > base_survival:
		# Procedure failed!
		expire_pet("Surgical Complication under Anesthesia")
		return false
	else:
		# Success! Heal sickness
		pet_data.is_sick = false
		pet_data.severity = 0.0
		pet_data.clinical_history.append("Successfully operated by Vet.")
		sickness_healed.emit()
		return true

func expire_pet(reason: String) -> void:
	death_triggered.emit(reason)
	# Play custom sad pixel particles, save status, delete pet node
	host_entity.queue_free()
