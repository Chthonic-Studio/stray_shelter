extends Node

# AutoLoad name registers as: BackyardManager
signal garden_updated()
signal crop_ripe(index: int, crop_type: String)

@export var max_beds_count: int = 6
var garden_database: Dictionary = {} # contains [int index]: GardenBed resource

@export_group("Raw Inventories")
var raw_wood: int = 15
var raw_string_cord: int = 12
var harvested_herbs: Dictionary = { "Catnip": 0, "Beets": 0, "Chamomile": 0 }

func _ready() -> void:
	initialize_backyard_patches()

func initialize_backyard_patches() -> void:
	for i in range(max_beds_count):
		var bed = GardenBed.new()
		bed.seed_type = "Empty"
		bed.soil_moisture = 45.0
		bed.growth_ratio = 0.0
		garden_database[i] = bed

func plant_crop_seed(index: int, type: String) -> void:
	if garden_database.has(index):
		var bed: GardenBed = garden_database[index]
		bed.seed_type = type
		bed.growth_ratio = 0.0
		bed.soil_moisture = 60.0 # pre-watered on plant
		bed.is_harvestable = false
		emit_signal("garden_updated")

func water_patch_index(index: int) -> void:
	if garden_database.has(index):
		var bed: GardenBed = garden_database[index]
		bed.water_bed(35.0)
		emit_signal("garden_updated")

func tick_farming_simulation(delta_hours: float) -> void:
	for key in garden_database.keys():
		var bed: GardenBed = garden_database[key]
		if bed.seed_type == "Empty":
			continue
			
		var was_ripe = bed.is_harvestable
		bed.step_growth_simulation(delta_hours)
		
		if bed.is_harvestable and not was_ripe:
			emit_signal("crop_ripe", key, bed.seed_type)
			
	emit_signal("garden_updated")

func harvest_patch_index(index: int) -> bool:
	if not garden_database.has(index): return false
	var bed: GardenBed = garden_database[index]
	if not bed.is_harvestable: return false
	
	var yield_val = bed.quantity_yield
	if harvested_herbs.has(bed.seed_type):
		harvested_herbs[bed.seed_type] += yield_val
	else:
		harvested_herbs[bed.seed_type] = yield_val
		
	# Reset Bed
	bed.seed_type = "Empty"
	bed.growth_ratio = 0.0
	bed.is_harvestable = false
	bed.quantity_yield = 0
	
	emit_signal("garden_updated")
	return true

func craft_toy(wood_spent: int, thread_spent: int, toy_product: String) -> bool:
	if raw_wood >= wood_spent and raw_string_cord >= thread_spent:
		raw_wood -= wood_spent
		raw_string_cord -= thread_spent
		return true
	return false
