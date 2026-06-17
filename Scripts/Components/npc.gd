class_name NPC
extends Entity

@export var adopter_profile: AdopterProfile


func _initialize_entity() -> void:
	data_profile = adopter_profile
