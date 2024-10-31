extends Area2D
var original:bool = false
var alive:bool = false
#var died:bool = false
var speed: float = 20.0
var genome =[]
var gene: int = 0;
var fitness: float = 0.0
var goal: Area2D
var genomeSize: int = 75
var mutAmnt: float = 0.05


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# initialising genome
	for i in genomeSize:
		genome.append(Vector2.ZERO)
	# randomizes the games seed value for later use
	randomize()
	
	# requires creature to be within another node and goal to be attached root node
	goal = get_parent().get_parent().get_node("Goal")
	
	# writing the genome
	# first gen
	if Global.bestDNA == null:
		for i in genomeSize:
			var v:= Vector2(randi_range(-1,1), randi_range(-1,1)).normalized() * speed
			genome[i] = v
	# later generations
	else:
		# 5% change to randomly generate new gene, otherwise apply best gene
		for i in genomeSize:
			if randf() < mutAmnt:
				var v:= Vector2(randi_range(-1,1), randi_range(-1,1)).normalized() * speed
				genome[i] = v
			else:
				genome[i] = Global.bestDNA[i]
	

func _physics_process(delta: float) -> void:
	if alive and gene < genome.size():
		global_position += genome[gene]
	else:
		die()

func die() -> void:
	# calculates how far creature is away from goal
	fitness = ((global_position.distance_squared_to(goal.global_position)))
	pass

# every tick will increase the index of the genome thus is position in game
func _on_timer_timeout() -> void:
	if alive:
		gene +=1
	else:
		alive = false

# collision with any object will cause it to die
func _on_body_entered(body: Node2D) -> void:
	if body:
		alive = true

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("goal"):
		alive = true
