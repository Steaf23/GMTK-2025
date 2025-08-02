class_name WarriorAttack
extends Node2D

@export var warrior: Warrior
@export var attack_distance = 50
@export var is_attacking: bool = false

func _on_hitbox_body_entered(body: Node2D) -> void:
	if not Global.dragon:
		return
		
	if body is Segment or body is DragonHead:
		Global.dragon.take_damage(body)


func precondition() -> bool:
	if not $Cooldown.is_stopped():
		return false
	
	if not warrior.dragon_segment:
		return false
		
	return warrior.dragon_segment.global_position.distance_to(warrior.global_position) <= attack_distance


func _physics_process(delta: float) -> void:
	if precondition():
		$Hitbox.look_at(warrior.dragon_segment.global_position)
		$Cooldown.start()
		$AnimationPlayer.play("attack")
