class_name AdopterProfile
extends Resource

@export_group("Adopter Bios")
@export var adopter_name: String = "Jane Doe"
@export var housing_type: String = "Apartment" # Apartment, House, Fenced_Yard
@export var is_child_friendly: bool = true
@export_range(0.0, 1.0) var patience_index: float = 0.75
@export var monthly_income: float = 2400.0

@export_group("Preferences")
@export var preferred_species: int = 0 # Match with PetData.Species DOG
@export var preferred_temperament: int = 1 # Match with PetData.Temperament PLAYFUL
@export var max_acceptable_age_months: float = 60.0
@export var willing_to_treat_sick: bool = false
