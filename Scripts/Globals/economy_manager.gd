# Scripts/Globals/EconomyManager.gd
extends Node

# AutoLoad registered in project as: EconomyManager
signal balance_changed(new_balance: float)
signal transaction_logged(amount: float, category: String, label: String, is_income: bool)
signal bankrupt()

@export_category("Starting Budget")
@export var starting_funds: float = 1200.0
@export var daily_shelter_maintenance: float = 45.0

var current_funds: float = 1200.0
var daily_income_total: float = 0.0
var daily_expense_total: float = 0.0
var renown_score: float = 50.0
var transaction_log: Array[Dictionary] = []

func _ready() -> void:
	current_funds = starting_funds
	balance_changed.emit(current_funds)

func add_funds(amount: float, label: String, category: String = "General") -> void:
	if amount <= 0.0: return
	current_funds += amount
	daily_income_total += amount
	_log_transaction(amount, label, category, true)

func spend_funds(amount: float, label: String, category: String = "General") -> bool:
	if amount <= 0.0: return true
	if current_funds < amount:
		current_funds -= amount
		daily_expense_total += amount
		_log_transaction(amount, label, category, false)
		if current_funds < -300.0:
			bankrupt.emit()
		return false
	current_funds -= amount
	daily_expense_total += amount
	_log_transaction(amount, label, category, false)
	return true

func _log_transaction(amount: float, label: String, category: String, is_income: bool) -> void:
	var log_entry = {
		"day": TimeManager.current_day if has_node("/root/TimeManager") else 1,
		"time": TimeManager.get_time_string() if has_node("/root/TimeManager") else "00:00 AM",
		"amount": amount,
		"label": label,
		"category": category,
		"is_income": is_income
	}
	transaction_log.append(log_entry)
	transaction_logged.emit(amount, category, label, is_income)
	balance_changed.emit(current_funds)

func increase_renown(amount: float) -> void:
	renown_score = clampf(renown_score + amount, 0.0, 100.0)

func decrease_renown(amount: float) -> void:
	renown_score = clampf(renown_score - amount, 0.0, 100.0)

func process_end_of_day() -> void:
	var worker_wages: float = 0.0
	if has_node("/root/JobManager"):
		var job_mgr = get_node("/root/JobManager")
		var processed: Array[Node] = []
		for station in job_mgr.assigned_workers.keys():
			var w = job_mgr.assigned_workers[station]
			if w and not processed.has(w): processed.append(w)
		for w in job_mgr.idle_workers:
			if w and not processed.has(w): processed.append(w)
			
		for w in processed:
			if "worker_data" in w and w.worker_data:
				worker_wages += w.worker_data.daily_wage
				
	if worker_wages > 0:
		spend_funds(worker_wages, "Staff Salaries", "Payroll")
		
	spend_funds(daily_shelter_maintenance, "Shelter Utility & Rent", "Maintenance")
	
	var base_donation: float = randf_range(40.0, 80.0)
	var renown_bonus: float = base_donation * (renown_score / 50.0)
	var final_donation: float = snappedf(base_donation + renown_bonus, 0.01)
	add_funds(final_donation, "Public Community Donations", "Donations")
	
	daily_income_total = 0.0
	daily_expense_total = 0.0
