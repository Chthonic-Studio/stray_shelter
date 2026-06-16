class_name AdopterProfile
extends Resource

@export var adopter_name: String = ""
@export_enum("Apartment", "House", "Yard") var housing_type_size: String = "Apartment"
@export var child_friendly: bool = false
@export_range(0.0, 1.0) var patience_index: float = 0.5
@export var preferred_temperament: PetData.Temperament
@export var historical_income: float = 0.0
