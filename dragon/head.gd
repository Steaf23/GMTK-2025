extends CharacterBody2D

var speed: int = 0

var cur_dir: Vector2 = Vector2.RIGHT

var is_eating: bool = false


func _physics_process(delta: float) -> void:
	if not is_eating:
		var input_dir = get_viewport_rect().get_center().direction_to(get_viewport().get_mouse_position())
		var angle = cur_dir.angle_to(input_dir)

		cur_dir = cur_dir.rotated(lerp_angle(0.0, angle, 0.05))
	
	velocity = cur_dir * speed
	move_and_slide()
	queue_redraw()
	
	var angle = velocity.angle()
	if angle < -PI/2 or angle > PI/2:
		%Sprite.scale.y = -1
	else:
		%Sprite.scale.y = 1
		
	$HeadPivot.rotation = velocity.angle()


func bite() -> void:
	%Sprite.play("bite")


func _on_sprite_animation_finished() -> void:
	if %Sprite.animation == "bite":
		%Sprite.play("default")
		
