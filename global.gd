extends Node

var dragon: Dragon = null


func nearest_segment_or_head(to_pos: Vector2) -> Node2D:
	if not dragon:
		return null
	
	var nearest = dragon.head
	var nearest_d = dragon.head.global_position.distance_squared_to(to_pos)
	for s in dragon.segments():
		var new_d = s.global_position.distance_squared_to(to_pos)
		if nearest_d > new_d:
			nearest_d = new_d
			nearest = s
	
	return nearest
