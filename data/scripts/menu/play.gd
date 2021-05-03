extends Control

onready var title = Game.make_title("Play")
var selected_level
var level_name = ""
var level_description = ""
var level_coins_total = 0
var level_coins_required = 0
var level_game_time_max = 30.0
var level_info = {}


func init_level_list():
	for level in Levels.LIST:
		get_node("PlayPanel/OptionButton").add_item(level[0])


func make_level_info_bbcode(name, description, coins_total, coins_required, game_time_max):
	get_node("PlayPanel/LevelInformation").set_bbcode("[b]" + tr("LevelDescription") + "[/b][indent]" + str(description) + "[/indent]\n\n[b]" + tr("LevelGameTimeMax") + "[/b] " + str(game_time_max) + " seconds\n[b]" + tr("LevelCoinsTotal") + "[/b] " + str(coins_total) + "\n[b]" + tr("LevelCoinsRequired") + "[/b] " + str(coins_required))


func _ready():
	get_node("PlayPanel/RichTextLabel").set_bbcode(title)
	# Select the first level in the list automatically
	selected_level = 0
	init_level_list()

	# Fill in the level information (for display in the menu and music playback)
	level_info = Game.read_level_information(selected_level)
	level_name = level_info["name"]
	level_description = level_info["description"]
	level_game_time_max = level_info["game_time_max"]
	level_coins_total = level_info["coins_total"]
	level_coins_required = level_info["coins_required"]
	# Store music name for playing later, when the player clicks "Play"
	Game.music_pending = level_info["music"]
	make_level_info_bbcode(level_name, level_description, level_coins_total, level_coins_required, level_game_time_max)


func _on_Button_pressed():
	Game.start_game(selected_level)


# Update the information, when player selects another level from GUI
func _on_OptionButton_item_selected(ID):
	selected_level = ID
	level_info = Game.read_level_information(ID)
	level_name = level_info["name"]
	level_description = level_info["description"]
	level_game_time_max = level_info["game_time_max"]
	level_coins_total = level_info["coins_total"]
	level_coins_required = level_info["coins_required"]
	# Store music name for playing later, when the player clicks "Play"
	Game.music_pending = level_info["music"]
	make_level_info_bbcode(level_name, level_description, level_coins_total, level_coins_required, level_game_time_max)
