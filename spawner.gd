class_name Spawner
extends Node2D


@export var starting_difficulty: float = 0.0
@export var increase_rate: float = 0.1
@export var base_budget: int = 5
@export var world: World
@export var max_spawns_per_check: int = 5
@export var min_spawns_per_check: int = 2
@export var dragon_segment_radius: float = 30

@onready var regions: Node2D = $Regions
@onready var difficulty: float = starting_difficulty

@onready var started: bool = false

@onready var dragon_radius_sq = dragon_segment_radius * dragon_segment_radius
@onready var dragon_head_radius_sq = 200 * 200

# scene: cost
var spawnables: Array = [
	{"scene": preload("res://warrior/pot_warrior.tscn"), "weight": 1},
	{"scene": preload("res://warrior/small_warrior.tscn"), "weight": 5},
	{"scene": preload("res://warrior/big_warrior.tscn"), "weight": 20},
]

func start() -> void:
	started = true
	$SpawnTimer.start()


func _physics_process(delta: float) -> void:
	if not started:
		return
		
	difficulty += delta * increase_rate


func _on_spawn_timer_timeout() -> void:
	var budget = difficulty * base_budget + 5
	
	var scenes: Array[PackedScene] = []
	
	var max_spawnables = randi_range(min_spawns_per_check, max_spawns_per_check)
	while budget > 0 and scenes.size() < max_spawnables:
		var choice = get_spawnable_with_budget(budget)
		
		if choice.scene == null:
			break
		
		budget -= choice.weight
		scenes.append(choice.scene)
	
	for s in scenes:
		spawn(s)


func get_spawnable_with_budget(budget: int) -> Dictionary:
	var choices = spawnables.filter(func(s): return budget >= s.weight)
	if choices.is_empty():
		return {"scene": null, "weight": 0}
		
	return choices.pick_random()
	

func spawn(scene: PackedScene) -> void:
	assert(world, "SET OBJECTS NODE FOR SPAWNING")
	if not world:
		return
	var obj = scene.instantiate()
	world.add_warrior(obj)
	
	var region = determine_spawn_region()
	var spawn_pos = Vector2(randf_range(region.position.x, region.end.x), randf_range(region.position.y, region.end.y))
	for i in 10:
		if not overlaps_dragon(regions.global_position + spawn_pos):
			break
		spawn_pos = Vector2(randf_range(region.position.x, region.end.x), randf_range(region.position.y, region.end.y))
	
	obj.global_position = regions.global_position + spawn_pos
	
	
func determine_spawn_region() -> Rect2:
	if regions.get_child_count() == 0:
		assert(false)
		return Rect2()
		
	return regions.get_children().pick_random().get_rect()

	
func overlaps_dragon(pos: Vector2) -> bool:
	if not Global.dragon:
		return false
	
	if Global.dragon.head.global_position.distance_squared_to(pos) <= dragon_head_radius_sq:
		return true
		
	for s in Global.dragon.segments():
		if s.global_position.distance_squared_to(pos) <= dragon_radius_sq:
			return true
			
	return false
