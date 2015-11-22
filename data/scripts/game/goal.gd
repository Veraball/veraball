extends Spatial

var global
var goal_init_time = 0
var can_score_goal = false

func _ready():
	global = get_node("/root/Global")
	set_fixed_process(true)

func _fixed_process(delta):
	# HACK: Prevent non-moving bodies from triggering the goal (such as level geometry)
	goal_init_time += delta
	if goal_init_time >= 1:
		can_score_goal = true

func _on_Area_body_enter(body):
	if can_score_goal and global.coins >= global.coins_required:
		get_node("AnimationPlayer").play("LevelWon")
		global.clock_running = false
	# If player doesn't have the number of coins required
	elif can_score_goal:
		global.centerprint(tr("YouNeedNCoinsToFinish").replace("%s", str(global.coins_required - global.coins)))

func _on_AnimationPlayer_finished():
	# Reset game state at end of animation (3 seconds)
	global.reset_game_state()
