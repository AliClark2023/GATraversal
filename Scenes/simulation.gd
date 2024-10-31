extends Node2D

@onready var spawner = $SpawnFolder
@onready var goal = $Goal
@export var spawnAmount: int = 100


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print ("Generation: " + str(Global.generationNum))
	spawnCreatures()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func spawnCreatures() ->void:
	# other generations
	if Global.bestDNA:
		for i in spawnAmount:
			var creature := preload("res://Scenes/creature.tscn").instantiate()
			creature.original = false
			spawner.add_child(creature)
		for creature in spawner.get_children():
			creature.alive = true
	# first generation
	else:
		for i in spawnAmount:
			var creature := preload("res://Scenes/creature.tscn").instantiate()
			creature.original = true
			creature.alive = true
			spawner.add_child(creature)


func _on_timer_timeout() -> void:
	var numOfDead:int = 0
	# checks if all creatures are dead
	for creature in spawner.get_children():
		if !creature.alive:
			numOfDead += 1
	# determines best fitness when all creatures are dead
	if numOfDead == spawnAmount:
		var bestFitnessSoFar:float = 10000000.0
		var idOfBestFit: int = 0
		
		for i in spawner.get_child_count():
			var fitness: float = spawner.get_child(i).fitness
			if fitness < bestFitnessSoFar:
				idOfBestFit = i
				bestFitnessSoFar = fitness
		
		if Global.bestFit > bestFitnessSoFar:
			Global.bestFit = bestFitnessSoFar
			Global.bestDNA = spawner.get_child(idOfBestFit).genome
		
		Global.generationNum +=1
		get_tree().reload_current_scene()
