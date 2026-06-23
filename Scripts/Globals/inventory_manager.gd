# Scripts/Globals/InventoryManager.gd
extends Node

# AutoLoad registered in project as: InventoryManager
signal player_inventory_updated()
signal shelter_storage_updated()

@export var max_player_slots: int = 12
var player_inventory: Array[Dictionary] = []
var shelter_storage: Dictionary = {}

func _ready() -> void:
	add_to_player_inventory("seed_catnip", "Catnip Seeds", 4, "Seeds")
	add_to_player_inventory("seed_chamomile", "Chamomile Seeds", 3, "Seeds")
	add_to_shelter_storage("medical_bandage", "Sterile Bandage", 8, "Medicine")
	add_to_shelter_storage("medical_ointment", "Soothing Herb Salve", 4, "Medicine")
	add_to_shelter_storage("dry_food_bag", "Premium Dog Food", 6, "Food")
	add_to_shelter_storage("fish_can", "Tuna Salmon Blend", 6, "Food")

func add_to_player_inventory(item_id: String, item_name: String, quantity: int = 1, category: String = "General") -> bool:
	for item in player_inventory:
		if item["id"] == item_id:
			item["quantity"] += quantity
			player_inventory_updated.emit()
			return true
	if player_inventory.size() >= max_player_slots:
		return false
	player_inventory.append({
		"id": item_id,
		"name": item_name,
		"quantity": quantity,
		"category": category
	})
	player_inventory_updated.emit()
	return true

func remove_from_player_inventory(item_id: String, quantity: int = 1) -> bool:
	for i in range(player_inventory.size()):
		var item = player_inventory[i]
		if item["id"] == item_id:
			if item["quantity"] < quantity: return false
			item["quantity"] -= quantity
			if item["quantity"] <= 0:
				player_inventory.remove_at(i)
			player_inventory_updated.emit()
			return true
	return false

func add_to_shelter_storage(item_id: String, item_name: String, quantity: int = 1, category: String = "General") -> void:
	if shelter_storage.has(item_id):
		shelter_storage[item_id]["quantity"] += quantity
	else:
		shelter_storage[item_id] = {
			"name": item_name,
			"quantity": quantity,
			"category": category
		}
	shelter_storage_updated.emit()
