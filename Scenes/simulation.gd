extends Node2D

@onready var spawner = $SpawnFolder
@onready var goal = $Goal
@export var spawnAmount: int = 100
@export var genomeThreshold: float = 0.6
@export var distanceToGoal: float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# remove if not needed
	distanceToGoal = ((spawner.global_position.distance_to(goal.global_position)))
	
	# initialse Generation arrays if not done so already
	if Global.previousGen.size() == 0:
		initialiseGenArray()
	Global.numReachedGoal = 0
	print ("Generation: " + str(Global.generationNum))
	spawnCreatures()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func spawnCreatures() ->void:
	# other generations
	if Global.bestDNA:
		Global.geneIdx = 0
		## next generation method goes here, contains
		## selection, crossover and mutation methods
		
		# method testing
		selectWeak()
		#singlePCross()
		#multiPCross()
		randomPCross()
		destMutation()
		
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
		print("Reached Goal" + str(Global.numReachedGoal))
		print("Closest distance" + str(Global.bestFit))
		get_tree().reload_current_scene()

## uses a selection method, crossover, mutation to create next generation
func nextGenCreation() -> void:
	## assign via UI
	var strongGenomes: bool = false;
	var weakerGenomes: bool = false;
	
	selectStrong()
	selectWeak()
	pass
	
# mutation functions (entire genome)

## keeps mutated genome regardless of fitness
func destMutation() -> void:
	## testing new method
	# make UI adjustable
	var mutationFactor: float = 0.15
	# each genome will have a % chance of mutating
	for i in spawnAmount:
		var rdm : float = randf()
		if rdm < mutationFactor:
			#print("mutating")
			# creation of new genome
			for j in Global.genomeSize:
				var v:= Vector2(randi_range(-1,1), randi_range(-1,1)).normalized() * Global.creatureSpeed
				Global.nextGen[i][0][j] = v

## needs to re calculate fitness, may not be possible given nature of program
func constructMutation() -> void:
	pass

## selection functions

## strongest survive
## will select genomes that are within a thresold of the best fitness
## or will create strong genome from best fit +- a percentage (available on UI)
func selectStrong() -> void:
	for i in spawnAmount:
		var strongThreshold: float = genomeThreshold * Global.bestFit
		var currentFitness: float = Global.previousGen[i][1]
		# geneome is passed on if fitness is within threshold
		if currentFitness > (Global.bestFit - strongThreshold) and currentFitness < (Global.bestFit + strongThreshold):
			Global.nextGen[i] = Global.previousGen[i]
		# genome is randomised from best fit genome?
		# genome is discarded and a new one is created?
		else:
			## randomised from best fit, make available on UI
			var bestFitVariance: float = 0.30
			for j in Global.genomeSize:
				var gene: Vector2 = Global.bestDNA[j]
				var newX: float =  abs(gene.x * bestFitVariance);
				var newY: float =  abs(gene.y * bestFitVariance);
				var newGene = Vector2(randf_range(gene.x - newX, gene.x + newX), randf_range(gene.y - newY, gene.y + newY))
				Global.nextGen[i][0][j] = newGene
		pass

## some weak survive (50% of the weak), change to UI variable
## strong selection based on same method on selectStrong
func selectWeak() -> void:
	var selectWeakChance :float = 0.5
	for i in spawnAmount:
		var rdm = randf()
		var strongThreshold: float = genomeThreshold * Global.bestFit
		var currentFitness: float = Global.previousGen[i][1]
		# strong geneome is passed on if fitness is within threshold
		if currentFitness > (Global.bestFit - strongThreshold) and currentFitness < (Global.bestFit + strongThreshold):
			Global.nextGen[i] = Global.previousGen[i]
		# selects 50% of the weaker genomes
		elif rdm < selectWeakChance:
			Global.nextGen[i] = Global.previousGen[i]
		# discards the rest and creates new genome
		else:
			## randomised from best fit, make available on UI
			var bestFitVariance: float = 0.30
			for j in Global.genomeSize:
				var gene: Vector2 = Global.bestDNA[j]
				var newX: float =  abs(gene.x * bestFitVariance);
				var newY: float =  abs(gene.y * bestFitVariance);
				var newGene = Vector2(randf_range(gene.x - newX, gene.x + newX), randf_range(gene.y - newY, gene.y + newY))
				Global.nextGen[i][0][j] = newGene

## cross-over functions (spawn amount and arrays need to be even numbered)
## crossover from a specified index point onwards (point to be adjusted in UI)
func singlePCross() -> void:
	for i in range(0, spawnAmount, 2):
		# assiging parents
		var parent1 = Global.nextGen[i][0]
		var parent2 = Global.nextGen[i+1][0]
		var child1 =  parent1.duplicate(true)
		var child2 = parent2.duplicate(true)
		
		# crossover point is around halfway along genome (adjust through UI)
		for j in range(Global.genomeSize/2, Global.genomeSize):
			var par1 = parent1[j]
			var par2 = parent2[j]
			
			child1[j] = par2
			child2[j] = par1
			#print("child1" + str(child1[j]))
			#print("child2" + str(child2[j]))
			pass
		
		# writing child to next gen array
		Global.nextGen[i][0] = child1
		Global.nextGen[i+1][0] = child2
		pass
	pass

## crossover between two index points (points to be adjusted in UI)
func multiPCross() -> void:
	for i in range(0, spawnAmount, 2):
		# assiging parents
		var parent1 = Global.nextGen[i][0]
		var parent2 = Global.nextGen[i+1][0]
		var child1 =  parent1.duplicate(true)
		var child2 = parent2.duplicate(true)
		## cross-overpoints (make Available in UI, between 0 and 75(genomesize))
		var indexStart: int = Global.genomeSize/5
		var indexEnd: int = Global.genomeSize/1.5
		
		# crossover point is around halfway along genome (adjust through UI)
		for j in range(indexStart, indexEnd):
			var par1 = parent1[j]
			var par2 = parent2[j]
			
			child1[j] = par2
			child2[j] = par1
			#print("child1" + str(child1[j]))
			#print("child2" + str(child2[j]))
			pass
		
		# writing child to next gen array
		Global.nextGen[i][0] = child1
		Global.nextGen[i+1][0] = child2
		pass
	pass

## crossover from a random index point onwards
func randomPCross() -> void:
	for i in range(0, spawnAmount, 2):
		# assiging parents
		var parent1 = Global.nextGen[i][0]
		var parent2 = Global.nextGen[i+1][0]
		var child1 =  parent1.duplicate(true)
		var child2 = parent2.duplicate(true)
		# creating random cross-over point
		var rdmIdx: float = randi_range(0, Global.genomeSize)
		
		# crossover point is around halfway along genome (adjust through UI)
		for j in range(rdmIdx, Global.genomeSize):
			var par1 = parent1[j]
			var par2 = parent2[j]
			
			child1[j] = par2
			child2[j] = par1
			#print("child1" + str(child1[j]))
			#print("child2" + str(child2[j]))
			pass
		
		# writing child to next gen array
		Global.nextGen[i][0] = child1
		Global.nextGen[i+1][0] = child2
		pass
