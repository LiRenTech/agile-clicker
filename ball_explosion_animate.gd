extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("animation_finished", _on_animation_finished)
	play("explode", 1.0, false)  # 如果未启用 Autoplay 时使用

func _on_animation_finished():
	get_parent().queue_free()  # 动画完成后自动销毁父节点

