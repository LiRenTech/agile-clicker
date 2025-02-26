extends Node2D

# 定义一个自定义信号，用于通知主场景球被点击
signal ball_expired  # 自然消失扣分信号
signal ball_clicked  # 点击加分信号

@export var shrink_speed: float = 0.2  # 缩小速度（可在 Inspector 调整）
@export var attraction_strength: float = 100.0  # 引力强度


func _physics_process(delta):
	# 吸引力影响
	var mouse_pos = get_viewport().get_mouse_position()  # 获取鼠标位置
	var direction = (mouse_pos - position).normalized()  # 计算方向向量
	position += direction * self.attraction_strength * delta  # 根据引力更新位置
	
	# 持续缩小
	scale -= Vector2.ONE * shrink_speed * delta
	
	# 缩小到阈值时消失
	if scale.x <= 0.1:
		emit_signal("ball_expired")
		queue_free()
	pass
	
# 暴露Area2D的输入事件到根节点
func _ready():
	$Area2D.input_event.connect(_on_Area2D_input_event)

# 点击
func _on_Area2D_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("ball_clicked")
		queue_free()


func _on_area_2d_area_entered(area):
	if area.has_meta("is_fragment") and area.get_meta("is_fragment"):
		# emit_signal("collided_with_fragment", area)  # 发出信号
		print("Collided with fragment!")
	pass # Replace with function body.
