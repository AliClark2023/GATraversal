extends Node
# hold variables for genetic algorithm to use and for display
# doesnt reset when reloading the scene, add to auto load in settings
# need to manually rest if using multiple simulation scenes

var genomeSize: int = 75
var bestDNA
var bestFit: float = 1000000.0
var generationNum: int = 0
var previousGen=[]
var nextGen=[]
var geneIdx: int = 0
var numReachedGoal: int = 0
var creatureSpeed: float = 20.0

## UI variables to be created and used
## generation features
var generationLimit: int = 40
var creaturesToSpawn: int = 40
var bestFitTolerance: float = 0.6
## operation selection (done)
var strongGenomes: bool = false
var singlePointCross: bool = false
var randomPointCross: bool = false
## operation chances
var mutationChance: float = 0.01
var crossoverChance: float = 0.5
