extends Node
var score = 0  # 分数
var killed_count = 0  # 击毁石头的数量
var game_active = true  # 游戏状态标志
var ball_scene = preload("res://scenes/ball.tscn")  # 加载球对象场景
var ball_explosion_scene = preload("res://scenes/ball_explosion.tscn")  # 加载球爆炸对象场景
var split_scene = preload("res://scenes/split.tscn")
var timer_interval = 1.0  # 初始生成间隔

var ball_shrink_speed = 0.15  # 当前难度下，小球掉落速度
const MAX_BALL_SHRINK_SPEED = 10
"""最快小球缩减速度"""

@export var suction_level = 0
@onready var score_label = $CanvasLayer/ScoreLabel

const GENERATE_PADDING = 100  
"""生成的边距"""
const MIN_GENERATE_INTERVAL = 0.4
"""最短生成间隔"""

# 初始化
func _ready():
	print("ready")
	var theme = preload("res://assets/fonts/unifont-16.0.02.otf")
	$CanvasLayer/RestartButton.theme = theme
	
	$Timer.start()  # 开始生成球
	print("start!")



# 生成一个随机位置的球
func spawn_ball():
	var ball = ball_scene.instantiate()
	ball.add_to_group("active_balls")
	add_child(ball)
	# 设置随机位置
	ball.position = get_random_position()
	ball.attraction_strength = suction_level
	ball.shrink_speed = ball_shrink_speed
	# 连接球消失时的信号
	ball.connect("ball_clicked", Callable(self, "_on_ball_clicked"))
	ball.connect("ball_expired", Callable(self, "_on_ball_expired"))

func get_random_position() -> Vector2:
	# 随机生成一个位置，尽量保证不重叠
	var random_pos = Vector2(
		randi_range(GENERATE_PADDING, 1920 - GENERATE_PADDING),
		randi_range(GENERATE_PADDING, 1080 - GENERATE_PADDING)
	)
	var balls = get_tree().get_nodes_in_group("active_balls")
	for ball in balls:
		if ball.position.distance_to(random_pos) < 100:
			# 距离太近，重新生成
			return get_random_position()
	return random_pos

func update_ui():
	score_label.text = "score: %d\nkilled: %d\ninterval: %.2f\nshrink_speed: %.2f" % [
		score,
		killed_count,
		timer_interval,
		ball_shrink_speed
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
	# 每次减少生成间隔
	timer_interval = max(MIN_GENERATE_INTERVAL, timer_interval * 0.95)
	if timer_interval <= MIN_GENERATE_INTERVAL:
		# 已经达到最小间隔，开始加快小球shrink速度
		# ball_shrink_speed = min(MAX_BALL_SHRINK_SPEED, ball_shrink_speed * 1.01)
		ball_shrink_speed *= 1.01
		print("加速掉落")
		pass
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
