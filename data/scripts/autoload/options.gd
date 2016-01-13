extends Node

# The types available for options
const BOOL = 0
const INT = 1
const FLOAT = 2
const STRING = 3

# The dictionary containing options, their type and their default values
# TODO: Sanitize by type
var options = {
	#value: [section, type, default],
	"fps_max": ["video", INT, 60],
	"shadow_type": ["video", INT, 1],
	"sound_volume": ["audio", FLOAT, 1.0],
	"music_volume": ["audio", FLOAT, 0.6],
	"view_sensitivity": ["input", FLOAT, 2.5]
}

var value

# Initialize options. If the file does not exist, create it with the default values.
func init():
	var config = ConfigFile.new()
	var file = File.new()
	if not file.file_exists("user://veraball.ini"):
		# Write the default values
		for key in options:
			config.set_value(options[key][0], key, options[key][2])
		config.save("user://veraball.ini")
		Developer.print_verbose("veraball.ini not found, using defaults.")

# Get an option. If it is not defined in the configuration, get the default.
func get(section, key):
	var config = ConfigFile.new()
	config.load("user://veraball.ini")
	if config.get_value(section, key) == null:
		value = options[key][2]
		config.set_value(section, key, value)
	else:
		value = config.get_value(section, key)
	Developer.print_verbose("Get option: [" + str(section) + "] " + str(key) + "=" + str(value))
	return value

# Set an option
func set(section, key, value):
	var config = ConfigFile.new()
	config.load("user://veraball.ini")
	config.set_value(section, key, value)
	Developer.print_verbose("Set option: [" + str(section) + "] " + str(key) + "=" + str(value))
	config.save("user://veraball.ini")