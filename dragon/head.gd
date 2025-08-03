class_name DragonHead
extends CharacterBody2D

var speed: int = 0

var cur_dir: Vector2 = Vector2.RIGHT

var is_eating: bool = false

var bite_input: bool = false

signal start_eating()
signal finish_eating()


func _physics_process(delta: float) -> void:
	if not get_parent().started:
		return
		
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


#func _on_sprite_animation_finished() -> void:
	#if %Sprite.animation == "open":
		#if not bite_input:
			## entering the bite phase
			#$HeadPivot/Mouth/MouthShape.set_deferred("disabled", false)
			#
			#await get_tree().create_timer(0.3).timeout
			#
			#$HeadPivot/Mouth/MouthShape.set_deferred("disabled", true)
		#else:
			## TODO: add bite SFX
			#%Sprite.play("default")
		


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("bite"):
		bite_input = true
		%Sprite.play("open")
		start_eating.emit()
	
	if event.is_action_released("bite"):
		bite_input = false
		%Sprite.play("default")
		
		$HeadPivot/Mouth/MouthShape.set_deferred("disabled", false)
			
		await get_tree().create_timer(0.3).timeout
		
		finish_eating.emit()
		$HeadPivot/Mouth/MouthShape.set_deferred("disabled", true)
	
