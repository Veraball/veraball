extends Node

var list = [
	# ["Full Name", "filename", "environment"],
	["Basics", "basics", "day"],
	["Advanced Basics", "basics-2", "night"]
]

func is_night_level(ID):
	if list[ID][2] == "night":
		return true
	else:
		return false
