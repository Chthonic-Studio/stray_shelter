class_name Pet
extends Entity

@export var pet_data: PetData

func _initialize_entity() -> void:
	data_profile = pet_data
	# Initialize unique pet behaviors or speed overrides here
