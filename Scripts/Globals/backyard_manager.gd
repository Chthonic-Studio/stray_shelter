extends Node

@export var bed_state: GardenBed
# Soil hydration depletion rate 
@export var moisture_degradation_rate: float = 0.1

var garden_patches: Dictionary = {} # index: GardenBedState

func initialize_garden_beds(beds_count: int) -> void:
	for i in range(beds_count):
		var bed = GardenBed.new()
		bed.seed_type = "Empty"
		bed.stage = 0.0
		bed.soil_moisture = 50.0
		bed.organic_yield = 0
		garden_patches[i] = bed

func process_farming_ticks(delta: float) -> void:
	for bed_idx in garden_patches:
		var bed: GardenBed = garden_patches[bed_idx]
		if bed.seed_type == "Empty": continue
		
		# Slowly lower soil moisture levels
		bed.soil_moisture = clampf(bed.soil_moisture - moisture_degradation_rate * delta * 5.0, 0.0, 100.0)
		
		# Growing logic dependent on moisture
		if bed.soil_moisture > 20.0:
			bed.stage = clampf(bed.stage + 0.05 * delta, 0.0, 3.0)
			
		# Damp weed overgrow chances if heavily watered
		if bed.soil_moisture > 85.0:
			bed.organic_yield = clampi(bed.organic_yield - 1, 0, 10)

func water_bed(bed_idx: int) -> void:
	if garden_patches.has(bed_idx):
		var bed: GardenBed = garden_patches[bed_idx]
		bed.soil_moisture = clampf(bed.soil_moisture + 40.0, 0.0, 100.0)

# Enrichment Crafting Panel
# Creating Toys triggers items needed for Pet Play configurations
func craft_enrichment_toy(wood_required: int, thread_required: int, inv_materials: Dictionary) -> Dictionary:
	if inv_materials.get("wood", 0) >= wood_required and inv_materials.get("thread", 0) >= thread_required:
		inv_materials["wood"] -= wood_required
		inv_materials["thread"] -= thread_required
		
		# Return crafted Toy and residual inventories
		return {
			"success": true,
			"toy_type": "Fleece Chew Knot" if thread_required > 3 else "Wooden Puzzle Roller",
			"enrichment_value": 35.0, # boosts pet enrichment vitals
			"updated_inventory": inv_materials
		}
	return { "success": false, "reason": "Insufficient crafting materials." }
