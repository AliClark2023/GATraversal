extends Node
# hold variables for genetic algorithm to use and for display
# doesnt reset when reloading the scene, add to auto load in settings
# need to manually rest if using multiple simulation scenes

var genomeSize: int = 75
var bestDNA
var bestFit: float = 1000000.0
var generationNum: int = 1
var previousGen=[]
var nextGen=[]
var geneIdx: int = 0
var creatureSpeed: float = 20.0
var startSimulation: bool = false
var simulationFinished: bool = false

## used as flag as indicator for first time running program
var programStarted: bool = false

## UI variables to be created and used
## generation features
var generationLimit: int = 40
var creaturesToSpawn: int = 40
var bestFitTolerance: float = 0.6
## operation selection (done)
var strongGenomes: bool = false
var singlePointCross: bool = false
var randomPointCross: bool = false
var eFitness: bool = true
## operation chances
var mutationChance: float = 0.01
var crossoverChance: float = 0.5
## used to determine how many generations failed to improve (reset with simulation)
var genFailedNum: int = 0

## display UI variables (use for data points)
var prevAvgFitessGen: float = 0
var averageFitnessGen: float = 0
var averageFitnessSim: float = 0
var numReachedGoal: int = 0
var totalReachedGoal: int = 0
var endCondition: String = ""
var simResults = []
