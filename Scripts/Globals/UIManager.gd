extends Node

@export_category("UI Screens Mapping")
@export var shelter_overview_panel: Control
@export var backyard_garden_panel: Control
@export var veterinary_surgery_panel: Control
@export var staffing_payroll_panel: Control

var active_ui_window: Control = null

func _ready() -> void:
	# Rigorously close panels at startup to clean viewports
	close_all_ui_panels()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("toggle_menu"):
		# Catch ESC or TAB to clear any active panels safely first
		if active_ui_window:
			dismiss_window(active_ui_window)
			get_viewport().set_input_as_handled()

func toggle_window(window_key: String) -> void:
	var target_screen: Control = null
	
	match window_key:
		"garden":
			target_screen = backyard_garden_panel
		"veterinary":
			target_screen = veterinary_surgery_panel
		"staff_payroll":
			target_screen = staffing_payroll_panel
		"overview":
			target_screen = shelter_overview_panel
			
	if not target_screen: return
	
	if active_ui_window == target_screen:
		dismiss_window(target_screen)
	else:
		if active_ui_window:
			dismiss_window(active_ui_window)
		present_window(target_screen)

func present_window(panel: Control) -> void:
	panel.visible = true
	active_ui_window = panel
	
	# Pause underlying map interactions so the player cannot run while menu is open
	get_tree().paused = true
	
	# Beautiful scale expansion visual transition (mocked via code)
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	panel.scale = Vector2(0.85, 0.85)
	panel.pivot_offset = panel.size / 2.0
	tween.tween_property(panel, "scale", Vector2.ONE, 0.2)

func dismiss_window(panel: Control) -> void:
	var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(panel, "scale", Vector2(0.9, 0.9), 0.12)
	tween.tween_callback(func():
		panel.visible = false
		if active_ui_window == panel:
			active_ui_window = null
		
		# Let the simulation continue running
		get_tree().paused = false
	)

func close_all_ui_panels() -> void:
	if shelter_overview_panel: shelter_overview_panel.visible = false
	if backyard_garden_panel: backyard_garden_panel.visible = false
	if veterinary_surgery_panel: veterinary_surgery_panel.visible = false
	if staffing_payroll_panel: staffing_payroll_panel.visible = false
	active_ui_window = null
