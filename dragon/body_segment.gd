extends CharacterBody2D


@onready var leading: Node2D = null

func update_position(leading: Node2D, follow_distance: float, speed: int, delta: float) -> bool:
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
