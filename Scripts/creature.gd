extends Area2D
var alive:bool = false
var firstGen:bool = true
var speed: float = Global.creatureSpeed
var genome =[]
var gene: int = 0;
# fitness is distance to goal (lower = better)
var fitness: float = 0.0
var goal: Area2D
var genomeSize: int = 75

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# initialising genome
	if genome.size() == 0:
		for i in genomeSize:
			genome.append(Vector2.ZERO)
			
	# randomizes the games seed value for later use
	randomize()
	
	# requires creature to be within another node and goal to be attached root node
	goal = get_parent().get_parent().get_node("Goal")
	
	## original code from https://www.youtube.com/watch?v=TMztBMRGrOQ&t=1218s
	## writing the genome
	## first gen
	#if Global.bestDNA == null:
		#for i in genomeSize:
			#var v:= Vector2(randi_range(-1,1), randi_range(-1,1)).normalized() * speed
			#genome[i] = v
	## later generations
	#else:
		#for i in genomeSize:
			#var rdm: float = randf()
			#if rdm < mutationChance:
				#var v:= Vector2(randi_range(-1,1), randi_range(-1,1)).normalized() * speed
				#genome[i] = v
			#else:
				#genome[i] = Global.bestDNA[i]
	
	# modified code
	randomize()
	# checks if it is first gen
	if firstGen:
		for i in genomeSize:
			var v:= Vector2(randi_range(-1,1), randi_range(-1,1)).normalized() * speed
			genome[i] = v
	# other generations, get from global array
	else:
		genome = Global.nextGen[Global.geneIdx][0]
		pass

# moves creature according to its genome (dies when reached the end of genome)
func _physics_process(delta: float) -> void:
	if alive and gene < genome.size():
		global_position += genome[gene]
	else:
		#alive = false
		die()

# calculates fitness
func die() -> void:
	if alive:
		# calculates how far creature is away from goal
		alive = false
		if Global.eFitness:
			#print("euc fitness selected")
			fitness = _euclidean_fitness()
		else:
			#print("man fitness selected")
			fitness = _manhattan_fitness()

## calculates fitness with euclidean formula
func _euclidean_fitness() -> float:
	return global_position.distance_to(goal.global_position)

## calculates fitness with manhattan formula
func _manhattan_fitness() -> float:
	var goal: Vector2 = goal.global_position
	var creature: Vector2 = global_position
	var manFitness: float = abs(creature.x - goal.x) + abs(creature.y - goal.y) 
	return manFitness

# every tick will increase the index of the genome thus is position in game
func _on_timer_timeout() -> void:
	if alive:
		gene +=1
	else:
		die()

# collision with any object will cause it to die
func _on_body_entered(body: Node2D) -> void:
	#print("Collided with node")
	if body:
		die()

func _on_area_entered(area: Area2D) -> void:
	#print("Collided with area")
	if area.is_in_group("Goal"):
		#print("Collided with goal")
		Global.numReachedGoal += 1
		Global.totalReachedGoal += 1
		die()
