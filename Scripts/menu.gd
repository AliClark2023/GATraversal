extends VBoxContainer
#extends Control
## obtaining input refrences
@onready var fitnessType = $FitnessType
@onready var rdmPointCross = $RandomPointCross
@onready var selection = $SelectionMethod
@onready var crossMethod = $CrossMethod
@onready var population = $Population/PopInput
@onready var generationLimit = $GenerationLimit/GenInput
@onready var bestFitTolerance = $BestFitTolerance/FitInput
@onready var mutationChance = $MutationChance/MutInput
@onready var crossoverChance = $CrossoverChance/CrossInput
@onready var statsticText = $Stats
@onready var reachedGoal = $ReachedGoal
@onready var averageFitnessGen = $AverageFitnessGen
@onready var currentGen = $CurrentGen
@onready var simulationStart = $StartSimulation
@onready var simulationRestart = $RestartSimulation
@onready var endConditionStatus = $EndCondition

var writtenToFile: bool = false
var dataFile: String = "res://Data/data.csv"

# Called when the node enters the scene tree for the first time.
## since scene resets after every generation, need to check status of the bool variables
func _ready() -> void:
	_defaultInputs()
	if (Global.startSimulation):
		_disable_input()
		_show_stats()
		simulationRestart.set_disabled(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if simulationStart.disabled and !Global.startSimulation:
		endConditionStatus.visible = true
		endConditionStatus.text = Global.endCondition
		## write simulation result to file (only once, make bool)
		if !writtenToFile:
			writtenToFile = true
			## testing functions
			formatResults()
			save_to_csv(dataFile, Global.simResults)

## adds simulation data to array for saving later
func formatResults() -> void:
	var fitnessType: String = ""
	if Global.eFitness:
		fitnessType = "Euclidean fitness"
	else:
		fitnessType = "Manhattan fitness"
	
	var selectionType: String = ""
	if Global.strongGenomes:
		selectionType = "Strong Genomes Selected"
	else:
		selectionType = "Weak Genomes Selected"
		
	var crossoverType: String = ""
	if Global.singlePointCross:
		crossoverType = "Single Point Cross"
	elif !Global.singlePointCross and Global.randomPointCross:
		crossoverType = "Random Point Cross"
	else:
		crossoverType = "Multi-Point Cross"
	
	Global.simResults[1] = [Global.creaturesToSpawn, Global.generationLimit, fitnessType,
	selectionType, crossoverType, Global.crossoverChance, Global.mutationChance,
	 0.0, Global.averageFitnessGen, Global.endCondition, Global.generationNum]
	
	pass

## records result of simulation (appends to file)
func save_to_csv(file_path: String, data: Array) -> void:
	var file = FileAccess.open(file_path, FileAccess.READ_WRITE)
	if file:
		file.seek_end()
		for row in data:
			#file.store_string(str(row + ", "))  # Convert the row (Array) to a CSV row
			file.store_csv_line(row)
		file.close()
		print("Data written to:", file_path)
	else:
		print("Failed to open file:", file_path)

func clearResultFile(file_path: String, data: Array) -> void:
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		for row in data:
			file.store_string(" ")  # Convert the row (Array) to a CSV row
			##file.store_csv_line(row)
		file.close()
		print("Data cleared in:", file_path)
	else:
		print("Failed to open file:", file_path)
	
## sets all ui inputs to their default values, according to Global.gd
func _defaultInputs() -> void:
	if Global.eFitness:
		fitnessType.set_pressed_no_signal(false)
		fitnessType.text = ("Euclidean fitness")
	else:
		fitnessType.set_pressed_no_signal(true)
		fitnessType.text = ("Manhattan fitness")
		
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
		
	population.set_value_no_signal(Global.creaturesToSpawn)
	generationLimit.set_value_no_signal(Global.generationLimit)
	bestFitTolerance.set_value_no_signal(Global.bestFitTolerance)
	mutationChance.set_value_no_signal(Global.mutationChance)
	crossoverChance.set_value_no_signal(Global.crossoverChance)

## disables all GA input variables
func _disable_input() -> void:
	# toggle buttons
	fitnessType.set_disabled(true)
	selection.set_disabled(true)
	crossMethod.set_disabled(true)
	rdmPointCross.set_disabled(true)
	# float inputs
	population.editable = false
	generationLimit.editable = false
	bestFitTolerance.editable = false
	mutationChance.editable = false
	crossoverChance.editable = false
	# simulation buttons
	simulationStart.set_disabled(true)

## resets all variables for starting the simulation again
func _resetSimulation() -> void:
	Global.bestDNA = 0
	Global.genomeSize = 75
	Global.bestFit = 1000000.0
	Global.generationNum = 1
	Global.previousGen.clear()
	Global.nextGen.clear()
	Global.geneIdx = 0
	Global.startSimulation = false
	Global.simulationFinished = false
	Global.genFailedNum = 0
	get_tree().reload_current_scene()
	pass
## shows current statistics of the simulation
func _show_stats() -> void:
	statsticText.visible = true
	currentGen.visible = true
	currentGen.text =("Current Generation: " + str(Global.generationNum))
	reachedGoal.visible = true
	reachedGoal.text = ("Creatures that reached goal: " + str(Global.numReachedGoal))
	averageFitnessGen.visible = true
	averageFitnessGen.text = ("Average Fitness: " + str(Global.averageFitnessGen))
	
	pass
## signal events
##
func _on_fitness_type_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Global.eFitness = !Global.eFitness
		fitnessType.text = ("Manhattan fitness")
	else:
		Global.eFitness = !Global.eFitness
		fitnessType.text = ("Euclidean fitness")
	pass # Replace with function body.
	
func _on_random_point_cross_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Global.randomPointCross = !Global.randomPointCross
		crossMethod.set_disabled(true)
	else:
		Global.randomPointCross = !Global.randomPointCross
		crossMethod.set_disabled(false)

func _on_selection_method_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Global.strongGenomes = !Global.strongGenomes
		selection.text = ("Strong Genomes")
	else:
		Global.strongGenomes = !Global.strongGenomes
		selection.text = ("Weak Genomes")

func _on_cross_method_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Global.singlePointCross = !Global.singlePointCross
		crossMethod.text = ("Single Point Cross")
	else:
		Global.singlePointCross = !Global.singlePointCross
		crossMethod.text = ("Multi Point Cross")

func _on_pop_input_value_changed(value: float) -> void:
	Global.creaturesToSpawn = value

func _on_gen_input_value_changed(value: float) -> void:
	Global.generationLimit = value

func _on_fit_input_value_changed(value: float) -> void:
	Global.bestFitTolerance = value

func _on_mut_input_value_changed(value: float) -> void:
	Global.mutationChance = value

func _on_cross_input_value_changed(value: float) -> void:
	Global.crossoverChance = value

func _on_start_simulation_pressed() -> void:
	_disable_input()
	simulationRestart.set_disabled(false)
	Global.startSimulation = true
	
	## do not reset bool when simulation reset
	if !Global.programStarted:
		Global.programStarted = true
		clearResultFile(dataFile, Global.simResults)

func _on_end_program_pressed() -> void:
	get_tree().quit()

## will reset Global variables to be ready to restart the simulation
func _on_restart_simulation_pressed() -> void:
	_resetSimulation()
