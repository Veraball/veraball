extends Node

# The types available for options
const INT = 0
const FLOAT = 1
const STRING = 2

# The dictionary containing options, their type and their default values
# TODO: Sanitize by type
var options = {
	#value: [section, type, default],
	"fps_max": ["renderer", INT, 60],
	"shadow_type": ["renderer", INT, 1],
	"view_sensitivity": ["input", FLOAT, 0.15],
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
		print("veraball.ini not found, using defaults.")

# Get an option. If it is not defined in the configuration, get the default.
func get(section, key):
	var config = ConfigFile.new()
	config.load("user://veraball.ini")
	if config.get_value(section, key) == null:
		value = options[key][2]
	else:
		value = config.get_value(section, key)
	# print("Get option: [" + section + "] " + key + "=" + str(value))
	return value

# Set an option
func set(section, key, value):
	var config = ConfigFile.new()
	config.load("user://veraball.ini")
	config.set_value(section, key, value)
	# print("Set option: [" + section + "] " + key + "=" + str(value))
	config.save("user://veraball.ini")