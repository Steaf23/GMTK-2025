class_name PotWarrior
extends Warrior


func _ready() -> void:
	if randi() % 10 == 0:
		$Sprite2D.play("big")
		$ConsumeArea.reward = 2
	if randi() % 20 == 0:
		$Sprite2D.play("gold")
		$ConsumeArea.reward = 5

func _physics_process(delta: float) -> void:
	pass
