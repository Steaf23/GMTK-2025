extends Node2D

@onready var dragon: Dragon = $Dragon


func _ready() -> void:
	randomize()
	
	for c in $Enemies.get_children():
		if c is Warrior:
			c.killed.connect(_on_warrior_killed.bind(c))


func _on_add_pressed() -> void:
	dragon.add_segment()


func _on_remove_pressed() -> void:
	dragon.remove_segment()


func _process(delta: float) -> void:
	var text = ""
	for w in dragon.constriction_windows.windows:
		text += "Diff: %s, Start: %s, End: %s\n" % [w.start_segment - w.end_segment, w.start_segment, w.end_segment]
	$CanvasLayer/Label.text = text


func _on_warrior_killed(warrior: Warrior) -> void:
	dragon.add_segment()
	warrior.queue_free()
