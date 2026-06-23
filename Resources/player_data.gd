# Resources/player_data.gd
class_name PlayerData
extends Resource

@export_category("Identity Details")
@export var player_name: String = "Alex"
@export var pronouns: String = "They/Them"

@export_category("Visual Customization")
@export var clothing_color: Color = Color(0.18, 0.45, 0.85)

@export_category("Manager Trait Selection")
@export var manager_trait: String = "Green Thumb" # Green Thumb, Negotiator, Vet Apprentice, Hardworker

func get_trait_description() -> String:
	match manager_trait:
		"Green Thumb":
			return "Your bond with plants allows crops to grow 20% faster and withstand dry soil better."
		"Negotiator":
			return "You excel at conversations! Adds 15% bonus revenue to successful adoption fees."
		"Vet Apprentice":
			return "You have steady hands. The target timing zones during surgical operations are 25% larger."
		"Hardworker":
			return "You have incredible stamina. Increases player walk speed and interaction range."
		_:
			return "A humble shelter manager doing their best."
