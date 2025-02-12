extends Node2D

# 定义一个自定义信号，用于通知主场景球被点击
signal ball_expired  # 自然消失扣分信号
signal ball_clicked  # 点击加分信号

@export var shrink_speed: float = 0.2  # 缩小速度（可在 Inspector 调整）

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("ball_clicked")
		queue_free()
