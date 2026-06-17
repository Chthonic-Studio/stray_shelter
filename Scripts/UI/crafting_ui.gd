extends Control

@export_category("Asset Elements")
@export var raw_materials_lbl: Label
@export var assemble_chew_btn: Button
@export var assemble_roller_btn: Button
@export var log_alert_lbl: Label

func _ready() -> void:
	UIManager.register_modular_menu("crafting", self)
	
	assemble_chew_btn.pressed.connect(_on_craft_chew_pressed)
	assemble_roller_btn.pressed.connect(_on_craft_roller_pressed)
	
	refresh_workbench_vitals()

func refresh_workbench_vitals() -> void:
	raw_materials_lbl.text = "Resources Stockpile:  [Timber Wood: " + str(BackyardManager.raw_wood) + "]  [String Thread: " + str(BackyardManager.raw_string_cord) + "]"
	
	# Enable/Disable buttons based on material parameters
	assemble_chew_btn.disabled = BackyardManager.raw_string_cord < 4
	assemble_roller_btn.disabled = BackyardManager.raw_wood < 3

func _on_craft_chew_pressed() -> void:
	var ok = BackyardManager.craft_toy(0, 4, "Fleece Chew Knot")
	if ok:
		log_alert_lbl.text = "Successfully created Fleece Chew Knot (+30 Enrichment)!"
	else:
		log_alert_lbl.text = "Failed! Insufficient cords."
	refresh_workbench_vitals()

func _on_craft_roller_pressed() -> void:
	var ok = BackyardManager.craft_toy(3, 0, "Wooden Puzzle Roller")
	if ok:
		log_alert_lbl.text = "Successfully created Wooden Puzzle Roller (+35 Play)!"
	else:
		log_alert_lbl.text = "Failed! Insufficient lumber."
	refresh_workbench_vitals()
