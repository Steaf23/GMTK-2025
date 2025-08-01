class_name Warrior
extends CharacterBody2D

signal killed()

@export var max_health: int = 1
@export var can_be_eaten: bool = false
@export var can_be_damaged: bool = true

@onready var health: int = max_health:
	set(value):
		health = value
		$ProgressBar.value = health
		if health == 1:
			can_be_eaten = true
			can_be_damaged = false

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
	$ProgressBar.max_value = max_health
	$ProgressBar.value = max_health
		
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
	
	captured = false
	
	if not can_be_damaged:
		return
		
	health -= 1
	if health <= 0:
		killed.emit()
