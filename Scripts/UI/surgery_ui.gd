extends Control

@export_category("Required Scene Assets")
@export var doctor_skill_slider: HSlider
@export var surgeon_spec_lbl: Label
@export var surgical_procedure_btn: Button
@export var medical_supplies_check: CheckBox
@export var result_feedback_lbl: Label

# Cached pet reference currently being treated
var active_pet_node: CharacterBody2D = null

func _ready() -> void:
	UIManager.register_modular_menu("veterinary", self)
	
	surgical_procedure_btn.pressed.connect(_on_surgery_triggered)
	doctor_skill_slider.value_changed.connect(_on_skill_changed)
	
	_on_skill_changed(doctor_skill_slider.value)

func set_target_patient(pet_character: CharacterBody2D) -> void:
	active_pet_node = pet_character
	result_feedback_lbl.text = "Diagnostics: Ready to operate."

func _on_skill_changed(val: float) -> void:
	surgeon_spec_lbl.text = "Surgeon Licensing Factor: " + str(val) + "% Qualification Rating"

func _on_surgery_triggered() -> void:
	if not active_pet_node:
		result_feedback_lbl.text = "Alert! Clean medical table: No pet patient loaded."
		return
		
	var health_comp = active_pet_node.get_node_or_null("HealthComponent") as HealthComponent
	if not health_comp:
		result_feedback_lbl.text = "Diagnostics error: Missing HealthComponent on patient."
		return
		
	var key_supplies_present: bool = medical_supplies_check.button_pressed
	var doc_rating: float = doctor_skill_slider.value / 100.0
	
	# Execute procedure math inside the pet's Health component
	var success: bool = health_comp.perform_medical_procedure(doc_rating, key_supplies_present)
	
	if success:
		result_feedback_lbl.text = "Procedure COMPLETED successfully! Chronic disease fully eradicated."
		# Release patient
		active_pet_node = null
	else:
		result_feedback_lbl.text = "CRITICAL FAILURE: Sudden postoperative hemorrhage! Patient expired."
		active_pet_node = null
