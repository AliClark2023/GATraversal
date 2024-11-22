extends Node2D

@onready var spawner = $SpawnFolder
@onready var goal = $Goal
## replace with global spawn number
@export var spawnAmount: int = Global.creaturesToSpawn
@export var genomeThreshold: float = Global.bestFitTolerance
var started: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	## only starts when user starts simulations
	if Global.startSimulation:
		started = true
		## initialse Generation arrays if not done so already
		if Global.previousGen.size() == 0:
			initialiseGenArray()
		spawnCreatures()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.startSimulation and started == false:
		started = true
		## initialse Generation arrays if not done so already
		if Global.previousGen.size() == 0:
			## needed to update spawn amount when starting simulation
			spawnAmount = Global.creaturesToSpawn
			initialiseGenArray()
			initialiseResultArray()
			
		spawnCreatures()
	pass


func spawnCreatures() ->void:
	Global.numReachedGoal = 0
	#print ("Generation: " + str(Global.generationNum))
	# other generations
	if Global.bestDNA:
		## reset index, to be used in creature creation for gen2 onwards
		Global.geneIdx = 0
		
		## creates next gen based on simulation results
		nextGenCreation()
		
		## spawns creatures with info from next gen array
		for i in spawnAmount:
			var creature := preload("res://Scenes/creature.tscn").instantiate()
			creature.firstGen = false
			spawner.add_child(creature)
			Global.geneIdx += 1
		
		## sets each creature alive
		for creature in spawner.get_children():
			creature.alive = true
	## first generation
	else:
		for i in spawnAmount:
			var creature := preload("res://Scenes/creature.tscn").instantiate()
			creature.firstGen = true
			creature.alive = true
			spawner.add_child(creature)

## initialises global arrays
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

## initialise result array
func initialiseResultArray() ->void:
	## creating header row
	Global.simResults = [["Population number","Generation limit", "Fitness type",
	"Selection type", "Crossover type", " Crossover chance", "Mutation chance",
	"Average fitness (sim)", "Average fitness (gen)", "End Condition", "Finished on Gen"],
	[0, 0, "", "", "", 0.0, 0.0, 0.0, 0.0, "", 0]]
	
	pass
## checks game state every timeout (set to 1s)
## determines state of creatures
func _on_timer_timeout() -> void:
	if Global.startSimulation:
		
		#if (Global.generationNum >= Global.generationLimit):
			#Global.startSimulation = false
		## checks if all creatures are dead
		var numOfDead:int = 0
		for creature in spawner.get_children():
			if !creature.alive:
				numOfDead += 1
		if numOfDead == spawnAmount:
			## debug
			##print("number of dead" + str(numOfDead))
			var bestFitnessSoFar:float = 10000000.0
			var idOfBestFit: int = 0
		
			for i in spawner.get_child_count():
				var fitness: float = spawner.get_child(i).fitness
				if fitness < bestFitnessSoFar:
					idOfBestFit = i
					bestFitnessSoFar = fitness
				
				## adding to previous gen array
				for j in spawner.get_child(i).genomeSize:
					Global.previousGen[i][0][j] = spawner.get_child(i).genome[j]
					Global.previousGen[i][1] = fitness

			if Global.bestFit > bestFitnessSoFar:
				Global.bestFit = bestFitnessSoFar
				Global.bestDNA = spawner.get_child(idOfBestFit).genome
				
			## Staticstic calculations
			_calculateAverageFitnessGen()
			
			## end conditions
			if genLimitReached():
				Global.endCondition = "Generation limit was met"
				Global.startSimulation = false
			elif !averageImproved():
				Global.endCondition = "Average fitness did not improve"
				Global.startSimulation = false
			elif goalReachedTest():
				Global.endCondition = "Majority of creatures reached goal"
				Global.startSimulation = false
			else:
				## go to next generation
				Global.generationNum +=1
				get_tree().reload_current_scene()

## end points of simulation
##
## returns true when generation average is passed a set threshold (5%)
## or number of failed generations is below the genFail threshold (10% of allowed generation) in a row
func averageImproved() -> bool:
	var threshold: float = 5.0
	var improvement: float = ((Global.prevAvgFitessGen - Global.averageFitnessGen) / Global.prevAvgFitessGen) * 100
	if improvement >= threshold:
		## resets fail number
		Global.genFailedNum = 0
		return true
	else:
		Global.genFailedNum +=1
		print("Gen failed num: " + str(Global.genFailedNum))
	
	var genFailThreshold: float = 0.1 * Global.generationLimit
	if Global.genFailedNum > genFailThreshold:
		return false
	else:
		return true

## returns true when a majority (60%) of creatures hit the end goal
func goalReachedTest() -> bool:
	var threshold: float = 0.6
	var target: float = Global.creaturesToSpawn * threshold
	if Global.numReachedGoal >= target:
		return true
	return false

## returns true if the generation limit has been reached
func genLimitReached() -> bool:
	if (Global.generationNum >= Global.generationLimit):
		return true
	return false

## statistic calculations
##
func _calculateAverageFitnessGen() ->void:
	var totalFitness: float = 0.0
	for i in spawner.get_child_count():
			var fitness: float = spawner.get_child(i).fitness
			totalFitness += fitness

	var avgFitness: float = totalFitness / Global.creaturesToSpawn

	## setting previous average
	Global.prevAvgFitessGen = Global.averageFitnessGen
	## setting current average
	Global.averageFitnessGen = avgFitness
	pass

## uses a selection method, crossover, mutation to create next generation
func nextGenCreation() -> void:
	## assign via UI
	var strongGenomes: bool = Global.strongGenomes
	var singlePointCross: bool = Global.singlePointCross
	var randomPointCross: bool = Global.randomPointCross
	
	## selection method
	if strongGenomes:
		selectStrong()
	else:
		selectWeak()
		
	if randomPointCross:
		randomPCross()
	else:
		if singlePointCross:
			singlePCross()
		else:
			multiPCross()
			
	## has chance to mutate within function
	destMutation()

## mutation functions (entire genome)
## keeps mutated genome regardless of fitness
func destMutation() -> void:
	# make UI adjustable
	var mutationChance: float = 0.01
	# each genome will have a % chance of mutating
	for i in spawnAmount:
		var rdm : float = randf()
		if rdm < mutationChance:
			#print("mutating")
			# creation of new genome or mutate part of genome?
			for j in Global.genomeSize:
				var v:= Vector2(randi_range(-1,1), randi_range(-1,1)).normalized() * Global.creatureSpeed
				Global.nextGen[i][0][j] = v

## needs to re calculate fitness, may not be possible given nature of program
func constructMutation() -> void:
	pass

## selection functions
##
## strongest survive
## will select genomes that are within a thresold of the best fitness
## or will create strong genome from best fit +- a percentage (available on UI)
func selectStrong() -> void:
	#print("selecting strong")
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
	#print("selecting weak")
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
## chance of crossover to occur (adhusted through UI)
func singlePCross() -> void:
	#print("Single Pcross enabled")
	var crossoverChance: float = 0.5
	for i in range(0, spawnAmount, 2):
		var rdm: float = randf()
		if rdm < crossoverChance:
			#print ("single P crossover")
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

## crossover between two index points (points to be adjusted in UI)
func multiPCross() -> void:
	#print("Multi Pcross enabled")
	var crossoverChance: float = 0.5
	for i in range(0, spawnAmount, 2):
		var rdm: float = randf()
		if rdm < crossoverChance:
			#print ("multi P crossover")
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
	#print("Random Pcross enabled")
	var crossoverChance: float = 0.5
	
	for i in range(0, spawnAmount, 2):
		var rdm: float = randf()
		if rdm < crossoverChance:
			#print ("random P crossover")
			# assiging parents
			var parent1 = Global.nextGen[i][0]
			var parent2 = Global.nextGen[i+1][0]
			var child1 =  parent1.duplicate(true)
			var child2 = parent2.duplicate(true)
			# creating random cross-over point
			var rdmIdx: float = randi_range(0, Global.genomeSize)
			
			# crossover point is randomly along genome
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
