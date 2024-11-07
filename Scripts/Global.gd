extends Node
# hold variables for genetic algorithm to use and for display
# doesnt reset when reloading the scene, add to auto load in settings
# need to manually rest if using multiple simulation scenes

var genomeSize: int = 75
var creatureSpeed: float = 20.0

var bestDNA
var bestFit: float = 1000000.0
var generationNum: int = 0
var previousGen=[]
