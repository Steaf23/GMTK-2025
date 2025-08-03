class_name Dragon
extends Node2D

signal player_died()

@export var follow_distance: int = 15
@export var speed: int = 120
@export var speed_mult: float = 1.0

@export var speed_curve: Curve

@onready var head: CharacterBody2D = $Head

var strangle_points: PackedVector2Array = []

# array of arrays, keeping track of segments that are part of a possible constriction.
var constriction_windows: ConstrictionManager = ConstrictionManager.new()

var started: bool = false

func _ready() -> void:
	Global.dragon = self
	
	add_segment()


func start_moving() -> void:
	started = true


func _physics_process(delta: float) -> void:
	var cur_speed = speed * speed_mult * speed_curve.sample(segments().size())

	$Head.speed = cur_speed
	var leading: Node2D = head
	var idx = 0
	for b in segments():
		if not b.update_position(leading, follow_distance, cur_speed, delta, b.get_index()):
			break
		
		leading = b
		idx += 1

	
func add_segment() -> void:
	var segment = preload("res://dragon/body_segment.tscn").instantiate()
	
	var leading: Node2D = head
	if $Body.get_child_count() > 0:
		leading = $Body.get_child(0)
	
	segment.global_position = leading.global_position
	segment.add_collision_exception_with(leading)
	leading.add_collision_exception_with(segment)
	if leading is Segment:
		leading.is_last = false
	
	$Body.add_child(segment)
	$Body.move_child(segment, 0)
	segment.is_last = true


func remove_segment() -> void:
	if $Body.get_child_count() == 0:
		return

	var b = $Body.get_children().pop_front()
	
	if $Body.get_child(1) is Segment:
		$Body.get_child(1).is_last = true
	b.queue_free()
	
	if $Body.get_child_count() <= 2:
		player_died.emit()


func _on_mouth_area_entered(area: Area2D) -> void:
	if area is Consumable:
		consumable_entered_mouth(area)
		return


func consumable_entered_mouth(consumable: Consumable) -> void:
	if not consumable.owner.can_be_eaten:
		SoundManager.stop_any_sfx(Sounds.BITE_METAL)
		consumable.owner.play_hit()
		return
	
	consumable.eat()


func _on_mouth_body_entered(body: Node2D) -> void:
	if not body.is_in_group("segment"):
		return
	
	if not body.leading:
		return
	var entry_angle = body.global_position.direction_to(body.leading.global_position).angle_to(body.global_position.direction_to(head.global_position))
	if entry_angle < PI/2 and entry_angle > -PI/2:
		return
	
	strangle_points.clear()
	strangle_points.append(to_local(head.global_position))
	
	var segment_idx = 0
	for s in segments():
		if s is not Node2D:
			continue
		strangle_points.append(to_local(s.global_position))
		
		if body == s:
			break
		segment_idx += 1
	
	var window = constriction_windows.add_window($Body.get_child_count(), segment_idx)
	
	#$Body.get_child(-1).body_collision_exited.connect(func(body): segment_exited_collision($Body.get_child(-1), body, window), ConnectFlags.CONNECT_ONE_SHOT)
	
	#get_captured_consumables()
	#queue_redraw()


func update_captured_warriors(window: ConstrictionManager.ConstrictionWindow) -> Array[Dictionary]:
	if window.start_segment < window.end_segment:
		#assert(false, "Illegal window")
		return []

	var points: PackedVector2Array = []
	var s = window.start_segment
	while s >= window.end_segment:
		var segment = $Body.get_child(s) as Segment
		points.append(segment.global_position)
		s -= 1
	
	points.append(points[0])
	
	if points.size() < 3:
		return []
		
	var space_state = get_world_2d().direct_space_state

	# Use Convex or Concave shape depending on polygon type
	var poly_shape = ConvexPolygonShape2D.new()
	poly_shape.points = points

	var shape_params = PhysicsShapeQueryParameters2D.new()
	shape_params.shape = poly_shape
	shape_params.transform = Transform2D(0, Vector2.ZERO) # Position in world
	shape_params.collision_mask = 8

	# Query physics space for bodies intersecting this polygon
	var results = space_state.intersect_shape(shape_params, 32)

	for r in results:
		if r.collider is Warrior:
			(r.collider as Warrior).captured = true
	
	
	strangle_points = points
	queue_redraw()
	
	return results


func segments() -> Array[Segment]:
	var arr: Array[Segment]
	arr.assign($Body.get_children())
	arr.reverse()
	return arr
	

# the segment the top segment collided with is the new ending segment of the loop
func segment_exited_collision(old_start: Node2D, new_end: Node2D, window: ConstrictionManager.ConstrictionWindow) -> void:
	if new_end is not Segment:
		return
	
	var new_start = window.start_segment - 1
	#$Body.get_child(new_start).body_collision_exited.connect(func(body): segment_exited_collision($Body.get_child(new_start), body, window), ConnectFlags.CONNECT_ONE_SHOT)
	constriction_windows.edit(window, new_start, new_end.get_index())


func _on_segment_detect_body_exited(body: Node2D) -> void:
	if body is not Segment:
		return
	
	if not $StartTimer.is_stopped():
		return
	
	var body_idx = body.get_index()
	
	# Create window between body_idx and the segment following the head
	var window = constriction_windows.add_window($Body.get_child_count() - 1, body_idx)
	
	var start_segment_body = $Body.get_child(window.start_segment)
	if start_segment_body.body_collision_exited.is_connected(_on_segment_exited_segment.bind(start_segment_body)):
		return
	#TODO: in eliminating double connection we can probably get rid of the left over windows too.
	start_segment_body.body_collision_exited.connect(_on_segment_exited_segment.bind(start_segment_body), ConnectFlags.CONNECT_ONE_SHOT)


func _on_segment_exited_segment(body: Node2D, origin_body: Segment) -> void:
	var segment = body as Segment
	
	var window = constriction_windows.get_window(origin_body.get_index())
	
	if window == null:
		#print("WINDOW WITH START_SEGMENT ", origin_body.get_index(), " DOES NOT EXIST!")
		return
	
	#print("CONTINUE WINDOW s:", window.start_segment, " e: ", window.end_segment)
	# TODO: add check to remove constriction if the window is no longer constricting.
	window = constriction_windows.edit(window, window.start_segment - 1, body.get_index())
	if not window:
		#print("WINDOW DISCARDED BY MANAGER!")
		return
		
	var start_segment_body = $Body.get_child(window.start_segment)
	if not start_segment_body.body_collision_exited.is_connected(_on_segment_exited_segment.bind(start_segment_body)):
		start_segment_body.body_collision_exited.connect(_on_segment_exited_segment.bind(start_segment_body), ConnectFlags.CONNECT_ONE_SHOT)
	
	var res = update_captured_warriors(window)
	if res.is_empty():
		constriction_windows.remove_window(window)
	
	## Invalid window cleanup...
	#var dist = start_segment_body.global_position.distance_to(body.global_position) 
	#await get_tree().create_timer(0.5).timeout
	#
	#if dist < start_segment_body.global_position.distance_to(body.global_position):
		#print("WINDOW at start ", start_segment_body.get_index(), " to loose!")


func get_speed_multiplier(segment_count: int) -> float:
	var min_segments = 3
	var max_segments = 30
	var max_speed = 1.75
	var min_speed = 0.75

	segment_count = clamp(segment_count, min_segments, max_segments)

	var t = float(segment_count - min_segments) / (max_segments - min_segments)
	return lerp(max_speed, min_speed, t)


func take_damage(part: Node2D) -> void:
	if not $InvincibleTimer.is_stopped():
		return
	
	SoundManager.play_random_sfx(Sounds.DAMAGED)
	$Head/AnimationPlayer.play("damaged")
	remove_segment()
	$InvincibleTimer.start()
	


func _on_head_start_eating() -> void:
	speed_mult = 0.6


func _on_head_finish_eating() -> void:
	speed_mult = 1.0
