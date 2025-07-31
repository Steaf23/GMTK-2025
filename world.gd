extends Node2D

@onready var dragon: Dragon = $Dragon

func _on_add_pressed() -> void:
	dragon.add_segment()


func _on_remove_pressed() -> void:
	dragon.remove_segment()
