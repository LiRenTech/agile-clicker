extends Node2D

# 定义一个自定义信号，用于通知主场景球被点击
signal ball_destroyed  # 将信号定义在根节点

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
# 暴露Area2D的输入事件到根节点
func _ready():
	$Area2D.input_event.connect(_on_Area2D_input_event)

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("ball_destroyed")
		queue_free()
