class_name Dragon
extends Node2D

@export var follow_distance: int = 15

func _ready() -> void:
	for i in 10:
		add_segment()
		

func _physics_process(delta: float) -> void:
	
	var leading: Node2D = $Head
	for b in $Body.get_children():
		var target = leading.global_position.direction_to(b.global_position) * follow_distance + leading.global_position
		
		#if b is RigidBody2D:
			#b.apply_central_impulse(b.global_position.direction_to(leading.global_position) * follow_distance + leading.global_position)
		
		b.velocity = b.global_position.direction_to(target) * 100
		b.move_and_slide()
		leading = b


func add_segment() -> void:
	var segment = preload("res://dragon/body_segment.tscn").instantiate()
	
	var back: Node2D = $Head
	if $Body.get_child_count() > 0:
		back = $Body.get_child(-1)
	
	segment.global_position = back.global_position
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
