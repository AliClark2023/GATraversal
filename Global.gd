extends Node
# hold variables for genetic algorithm to use and for display
# doesnt reset when reloading the scene, add to auto load in settings

var bestDNA
var bestFit: float = 1000000.0
var generationNum: int = 0
