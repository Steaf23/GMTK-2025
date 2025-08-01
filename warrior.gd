class_name Warrior
extends CharacterBody2D

signal killed()

@onready var captured: bool = false:
	set(value):
		if not is_stuck():
			captured = false
		
		if value and not captured:
			$ConstrictTimer.start()
			captured = true
			
		if not value:
			captured = false
			

func _ready() -> void:
	for c in $Rays.get_children():
		c.add_exception(self)


func is_stuck() -> bool:
	for c in $Rays.get_children():
		if not c.is_colliding():
			return false
	
	return true
		

func _on_constrict_timer_timeout() -> void:
	if not is_stuck():
		captured = false
		return
	
	killed.emit()
