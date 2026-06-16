class_name WorkerStats
extends Resource

enum EmployeeRole { CARETAKER, VETERINARIAN, CLEANER, RECEPTIONIST }
enum PersonalityTrait { DILIGENT, GRUMPY, COMPASSIONATE, LAZY }

@export var employee_id: String = ""
@export var employee_name: String = "John Doe"
@export var role: EmployeeRole = EmployeeRole.CARETAKER
@export var personality: PersonalityTrait = PersonalityTrait.DILIGENT

@export_category("Financials")
@export var daily_wage: float = 120.0
@export var hiring_bonus: float = 300.0

@export_category("Attributes & Work Rating")
@export_range(0.0, 1.0) var qualification: float = 0.70
@export_range(0.0, 1.0) var satisfaction: float = 0.85
@export_range(0.0, 1.0) var fatigue: float = 0.0

@export var performance_score: float = 0.8

func process_shift_completed() -> float:
	# Fatigue accumulates during work shifts
	fatigue = clampf(fatigue + 0.15, 0.0, 1.0)
	
	# Diligent workers rate stays high, grumpy or tired drops
	var energy_multiplier: float = (1.0 - fatigue)
	var work_efficiency: float = qualification * satisfaction * energy_multiplier
	
	if personality == PersonalityTrait.LAZY:
		work_efficiency *= 0.75
	elif personality == PersonalityTrait.COMPASSIONATE:
		# Boosts pet bonding satisfaction
		work_efficiency *= 1.10
		
	return clampf(work_efficiency, 0.0, 1.0)

func apply_performance_review(rating: float) -> void:
	performance_score = clampf((performance_score + rating) / 2.0, 0.0, 1.0)
	# Dissatisfied underpaid helpers may resign
	if performance_score < 0.35 and satisfaction < 0.30:
		resign()

func resign() -> void:
	# Workers trigger notification and leave the workforce list
	pass
