extends Node2D

@onready var spawner = $SpawnFolder
@onready var goal = $Goal
@export var spawnAmount: int = 100
@export var genomeThreshold: float = 0.4
@export var distanceToGoal: float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	distanceToGoal = ((spawner.global_position.distance_to(goal.global_position)))
	
	if Global.previousGen.size() == 0:
		initialiseGenArray()

	print ("Generation: " + str(Global.generationNum))
	spawnCreatures()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func spawnCreatures() ->void:
	# other generations
	if Global.bestDNA:
		for i in spawnAmount:
			# selection, crossover and mutation methods go here
			selectStrong();
			
			var creature := preload("res://Scenes/creature.tscn").instantiate()
			creature.firstGen = false
			spawner.add_child(creature)
		for creature in spawner.get_children():
			creature.alive = true
	# first generation
	else:
		for i in spawnAmount:
			var creature := preload("res://Scenes/creature.tscn").instantiate()
			creature.firstGen = true
			creature.alive = true
			spawner.add_child(creature)

func initialiseGenArray() -> void:			
	for i in spawnAmount:
		var genome = []
		for j in Global.genomeSize:
			genome.append(Vector2.ZERO)
		Global.previousGen.append([genome, 0.0])

# checks game state every timeout
func _on_timer_timeout() -> void:
	var numOfDead:int = 0
	# checks if all creatures are dead
	for creature in spawner.get_children():
		if !creature.alive:
			numOfDead += 1
			
	# debug
	#print("number of dead" + str(numOfDead))
	
	# determines best fitness when all creatures are dead
	if numOfDead == spawnAmount:
		var bestFitnessSoFar:float = 10000000.0
		var idOfBestFit: int = 0
		
		for i in spawner.get_child_count():
			var fitness: float = spawner.get_child(i).fitness
			if fitness < bestFitnessSoFar:
				idOfBestFit = i
				bestFitnessSoFar = fitness
				
			# adding to previous gen array
			for j in spawner.get_child(i).genomeSize:
				Global.previousGen[i][0][j] = spawner.get_child(i).genome[j]
			Global.previousGen[i][1] = fitness
		
		if Global.bestFit > bestFitnessSoFar:
			Global.bestFit = bestFitnessSoFar
			Global.bestDNA = spawner.get_child(idOfBestFit).genome
		
		Global.generationNum +=1
		get_tree().reload_current_scene()

# mutation functions (entire genome)
# keeps mutated genome regardless of fitness
func destMutation() -> void:
	var creature := preload("res://Scenes/creature.tscn").instantiate()
	creature.firstGen = false
	creature.alive = true
	
	for i in creature.genomeSize:
		var v: Vector2 = Vector2(randi_range(-1,1), randi_range(-1,1)).normalized() * creature.speed
		creature.genome.append(v)
		#creature.genome[i] = v
		pass
	
	spawner.add_child(creature)
	print("mutated")

func constructMutation() -> void:
	pass

# selection functions
# strongest survive
func selectStrong() -> void:
	for i in Global.previousGen.size():
		var distPercent: float = Global.previousGen[i][1] / distanceToGoal
		if Global.previousGen[i][1] > genomeThreshold:
			pass
		pass
	pass
# some weak survive
func selectWeak() -> void:
	pass

# cross-over functions
func singlePCross() -> void:
	pass

func multiPCross() -> void:
	pass

func randomPCross() -> void:
	pass
