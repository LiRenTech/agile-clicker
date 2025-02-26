extends Node
var score = 0  # 分数
var killed_count = 0  # 击毁石头的数量
var game_active = true  # 游戏状态标志
var ball_scene = preload("res://ball.tscn")  # 加载球对象场景
var ball_explosion_scene = preload("res://ball_explosion.tscn")  # 加载球爆炸对象场景
var split_scene = preload("res://split.tscn")
var timer_interval = 1.0  # 初始生成间隔
var split_level = 0  # 击碎分裂等级
@export var suction_level = 0
@onready var score_label = $CanvasLayer/ScoreLabel

# 初始化
func _ready():
	print("ready")
	$Timer.start()  # 开始生成球
	print("start!")


# 生成一个随机位置的球
func spawn_ball():
	var ball = ball_scene.instantiate()
	ball.add_to_group("active_balls")
	add_child(ball)
	# 设置随机位置
	var screen_size = get_viewport().size
	var random_pos = Vector2(
		randi() % int(screen_size.x),
		randi() % int(screen_size.y)
	)
	ball.position = random_pos
	ball.attraction_strength = suction_level
	# 连接球消失时的信号
	ball.connect("ball_clicked", Callable(self, "_on_ball_clicked"))
	ball.connect("ball_expired", Callable(self, "_on_ball_expired"))

func update_ui():
	score_label.text = "score: %d\nkilled: %d\ninterval: %.2f\nsuction_level: %d" % [
		score,
		killed_count,
		timer_interval,
		suction_level
	]
	pass


# 点击击杀逻辑
func _on_ball_clicked(ball_dead_position, ball_dead_scale):
	if !game_active:
		return
	score += 1
	killed_count += 1
	update_ui()
	
	# 增加爆炸效果
	var ball_explosion = ball_explosion_scene.instantiate()
	add_child(ball_explosion)
	ball_explosion.position = ball_dead_position
	ball_explosion.scale = ball_dead_scale
	# 动态调整球生成速度
	timer_interval = max(0.016, timer_interval * 0.95)  # 每次减少生成间隔
	$Timer.wait_time = timer_interval

# 自然消失扣分逻辑
func _on_ball_expired():
	if !game_active:
		return
	score -= 2  # 扣分幅度大于加分
	update_ui()
	# 播放音效
	$ballEpired.pitch_scale = randf_range(0.6, 1.5)
	$ballEpired.play()
	
	# 游戏结束条件
	if score <= 0:
		game_over()

func game_over():
	game_active = false
	suction_level = 0
	split_level = 0
	$GameOver.play()
	$Timer.stop()
	var balls = get_tree().get_nodes_in_group("active_balls")
	
	# 批量删除
	for ball in balls:
		ball.queue_free()  # 安全删除节点
	# 可选：立即强制释放内存
	Engine.get_main_loop().process_frame  # 等待一帧
	RenderingServer.force_draw()          # 强制渲染刷新
	
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
