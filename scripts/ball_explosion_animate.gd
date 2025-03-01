extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("animation_finished", _on_animation_finished)
	play("explode", 1.0, false) # 如果未启用 Autoplay 时使用
	
	var audioNode = get_parent().get_node("AudioStreamPlayer2D");
	# 随机音高
	audioNode.pitch_scale = randf_range(0.6, 1.5)
	audioNode.play()

func _on_animation_finished():
	get_parent().queue_free() # 动画完成后自动销毁父节点
