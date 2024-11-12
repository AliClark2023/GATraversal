extends Node2D

@onready var spawner = $SpawnFolder
@onready var goal = $Goal
@export var spawnAmount: int = 100
@export var genomeThreshold: float = 0.6
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
		Global.geneIdx = 0
		# next generation method goes here, contains
		# selection, crossover and mutation methods
		# method testing
		selectStrong()
		#selectWeak()
		for i in spawnAmount:
			var creature := preload("res://Scenes/creature.tscn").instantiate()
			creature.firstGen = false
			spawner.add_child(creature)
			Global.geneIdx += 1

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
		
	for i in spawnAmount:
		var genome = []
		for j in Global.genomeSize:
			genome.append(Vector2.ZERO)
		Global.nextGen.append([genome, 0.0])

# checks game state every timeout
func _on_timer_timeout() -> void:
	var numOfDead:int = 0
	# checks if all creatures are dead
	for creature in spawner.get_children():
		if !creature.alive:
			numOfDead += 1
			
	# debug
	#print("number of dead" + str(numOfDead))
	
	# determines best fitness when all creatures are dead lower = better
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

# uses a selection method, crossover, mutation to create next generation
func nextGenCreation() -> void:
	selectStrong()
	selectWeak()
	pass
	
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
		var distPercent: float = (distanceToGoal - Global.previousGen[i][1]) / distanceToGoal
		#print("global fitness" + str(Global.previousGen[i][1]))
		# strongest genome
		if distPercent > genomeThreshold:
			Global.nextGen[i] = Global.previousGen[i]
		# determine method for weak genomes
		else:
			for j in Global.genomeSize:
				var gene: Vector2 = Global.previousGen[i][0][j]
				var newX: float =  abs(Global.previousGen[i][0][j].x * 0.10);
				var newY: float =  abs(Global.previousGen[i][0][j].y * 0.10);
				var newGene = Vector2(randf_range(gene.x - newX, gene.x + newX), randf_range(gene.y - newY, gene.y + newY))
				Global.nextGen[i][0][j] = newGene
				pass
			pass
# some weak survive (50% of the weak), change to UI variable
func selectWeak() -> void:
	for i in Global.previousGen.size():
		var distPercent: float = (distanceToGoal - Global.previousGen[i][1]) / distanceToGoal
		#print("global fitness" + str(Global.previousGen[i][1]))
		# strongest genome
		if distPercent > genomeThreshold:
			Global.nextGen[i] = Global.previousGen[i]
		# selects 50% of the weaker genomes
		elif distPercent < genomeThreshold && randf() < 0.5:
			Global.nextGen[i] = Global.previousGen[i]
			pass
		# determine method for other weak genomes
		# randomises genome +- 10% of previous parent (add to UI)
		else:
			for j in Global.genomeSize:
				var gene: Vector2 = Global.previousGen[i][0][j]
				var newX: float =  abs(Global.previousGen[i][0][j].x * 0.10);
				var newY: float =  abs(Global.previousGen[i][0][j].y * 0.10);
				var newGene = Vector2(randf_range(gene.x - newX, gene.x + newX), randf_range(gene.y - newY, gene.y + newY))
				Global.nextGen[i][0][j] = newGene
				pass
			pass
	pass

# cross-over functions
func singlePCross() -> void:
	pass

func multiPCross() -> void:
	pass

func randomPCross() -> void:
	pass
