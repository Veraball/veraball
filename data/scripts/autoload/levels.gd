extends Node

const LIST = [
	# ["Full Name", "filename", "environment"],
	["Basics", "basics", "day"],
	["Advanced Basics", "basics-2", "night"]
]


func is_night_level(id: int):
	return LIST[id][2] == "night"
