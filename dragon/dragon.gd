class_name Dragon
extends Node2D

@export var follow_distance: int = 15
@export var speed: int = 150
@export var speed_mult: float = 1.0


func _ready() -> void:
	for i in 10:
		add_segment()
		

func _physics_process(delta: float) -> void:
	
	var cur_speed = speed
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		cur_speed = speed * speed_mult
	
	$Head.speed = cur_speed
	var leading: Node2D = $Head
	var idx = 0
	for b in $Body.get_children():
		var target = leading.global_position.direction_to(b.global_position) * follow_distance + leading.global_position
		
		var direction = target - b.global_position
		var distance = direction.length()
		
		if distance < 1.0:
			break
	
		var target_velocity = b.global_position.direction_to(target) * cur_speed
		b.velocity = b.velocity.lerp(target_velocity, 0.4)
		#b.velocity = lerp(old_velocity, b.velocity, 0.1)
		b.move_and_slide()
		leading = b
		idx += 1
		

func add_segment() -> void:
	var segment = preload("res://dragon/body_segment.tscn").instantiate()
	
	var leading: Node2D = $Head
	if $Body.get_child_count() > 0:
		leading = $Body.get_child(-1)
	
	segment.global_position = leading.global_position
	segment.add_collision_exception_with(leading)
	leading.add_collision_exception_with(segment)
	$Body.add_child(segment)


func remove_segment() -> void:
	if $Body.get_child_count() == 0:
		return

	var b = $Body.get_children().pop_back()
	b.queue_free()


func _on_add_pressed() -> void:
	add_segment()


func _on_remove_pressed() -> void:
	remove_segment()
