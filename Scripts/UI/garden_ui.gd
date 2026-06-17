extends Control

@export_category("UI Nodes Links")
@export var status_title: Label
@export var moisture_bar: ProgressBar
@export var wood_count_label: Label
@export var plant_crop_btn: Button
@export var water_soil_btn: Button

var selected_garden_bed_idx: int = 0

func _ready() -> void:
	# Register self with global UI dispatcher
	UIManager.register_modular_menu("garden", self)
	
	# Connect local button interaction signals safely
	water_soil_btn.pressed.connect(_on_water_pressed)
	plant_crop_btn.pressed.connect(_on_plant_pressed)
	
	# Connect to BackyardManager signal update
	BackyardManager.garden_updated.connect(refresh_garden_interface)
	
	refresh_garden_interface()

func refresh_garden_interface() -> void:
	var bed: GardenBed = BackyardManager.garden_database[selected_garden_bed_idx]
	if not bed: return
	
	# Set Labels
	status_title.text = "Garden patch #" + str(selected_garden_bed_idx) + " - Current crop: " + bed.seed_type
	moisture_bar.value = bed.soil_moisture
	wood_count_label.text = "Shed Wood Timber Stock: " + str(BackyardManager.raw_wood) + " units"
	
	if bed.is_harvestable:
		plant_crop_btn.text = "HARVEST CROP! (Qty: " + str(bed.quantity_yield) + ")"
		plant_crop_btn.disabled = false
	else:
		if bed.seed_type == "Empty":
			plant_crop_btn.text = "Plant Chamomile Seed 🌱"
			plant_crop_btn.disabled = false
		else:
			plant_crop_btn.text = "Growing... (" + str(roundf(bed.growth_ratio * 100)) + "%)"
			plant_crop_btn.disabled = true

func _on_water_pressed() -> void:
	# Water garden bed via backyard Singletons
	BackyardManager.water_patch_index(selected_garden_bed_idx)

func _on_plant_pressed() -> void:
	var bed: GardenBed = BackyardManager.garden_database[selected_garden_bed_idx]
	if bed.is_harvestable:
		BackyardManager.harvest_patch_index(selected_garden_bed_idx)
	else:
		if bed.seed_type == "Empty":
			BackyardManager.plant_crop_seed(selected_garden_bed_idx, "Chamomile")
