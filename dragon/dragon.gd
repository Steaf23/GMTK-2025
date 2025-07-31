class_name Dragon
extends Node2D

@export var follow_distance: int = 15
@export var speed: int = 150
@export var speed_mult: float = 1.0

@onready var head: CharacterBody2D = $Head

var eating_count = 0

func _ready() -> void:
	for i in 10:
		add_segment()
		

func _physics_process(delta: float) -> void:
	
	var cur_speed = speed * speed_mult

	$Head.speed = cur_speed
	var leading: Node2D = head
	var idx = 0
	for b in $Body.get_children():
		var target = leading.global_position.direction_to(b.global_position) * follow_distance + leading.global_position
		
		var direction = target - b.global_position
		var distance = direction.length()
		
		if distance < 1.0:
			break
	
		var target_velocity = b.global_position.direction_to(target) * cur_speed
		b.velocity = b.velocity.lerp(target_velocity, 0.4)
		#b.velocity = lerp(old_velocity, b.velocity, 0.1)
		b.move_and_slide()
		leading = b
		idx += 1
		

func add_segment() -> void:
	var segment = preload("res://dragon/body_segment.tscn").instantiate()
	
	var leading: Node2D = head
	if $Body.get_child_count() > 0:
		leading = $Body.get_child(-1)
	
	segment.global_position = leading.global_position
	segment.add_collision_exception_with(leading)
	leading.add_collision_exception_with(segment)
	$Body.add_child(segment)


func remove_segment() -> void:
	if $Body.get_child_count() == 0:
		return

	var b = $Body.get_children().pop_back()
	b.queue_free()


func _on_mouth_area_entered(area: Area2D) -> void:
	if not area.is_in_group(&"consumable") and area is not Consumable:
		return
	
	head.is_eating = true
	speed_mult = 0.6
	eating_count += 1
	await get_tree().create_timer(0.5).timeout

	eating_count = max(eating_count - 1, 0)
	head.is_eating = eating_count > 0
	if not head.is_eating:
		speed_mult = 1.0
		
	if area:
		area.owner.queue_free()
	add_segment()
