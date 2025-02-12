extends Node
var score = 0  # 分数
var game_active = true  # 游戏状态标志
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
	ball.connect("ball_clicked", Callable(self, "_on_ball_clicked"))
	ball.connect("ball_expired", Callable(self, "_on_ball_expired"))

func update_ui():
	$CanvasLayer/ScoreLabel.text = "Score: %d" % score
# 点击加分逻辑
func _on_ball_clicked():
	if !game_active: 
		return
	score += 1
	update_ui()
	# 动态调整球生成速度
	timer_interval = max(0.2, timer_interval * 0.95)  # 每次减少生成间隔
	$Timer.wait_time = timer_interval

# 自然消失扣分逻辑
func _on_ball_expired():
	if !game_active: 
		return
	score -= 2  # 扣分幅度大于加分
	update_ui()
	
	# 游戏结束条件
	if score <= 0:
		game_over()

func game_over():
	game_active = false
	$Timer.stop()
	get_tree().paused = true
	$CanvasLayer/GameOverLabel.visible = true

# 每次 Timer 触发时生成一个球
func _on_timer_timeout():
	if get_tree().paused:  # 如果游戏暂停，不生成球
		return

	#if get_node("/root/VisibleBallCount").get_child_count() >= max_balls:
		#return  # 如果球数量达到上限，则不生成新球

	spawn_ball()
