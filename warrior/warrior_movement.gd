class_name WarriorMovement
extends Node

@export var speed: int = 30

@export var warrior: Warrior

@onready var direction: Vector2 = Vector2.ZERO


# Walks up to the nearest segment of the dragon and tries to stay about 40 px away to not get in the way
func _physics_process(delta: float) -> void:
	if not Global.dragon:
		return
	
	if not warrior.dragon_segment:
		return
	var desired_position = warrior.dragon_segment.global_position + (warrior.dragon_segment.global_position.direction_to(warrior.global_position) * 40)
	direction = warrior.global_position.direction_to(desired_position)
	warrior.velocity = direction * speed
	warrior.move_and_slide()

		
