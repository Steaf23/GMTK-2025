class_name Consumable
extends Area2D

signal eaten()

@export var reward: int = 1

func eat() -> void:
	eaten.emit()
	
	if owner is Warrior:
		await get_tree().create_timer(0.3).timeout
		owner.killed.emit()
