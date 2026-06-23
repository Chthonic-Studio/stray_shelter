extends Node

signal day_started(day_number: int)
signal time_ticked(hour: int, minute: int)
signal phase_changed(new_phase: String)

signal morning_started()
signal shelter_opened()
signal shelter_closed()
signal overtime_started()
signal forced_sleep_started()

@export_category("Time Configuration")
@export var minutes_per_tick: int = 10
@export var seconds_per_tick: float = 1.0 # Real seconds per in-game tick
@export var starting_day: int = 1
@export var starting_hour: int = 6 # Starts in the Morning at 6:00 AM

# Game state
var current_day: int = 1
var current_hour: int = 6
var current_minute: int = 0
var current_phase: String = "Morning" # Morning, Open, Closed, Overtime, Sleep

var is_paused: bool = false
var tick_timer: float = 0.0

func _ready() -> void:
	current_day = starting_day
	current_hour = starting_hour
	current_minute = 0
	set_phase_by_hour()
	process_mode = PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	if is_paused or get_tree().paused:
		return
		
	tick_timer += delta
	if tick_timer >= seconds_per_tick:
		tick_timer = 0.0
		tick_time()

func tick_time() -> void:
	current_minute += minutes_per_tick
	if current_minute >= 60:
		current_minute = 0
		current_hour += 1
		
		if has_node("/root/BackyardManager"):
			get_node("/root/BackyardManager").tick_farming_simulation(1.0)
			
	if current_hour >= 24:
		current_hour = 0
		current_day += 1
		day_started.emit(current_day)
		
	time_ticked.emit(current_hour, current_minute)
	check_phase_transitions()

func check_phase_transitions() -> void:
	var old_phase = current_phase
	set_phase_by_hour()
	
	if current_phase != old_phase:
		phase_changed.emit(current_phase)
		match current_phase:
			"Morning":
				morning_started.emit()
			"Open":
				shelter_opened.emit()
			"Closed":
				shelter_closed.emit()
			"Overtime":
				overtime_started.emit()
			"Sleep":
				forced_sleep_started.emit()
				trigger_daily_summary()

func set_phase_by_hour() -> void:
	if current_hour >= 6 and current_hour < 8:
		current_phase = "Morning"
	elif current_hour >= 8 and current_hour < 18:
		current_phase = "Open"
	elif current_hour >= 18 and current_hour < 19:
		current_phase = "Closed"
	elif current_hour >= 19 and current_hour < 22:
		current_phase = "Overtime"
	else:
		current_phase = "Sleep"

func force_next_day() -> void:
	current_hour = 6
	current_minute = 0
	current_day += 1
	current_phase = "Morning"
	tick_timer = 0.0
	day_started.emit(current_day)
	morning_started.emit()
	phase_changed.emit(current_phase)
	time_ticked.emit(current_hour, current_minute)

func pause_clock() -> void:
	is_paused = true

func resume_clock() -> void:
	is_paused = false

func trigger_daily_summary() -> void:
	if has_node("/root/EconomyManager"):
		get_node("/root/EconomyManager").process_end_of_day()
	if has_node("/root/UIManager"):
		get_node("/root/UIManager").toggle_menu_window("daily_summary")

func get_time_string() -> String:
	var am_pm = "AM" if current_hour < 12 else "PM"
	var display_hour = current_hour % 12
	if display_hour == 0:
		display_hour = 12
	return "%02d:%02d %s" % [display_hour, current_minute, am_pm]
