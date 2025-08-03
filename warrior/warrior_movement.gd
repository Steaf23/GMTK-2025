class_name WarriorMovement
extends Node

@export var speed: int = 30

@export var warrior: Warrior

@onready var direction: Vector2 = Vector2.ZERO

@onready var is_moving: bool = false


# Walks up to the nearest segment of the dragon and tries to stay about 40 px away to not get in the way
func _physics_process(delta: float) -> void:
	if not Global.dragon:
		return
	
	if not warrior.dragon_segment:
		return
	var desired_position = warrior.dragon_segment.global_position + (warrior.dragon_segment.global_position.direction_to(warrior.global_position) * 40)
	direction = warrior.global_position.direction_to(desired_position)
	
	if warrior.global_position.distance_to(desired_position) < 1.0:
		warrior.velocity = Vector2.ZERO
	else:
		warrior.velocity = direction * speed
	warrior.move_and_slide()
	
	is_moving = warrior.get_position_delta().length() > 0.2

		
