class_name Segment
extends CharacterBody2D


@onready var leading: Node2D = null

@onready var is_last: bool = false:
	set(value):
		is_last = value
		if is_node_ready():
			if is_last:
				$Sprite.animation = "tail"
			elif has_arms:
				$Sprite.animation = "arms"
			else:
				$Sprite.animation = "default"

@onready var has_arms: bool = false:
	set(value):
		has_arms = value
		if is_node_ready() and has_arms:
			$Sprite.animation = "arms"

@onready var body_angle: float = 0.0


func _ready() -> void:
	has_arms = randi() % 5 == 0 # A segment has 1 in 3 chance to have arms


func update_position(leading: Node2D, follow_distance: float, speed: int, delta: float) -> bool:
	if leading is not Segment: # leading must be the head, so we have arms.
		has_arms = true
		
	
	self.leading = leading
	var target = leading.global_position.direction_to(global_position) * follow_distance + leading.global_position
		
	var direction = target - global_position
	var distance = direction.length()
		
	if distance < 1.0:
		return false
	
	var target_velocity = global_position.direction_to(target) * speed
	velocity = velocity.lerp(target_velocity, 0.4)
	#b.velocity = lerp(old_velocity, b.velocity, 0.1)
	move_and_slide()
	return true


func _process(delta: float) -> void:
	if not leading:
		return
	
	body_angle = Vector2.RIGHT.angle_to(global_position.direction_to(leading.global_position))
	
	if body_angle < -PI/2 or body_angle > PI/2:
		$Sprite.scale.y = -1
	else:
		$Sprite.scale.y = 1
		
	$Sprite.rotation = body_angle
