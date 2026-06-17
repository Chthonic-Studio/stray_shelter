class_name PetData
extends Resource

enum Species { DOG, CAT, RABBIT, REPTILE, BIRD, OTHER }
enum Temperament { ANXIOUS, PLAYFUL, GLUTTONOUS, INDEPENDENT, CALM }

@export_group("Identity")
@export var id: String = ""
@export var pet_name: String = "Unnamed Pet"
@export var species: Species = Species.DOG
@export var breed: String = "Mixed"
@export var age_months: float = 12.0
@export var is_rescued: bool = true

@export_group("Temperament")
@export var temperament: Temperament = Temperament.CALM
@export var history_logs: Array[String] = []

@export_group("Dynamic Needs")
@export_range(0.0, 100.0) var hunger: float = 30.0
@export_range(0.0, 100.0) var energy: float = 95.0
@export_range(0.0, 100.0) var enrichment: float = 50.0
@export_range(0.0, 100.0) var affection: float = 60.0

@export_group("Medical State")
@export var is_sick: bool = false
@export var disease_name: String = ""
@export_range(0.0, 1.0) var severity: float = 0.0 # 1.0 is critical
@export var clinical_history: Array[String] = []
@export var dietary_needs: Array[String] = []

func _init() -> void:
	if id == "":
		id = str(PetManager.pet_id_counter)
		PetManager.increase_id_counter()

func apply_time_tick(delta_days: float) -> void:
	age_months += delta_days
	hunger = clampf(hunger + 8.5 * delta_days, 0.0, 100.0)
	energy = clampf(energy - 5.0 * delta_days, 0.0, 100.0)
	enrichment = clampf(enrichment - 6.0 * delta_days, 0.0, 100.0)
	affection = clampf(affection - 4.0 * delta_days, 0.0, 100.0)
	
	if is_sick:
		severity = clampf(severity + 0.02 * delta_days, 0.0, 1.0)
