extends Node2D

@onready var dragon: Dragon = $Dragon

@onready var score: Label = %Score
@onready var highscore = 0


func _ready() -> void:
	randomize()
	
	dragon.player_died.connect(_on_player_died)
	
	for c in $Enemies.get_children():
		if c is Warrior:
			c.killed.connect(_on_warrior_killed.bind(c))


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
	pass


func _on_player_died() -> void:
	$Gameover.show()
	$%FinalScore.text = "Score: %s" % [highscore]
	get_tree().paused = true
	

func _on_warrior_killed(warrior: Warrior) -> void:
	dragon.add_segment()
	warrior.queue_free()


func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
