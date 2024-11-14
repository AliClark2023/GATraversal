extends VBoxContainer
## obtaining input refrences
@onready var rdmPointCross = $RandomPointCross
@onready var selection = $SelectionMethod
@onready var crossMethod = $CrossMethod
@onready var population = $Population/Input
@onready var generationLimit = $GenerationLimit/Input
@onready var bestFitTolerance = $BestFitTolerance/Input
@onready var mutationChance = $MutationChance/Input
@onready var crossoverChance = $CrossoverChance/Input

# Called when the node enters the scene tree for the first time.
## since scene resets after every generation, need to check status of the bool variables
func _ready() -> void:
	if Global.strongGenomes:
		selection.set_pressed_no_signal(true)
		selection.text = ("Strong Genomes")
	else:
		selection.set_pressed_no_signal(false)
		selection.text = ("Weak Genomes")
		
	if Global.singlePointCross:
		crossMethod.set_pressed_no_signal(true)
		crossMethod.text = ("Single Point Cross")
	else:
		crossMethod.set_pressed_no_signal(false)
		crossMethod.text = ("Multi Point Cross")
	
	if Global.randomPointCross:
		rdmPointCross.set_pressed_no_signal(true)
		crossMethod.set_disabled(true)
	else:
		rdmPointCross.set_pressed_no_signal(false)
		crossMethod.set_disabled(false)
	
	_defaultInputs()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
## sets all ui inputs to their default values, according to Global.gd
func _defaultInputs() -> void:
	population.set_value_no_signal(Global.creaturesToSpawn)
	generationLimit.set_value_no_signal(Global.generationLimit)
	bestFitTolerance.set_value_no_signal(Global.bestFitTolerance)
	mutationChance.set_value_no_signal(Global.mutationChance)
	crossoverChance.set_value_no_signal(Global.crossoverChance)
	pass
func _on_random_point_cross_pressed() -> void:
	Global.randomPointCross = !Global.randomPointCross
	pass # Replace with function body.

func _on_random_point_cross_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Global.randomPointCross = !Global.randomPointCross
		crossMethod.set_disabled(true)
	else:
		Global.randomPointCross = !Global.randomPointCross
		crossMethod.set_disabled(false)

	pass # Replace with function body.
	
func _on_selection_method_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Global.strongGenomes = !Global.strongGenomes
		selection.text = ("Strong Genomes")
	else:
		Global.strongGenomes = !Global.strongGenomes
		selection.text = ("Weak Genomes")
	pass # Replace with function body.


func _on_cross_method_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Global.singlePointCross = !Global.singlePointCross
		crossMethod.text = ("Single Point Cross")
	else:
		Global.singlePointCross = !Global.singlePointCross
		crossMethod.text = ("Multi Point Cross")
	pass # Replace with function body.
