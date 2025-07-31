class_name Dragon
extends Node2D

@export var follow_distance: int = 15
@export var speed: int = 150
@export var speed_mult: float = 1.0

@onready var head: CharacterBody2D = $Head

var eating_count = 0

var strangle_points: PackedVector2Array = []

func _ready() -> void:
	for i in 3:
		add_segment()
		

func _physics_process(delta: float) -> void:
	
	var cur_speed = speed * speed_mult

	$Head.speed = cur_speed
	var leading: Node2D = head
	var idx = 0
	for b in $Body.get_children():
		if not b.update_position(leading, follow_distance, cur_speed, delta):
			break
		
		leading = b
		idx += 1
		

func add_segment() -> void:
	var segment = preload("res://dragon/body_segment.tscn").instantiate()
	
	var leading: Node2D = head
	if $Body.get_child_count() > 0:
		leading = $Body.get_child(-1)
	
	segment.global_position = leading.global_position
	segment.add_collision_exception_with(leading)
	leading.add_collision_exception_with(segment)
	if leading is Segment:
		leading.is_last = false
	
	$Body.add_child(segment)
	segment.is_last = true


func remove_segment() -> void:
	if $Body.get_child_count() == 0:
		return

	var b = $Body.get_children().pop_back()
	
	if $Body.get_child(-1) is Segment:
		$Body.get_child(-1).is_last = true
	b.queue_free()


func _on_mouth_area_entered(area: Area2D) -> void:
	if area is Consumable:
		consumable_entered_mouth(area)
		return


func consumable_entered_mouth(consumable: Consumable) -> void:

	head.is_eating = true
	speed_mult = 0.6
	eating_count += 1
	head.bite()
	await get_tree().create_timer(0.5).timeout

	eating_count = max(eating_count - 1, 0)
	head.is_eating = eating_count > 0
	if not head.is_eating:
		speed_mult = 1.0
		
	if consumable:
		consumable.owner.queue_free()
	add_segment()



func _draw() -> void:
	#for b in segments():
		#draw_circle(to_local(b.global_position), 10, Color.html("#e8c7b3"))
		#
	#for b in segments():
		#draw_circle(to_local(b.global_position) + Vector2(0, 5), 10, Color.html("#cf0000"))
	#
	if strangle_points.is_empty():
		return
	
	var c = Color.DODGER_BLUE
	c.a = 0.5
	draw_colored_polygon(strangle_points, c)


func _on_mouth_body_entered(body: Node2D) -> void:
	if not body.is_in_group("segment"):
		return
	
	if not body.leading:
		return
	var entry_angle = body.global_position.direction_to(body.leading.global_position).angle_to(body.global_position.direction_to(head.global_position))
	print(rad_to_deg(entry_angle))
	if entry_angle < PI/2 and entry_angle > -PI/2:
		return
	
	strangle_points.clear()
	strangle_points.append(to_local(head.global_position))
	for s in $Body.get_children():
		if s is not Node2D:
			continue
		strangle_points.append(to_local(s.global_position))
		
		if body == s:
			break
	
	get_captured_consumables()
	queue_redraw()


func get_captured_consumables() -> void:
	var space_state = get_world_2d().direct_space_state

	# Use Convex or Concave shape depending on polygon type
	var poly_shape = ConvexPolygonShape2D.new()
	poly_shape.points = strangle_points

	var shape_params = PhysicsShapeQueryParameters2D.new()
	shape_params.shape = poly_shape
	shape_params.transform = Transform2D(0, Vector2.ZERO) # Position in world
	shape_params.collision_mask = 8

	# Query physics space for bodies intersecting this polygon
	var results = space_state.intersect_shape(shape_params, 32)

	for r in results:
		print("Found body: ", r.collider)


func segments() -> Array[Segment]:
	var arr: Array[Segment]
	arr.assign($Body.get_children())
	return arr
