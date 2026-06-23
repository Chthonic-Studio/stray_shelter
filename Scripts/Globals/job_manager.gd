# Scripts/Globals/JobManager.gd
extends Node

# AutoLoad registered in project as: JobManager
signal workstation_registered(station_name: String, station_node: Node)
signal worker_assigned(worker_node: Node, station_name: String)
signal worker_relieved(worker_node: Node, station_name: String)
signal player_occupied_station(station_name: String)
signal player_vacated_station(station_name: String)

var workstations: Dictionary = {}
var assigned_workers: Dictionary = {}
var idle_workers: Array[Node] = []

func register_workstation(station_name: String, station_node: Node) -> void:
	workstations[station_name] = station_node
	workstation_registered.emit(station_name, station_node)

func assign_worker_to_station(worker_node: Node, station_name: String) -> bool:
	if not workstations.has(station_name):
		push_error("JobManager: Attempted to assign worker to unregistered station: " + station_name)
		return false
		
	if assigned_workers.has(station_name) and assigned_workers[station_name] != null:
		relieve_worker_from_station(assigned_workers[station_name], station_name)
		
	if idle_workers.has(worker_node):
		idle_workers.erase(worker_node)
		
	for other_station in assigned_workers.keys():
		if assigned_workers[other_station] == worker_node:
			assigned_workers.erase(other_station)
			
	assigned_workers[station_name] = worker_node
	worker_assigned.emit(worker_node, station_name)
	
	var station_node = workstations[station_name]
	if station_node and station_node.is_occupied_by_player:
		kick_worker_to_fallback(worker_node, station_name)
		
	return true

func relieve_worker_from_station(worker_node: Node, station_name: String) -> void:
	if assigned_workers.has(station_name) and assigned_workers[station_name] == worker_node:
		assigned_workers.erase(station_name)
		if not idle_workers.has(worker_node):
			idle_workers.append(worker_node)
		worker_relieved.emit(worker_node, station_name)

func on_player_entered_workstation(station_name: String) -> void:
	player_occupied_station.emit(station_name)
	if assigned_workers.has(station_name) and assigned_workers[station_name] != null:
		var worker = assigned_workers[station_name]
		kick_worker_to_fallback(worker, station_name)

func on_player_exited_workstation(station_name: String) -> void:
	player_vacated_station.emit(station_name)
	if assigned_workers.has(station_name) and assigned_workers[station_name] != null:
		var worker = assigned_workers[station_name]
		recall_worker_to_duty(worker, station_name)

func kick_worker_to_fallback(worker_node: Node, station_name: String) -> void:
	if worker_node.has_method("notify_station_occupied"):
		worker_node.notify_station_occupied(station_name, true)

func recall_worker_to_duty(worker_node: Node, station_name: String) -> void:
	if worker_node.has_method("notify_station_occupied"):
		worker_node.notify_station_occupied(station_name, false)

func register_worker_as_idle(worker_node: Node) -> void:
	if not idle_workers.has(worker_node):
		var is_assigned = false
		for station in assigned_workers.keys():
			if assigned_workers[station] == worker_node:
				is_assigned = true
				break
		if not is_assigned:
			idle_workers.append(worker_node)

func unregister_worker(worker_node: Node) -> void:
	if idle_workers.has(worker_node):
		idle_workers.erase(worker_node)
		
	for station in assigned_workers.keys():
		if assigned_workers[station] == worker_node:
			assigned_workers.erase(station)
			worker_relieved.emit(worker_node, station)

func get_assigned_worker(station_name: String) -> Node:
	if assigned_workers.has(station_name):
		return assigned_workers[station_name]
	return null
