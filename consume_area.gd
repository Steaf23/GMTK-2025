class_name Consumable
extends Area2D

signal eaten()

@export var reward: int = 1

func eat() -> void:
	eaten.emit()
