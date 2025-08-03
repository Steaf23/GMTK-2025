extends VBoxContainer


func _ready() -> void:
	hide()
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") or (event.is_pressed() and event is InputEventKey and event.physical_keycode == KEY_ESCAPE):
		toggle_pause()


func toggle_pause() -> void:
	if get_tree().paused:
		unpause()
	else:
		pause()
		

func pause() -> void:
	show()
	SoundManager.muffle_music(true)
	get_tree().paused = true
	
	
func unpause() -> void:
	hide()
	SoundManager.muffle_music(false)
	get_tree().paused = false


func _on_resume_pressed() -> void:
	SoundManager.play_sfx(Sounds.BUTTON_PRESS, .5)
	toggle_pause()
