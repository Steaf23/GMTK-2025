extends CharacterBody2D

@export var speed = 100

func _physics_process(delta: float) -> void:
	var dir = get_viewport_rect().get_center().direction_to(get_viewport().get_mouse_position())
	velocity = dir * speed
	move_and_slide()
