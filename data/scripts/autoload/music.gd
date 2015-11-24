extends Node

func play(music):
	var stream = load("res://data/music/" + str(music) + ".opus")
	get_node("StreamPlayer").set_stream(stream)
	get_node("StreamPlayer").play()