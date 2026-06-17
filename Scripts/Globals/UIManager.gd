extends Node

# AutoLoad registered in project as: UIManager
signal overlay_window_opened(key_id: String)
signal overlay_window_closed(key_id: String)

var open_screen_overlays: Dictionary = {} # contains [String key_id]: Control scene Node

func register_modular_menu(key_id: String, overlay_node: Control) -> void:
	open_screen_overlays[key_id] = overlay_node
	overlay_node.visible = false # default closed

func toggle_menu_window(key_id: String) -> void:
	if not open_screen_overlays.has(key_id):
		push_error("UIManager: Screen overlay key not registered: " + key_id)
		return
		
	var target_screen: Control = open_screen_overlays[key_id]
	if target_screen.visible:
		dismiss_overlay(key_id, target_screen)
	else:
		present_overlay(key_id, target_screen)

func present_overlay(key_id: String, screen: Control) -> void:
	screen.visible = true
	get_tree().paused = true # Pauses physics simulation loops beautifully
	
	# Trigger Tween elastic scale entry
	var tween = screen.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	screen.scale = Vector2(0.85, 0.85)
	screen.pivot_offset = screen.size / 2.0
	tween.tween_property(screen, "scale", Vector2.ONE, 0.18)
	
	overlay_window_opened.emit(key_id)

func dismiss_overlay(key_id: String, screen: Control) -> void:
	var tween = screen.create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(screen, "scale", Vector2(0.9, 0.9), 0.12)
	tween.tween_callback(func():
		screen.visible = false
		get_tree().paused = false # Resumes full movement mechanics
		overlay_window_closed.emit(key_id)
	)

func close_all_screens() -> void:
	for key in open_screen_overlays.keys():
		var node = open_screen_overlays[key]
		if node and node.visible:
			dismiss_overlay(key, node)
