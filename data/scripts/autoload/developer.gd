extends Node

# Prints something only if running a debug build (editor, or debug-mode export
# template). Will not print in release-mode export templates.
func print_verbose(text):
	if OS.is_debug_build():
		print(text)
