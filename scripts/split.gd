extends Node2D

var speed = Vector2(5, 5)

# Called when the node enters the scene tree for the first time.
# 标记此对象为小碎片
func _ready():
	set_meta("is_fragment", true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	self.position += speed
