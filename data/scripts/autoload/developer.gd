extends Node

func print_verbose(text):
	if OS.is_debug_build():
		print(text)