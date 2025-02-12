extends Node
var score = 0  # 分数
var ball_scene = preload("res://ball.tscn")  # 加载球对象场景
var timer_interval = 1.0  # 初始生成间隔
var max_balls = 5  # 最大同时存在的球数量

# 初始化
func _ready():
	print("ready")
	$Timer.start()  # 开始生成球
	print("start!")
	

# 生成一个随机位置的球
func spawn_ball():
	var ball = ball_scene.instantiate()
	add_child(ball)

	# 设置随机位置
	var screen_size = get_viewport().size
	var random_pos = Vector2(
		randi() % int(screen_size.x),
		randi() % int(screen_size.y)
	)
	ball.position = random_pos
	# 连接球消失时的信号
	ball.connect("ball_destroyed", Callable(self, "_on_Ball_destroyed"))



# 当球被点击并移除时增加分数
func _on_Ball_destroyed():
	print("on ball destory")
	score += 1
	$CanvasLayer/ScoreLabel.text = "Score: " + str(score)

	# 动态调整球生成速度
	timer_interval = max(0.2, timer_interval * 0.95)  # 每次减少生成间隔
	$Timer.wait_time = timer_interval

# 游戏结束逻辑
func game_over():
	get_tree().paused = true  # 暂停游戏
	print("Game Over! Final Score: ", score)

# 每次 Timer 触发时生成一个球
func _on_timer_timeout():
	if get_tree().paused:  # 如果游戏暂停，不生成球
		return

	#if get_node("/root/VisibleBallCount").get_child_count() >= max_balls:
		#return  # 如果球数量达到上限，则不生成新球

	spawn_ball()
