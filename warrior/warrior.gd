class_name Warrior
extends CharacterBody2D

signal killed()

@export var max_health: int = 1:
	set(value):
		max_health = value
		
		if not is_node_ready():
			await ready
			
		$ProgressBar.visible = max_health > 1
		
@export var can_be_eaten: bool = false
@export var can_be_damaged: bool = true
@export var can_always_be_damaged: bool = false

@onready var dragon_segment: Node2D = null

@onready var movement: WarriorMovement = get_node_or_null("Components/WarriorMovement")
@onready var attack: WarriorAttack = get_node_or_null("Components/WarriorAttack")

@onready var health: int = max_health:
	set(value):
		health = value
		$ProgressBar.value = health
		if health == 1:
			can_be_eaten = true
			can_be_damaged = can_always_be_damaged
			$ProgressBar.tint_progress = Color.html("#cf3337")

@onready var captured: bool = false:
	set(value):
		if not is_stuck() and captured:
			SoundManager.stop_any_sfx(Sounds.CONSTRICT)
		
		if not is_stuck():
			captured = false
		
		if value and not captured:
			$ConstrictTimer.start()
			captured = true
			SoundManager.play_random_sfx(Sounds.CONSTRICT, .3)
			
		if not value:
			captured = false
			

func _ready() -> void:
	$StaticBody2D.add_collision_exception_with(self)
	$ProgressBar.max_value = max_health
	$ProgressBar.value = max_health
	$ProgressBar.tint_progress = Color.html("#00c700")
		
	for c in $Rays.get_children():
		c.add_exception(self)
	


func is_stuck() -> bool:
	for c in $Rays.get_children():
		if not c.is_colliding():
			return false
	
	return true
		
		

func _physics_process(delta: float) -> void:
	
	var attacking
	if not attack:
		attacking = false
	else:
		attacking = attack.is_attacking
		
	if velocity.y < 0.0:
		if attacking:
			$Sprite2D.play("back_attack")
		else:
			$Sprite2D.play("back")
	else:
		if attacking:
			$Sprite2D.play("front_attack")
		else:
			$Sprite2D.play("front")


func _process(delta: float) -> void:
	if not movement:
		return
		
	if movement.is_moving:
		$AnimationPlayer.play("walk")
	else:
		$AnimationPlayer.play("RESET")
	

func _on_constrict_timer_timeout() -> void:
	if not is_stuck():
		captured = false
		return
	
	captured = false
	
	if not can_be_damaged and not can_always_be_damaged:
		SoundManager.play_random_sfx(Sounds.BITE_METAL)
		return
		
	SoundManager.play_random_sfx(Sounds.DASH, 0.4)
	health -= 1
	if health <= 0:
		killed.emit()


func _on_consume_area_eaten() -> void:
	$CollisionShape2D2.set_deferred("disabled", true)
	$StaticBody2D/CollisionShape2D.set_deferred("disabled", true)


func _on_retarget_timer_timeout() -> void:
	dragon_segment = Global.nearest_segment_or_head(global_position)


func get_reward() -> int:
	return $ConsumeArea.reward
