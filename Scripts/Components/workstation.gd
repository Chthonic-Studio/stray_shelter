extends Area2D
class_name Workstation

# Attached to Workstation (Area2D) with a CollisionShape2D and Sprite2D.
# Collision mask Layer 1 for players and workers.

signal player_arrived()
signal player_departed()
signal worker_arrived(worker_node: Node)
signal worker_departed()

@export_category("Workstation Settings")
@export var station_name: String = "FrontDesk" # FrontDesk, ClinicTable, MopCloset
@export var require_interaction_button: bool = true

var is_occupied_by_player: bool = false
var occupied_worker_node: Node = null

func _ready() -> void:
	# Register this station in the Global JobManager autoload
	if has_node("/root/JobManager"):
		get_node("/root/JobManager").register_workstation(station_name, self)
		
	# Connect overlap detection signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

# Invoked directly by the PlayerController's InteractComponent or RayCast
func on_interacted(player_node: CharacterBody2D) -> void:
	if not is_occupied_by_player:
		is_occupied_by_player = true
		player_arrived.emit()
		
		# Notify JobManager to kick the assigned worker
		if has_node("/root/JobManager"):
			get_node("/root/JobManager").on_player_entered_workstation(station_name)
			
		open_station_interface()

# Call when Player leaves or closes the station UI
func end_player_interaction() -> void:
	if is_occupied_by_player:
		is_occupied_by_player = false
		player_departed.emit()
		
		# Notify JobManager to restore the assigned worker
		if has_node("/root/JobManager"):
			get_node("/root/JobManager").on_player_exited_workstation(station_name)

func open_station_interface() -> void:
	# Trigger the matching interface screen in UIManager
	if has_node("/root/UIManager"):
		match station_name:
			"FrontDesk":
				get_node("/root/UIManager").toggle_menu_window("front_desk")
			"ClinicTable":
				get_node("/root/UIManager").toggle_menu_window("veterinary")
			"MopCloset":
				get_node("/root/UIManager").toggle_menu_window("crafting")

func _on_body_entered(body: Node2D) -> void:
	# Handle non-button entry triggers for secondary stations (like cleaning areas)
	if body.is_in_group("player") and not require_interaction_button:
		on_interacted(body)
	elif body.has_node("WorkerStats") or body.has_method("notify_station_occupied"):
		# It is an AI Worker!
		occupied_worker_node = body
		worker_arrived.emit(body)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and not require_interaction_button:
		end_player_interaction()
	elif body == occupied_worker_node:
		occupied_worker_node = null
		worker_departed.emit()
