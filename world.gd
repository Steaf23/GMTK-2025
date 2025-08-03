class_name World
extends Node2D

@onready var dragon: Dragon = $Dragon
@onready var spawner: Spawner = $Spawner
@onready var score: Label = %Score

@onready var highscore = 0

var in_tutorial: bool = true

var counter: float = 0


func _ready() -> void:
	randomize()
	
	dragon.player_died.connect(_on_player_died)
	
	for c in $Enemies.get_children():
		if c is Warrior:
			c.killed.connect(_on_warrior_killed.bind(c))


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		_on_restart_pressed()	

	if in_tutorial and event.is_action_pressed("continue"):
		in_tutorial = false
		$Tutorial.hide()
		SoundManager.play_sfx(Sounds.GAME_START, 0.3)
		dragon.start_moving()
		for i in 2:
			dragon.add_segment()
		spawner.start()

func _on_add_pressed() -> void:
	dragon.add_segment()


func _on_remove_pressed() -> void:
	dragon.remove_segment()


func _process(delta: float) -> void:
	#var text = ""
	#for w in dragon.constriction_windows.windows:
		#text += "Diff: %s, Start: %s, End: %s\n" % [w.start_segment - w.end_segment, w.start_segment, w.end_segment]
	#$CanvasLayer/Label.text = text
	
	var s = dragon.segments().size()
	if s > highscore:
		highscore = s
	score.text = "High Score: %s\nScore: %s" % [highscore, s]
	
	
	if in_tutorial:
		return
	counter += delta
	var second = counter 
	%Time.text = "%s:%2s" % [str(int(counter / 60)).pad_zeros(2), str(int(counter) % 60).pad_zeros(2)]


func _on_player_died() -> void:
	$Gameover.show()
	%FinalScore.text = "Score: %s" % [highscore]
	get_tree().paused = true
	

func _on_warrior_killed(warrior: Warrior) -> void:
	SoundManager.stop_any_sfx(Sounds.CONSTRICT)
	if warrior.get_reward() == 1:
		spawn_spirit(warrior.global_position, 0)
	elif warrior.get_reward() == 2:
		spawn_spirit(warrior.global_position, 8)
		spawn_spirit(warrior.global_position, 8)
	else:
		for i in 3:
			spawn_spirit(warrior.global_position, 12)
	
	SoundManager.play_random_sfx(Sounds.BREAK, .8)
	for i in warrior.get_reward():
		dragon.add_segment()
	warrior.queue_free()


func _on_restart_pressed() -> void:
	SoundManager.play_sfx(Sounds.BUTTON_PRESS, .5)
	get_tree().paused = false
	get_tree().reload_current_scene()


func add_warrior(warrior: Warrior) -> void:
	warrior.killed.connect(_on_warrior_killed.bind(warrior))
	$Enemies.add_child(warrior)
	

func get_warrior_count() -> int:
	return $Enemies.get_children().filter(func(w): return w is not PotWarrior).size()


func spawn_spirit(global_pos: Vector2, pos_offset_radius: int) -> void:
	var spirit = preload("res://warrior/spirit.tscn").instantiate()
	$Spirits.add_child(spirit)
	spirit.global_position = global_pos + Vector2(randi_range(0, pos_offset_radius), randi_range(0, pos_offset_radius) - 5)
