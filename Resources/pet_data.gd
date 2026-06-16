class_name PetData
extends Resource

enum Species { DOG, CAT, RABBIT, REPTILE, BIRD, OTHER }
enum Temperament { ANXIOUS, PLAYFUL, GLUTTONOUS, INDEPENDENT, CALM }

@export_category("Identity")
@export var id: String = ""
@export var pet_name: String = "Unnamed Pet"
@export var species: Species = Species.DOG
@export var breed: String = "Mixed"
@export var age_months: float = 12.0
@export var is_rescued: bool = true

@export_category("Atmosphere & Personality")
@export var temperament: Temperament = Temperament.CALM
@export var memory_history: String = "Found wandering near the forest."

@export_category("Needs & Vitals")
@export_range(0.0, 100.0) var hunger: float = 30.0
@export_range(0.0, 100.0) var energy: float = 90.0
@export_range(0.0, 100.0) var enrichment: float = 50.0
@export_range(0.0, 100.0) var affection: float = 60.0

@export_category("Medical Specs")
@export var is_sick: bool = false
@export var sickness_type: String = ""
@export var severity: float = 0.0 # 0.0 to 1.0 (deadly)
@export var dietary_needs: Array[String] = []
@export var clinical_history: Array[String] = []

func _init() -> void:
	if id == "":
		id = str(PetManager.pet_id_counter)
		PetManager.increase_id_counter()

func age_one_frame(delta_days: float) -> void:
	age_months += delta_days
	# Check for aging events (elderly stats, natural expiration checks)
