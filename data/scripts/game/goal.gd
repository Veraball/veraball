extends Spatial

var goal_init_time = 0
var can_score_goal = false

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	# HACK: Prevent non-moving bodies from triggering the goal (such as level geometry)
	goal_init_time += delta
	if goal_init_time >= 1:
		can_score_goal = true
		goal_init_time = 1

func _on_Area_body_enter(body):
	if can_score_goal and Game.coins >= Game.coins_required:
		get_node("AnimationPlayer").play("LevelWon")
		Game.centerprint(tr("YouWin"))
		Game.clock_running = false
		Game.camera_follows_ball = false
		Game.acceleration_factor = 0.0
	# If player doesn't have the number of coins required
	elif can_score_goal:
		Game.centerprint(tr("YouNeedNCoinsToFinish").replace("%s", str(Game.coins_required - Game.coins)))

func _on_AnimationPlayer_finished():
	# Reset game state at end of animation (2.5 seconds)
	Game.restart_level()
