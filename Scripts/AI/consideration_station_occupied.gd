# Scripts/AI/consideration_station_occupied.gd
extends UtilityConsideration

func evaluate_consideration(entity: CharacterBody2D) -> float:
	if not has_node("/root/JobManager"): return 1.0
	var job_mgr = get_node("/root/JobManager")
	var target_station_name = ""
	for station in job_mgr.assigned_workers.keys():
		if job_mgr.assigned_workers[station] == entity:
			target_station_name = station
			break
	if target_station_name == "": return 0.0
	var s_node = job_mgr.workstations.get(target_station_name)
	if not s_node: return 0.0
	return 0.0 if s_node.is_occupied_by_player else 1.0
