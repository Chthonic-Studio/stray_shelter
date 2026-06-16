class_name GardenBed
extends Resource

@export var seed_type: String = ""
@export_range(0.0, 3.0) var stage: float = 0.0
@export_range(0.0, 100.0) var soil_moisture: float = 100.0
@export var organic_yield: int = 0
