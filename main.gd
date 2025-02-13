extends Node
var score = 0  # 分数
var killed_count = 0  # 击毁石头的数量
var game_active = true  # 游戏状态标志
var ball_scene = preload("res://ball.tscn")  # 加载球对象场景
var timer_interval = 1.0  # 初始生成间隔

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
	$CanvasLayer/ScoreLabel.text = "score: " + str(score) + "\n" + "killed: " + str(killed_count)

# 点击加分逻辑
func _on_ball_clicked():
	if !game_active: 
		return
	score += 1
	killed_count += 1
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
	$CanvasLayer/GameOverLabel.visible = true
	$CanvasLayer/RestartButton.visible = true

	
# 每次 Timer 触发时生成一个球
func _on_timer_timeout():
	if !game_active:
		# 游戏暂停不触发
		return

	spawn_ball()


func _on_restart_button_pressed():
	print("restart")
	game_active = true
	$CanvasLayer/GameOverLabel.visible = false
	$CanvasLayer/RestartButton.visible = false
	score = 0
	killed_count = 0
	update_ui()
	timer_interval = 1
	$Timer.wait_time = 1
	$Timer.start()
	
	pass # Replace with function body.
