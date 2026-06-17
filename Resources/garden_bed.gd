class_name GardenBed
extends Resource

@export_group("Crop Details")
@export var seed_type: String = "Empty" # Empty, Catnip, Beets, Chamomile
@export_range(0.0, 100.0) var soil_moisture: float = 50.0
@export_range(0.0, 1.0) var growth_ratio: float = 0.0 # 1.0 is mature

@export_group("Productivity")
@export var is_harvestable: bool = false
@export var quantity_yield: int = 0

func water_bed(amount: float) -> void:
	soil_moisture = clampf(soil_moisture + amount, 0.0, 100.0)

func step_growth_simulation(delta_hours: float) -> void:
	if seed_type == "Empty":
		return
		
	# Moisture naturally evaporates over time
	soil_moisture = clampf(soil_moisture - 2.5 * delta_hours, 0.0, 100.0)
	
	# Growth occurs if moisture is optimal (between 25% and 85%)
	if soil_moisture >= 25.0 and soil_moisture <= 85.0:
		growth_ratio = clampf(growth_ratio + 0.04 * delta_hours, 0.0, 1.0)
		if growth_ratio >= 1.0:
			is_harvestable = true
			quantity_yield = randi_range(2, 4)
	elif soil_moisture > 85.0:
		# Waterlogged seed decay hazard
		growth_ratio = clampf(growth_ratio - 0.01 * delta_hours, 0.0, 1.0)
