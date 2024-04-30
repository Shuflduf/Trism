class_name ScoreTable
extends Resource

# https://tetris.wiki/Scoring

var soft_drop = 1
var hard_drop = 2

var basic = {
	1 : 100,
	2 : 300,
	3 : 500,
	4 : 800, #
}

var mini_tspin = {
	0 : 100,
	1 : 200, #
	2 : 400, #
}

var standard_tspin = {
	0 : 400,
	1 : 800, #
	2 : 1200, #
	3 : 1600, #
}

var perfect_clears = {
	1 : 800,
	2 : 1200,
	3 : 1800,
	4 : 2000,
	#b2b 4 : 3200,
}

# still need b2b difficult clears and combo
