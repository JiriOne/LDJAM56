extends Camera2D

@onready var level: Node2D = $".."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.position.x = 160
	self.position.y = 160


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_right"):
		self.position.x += 3
	if Input.is_action_pressed("ui_left"):
		self.position.x -= 3
	if Input.is_action_pressed("ui_down"):
		self.position.y += 3
	if Input.is_action_pressed("ui_up"):
		self.position.y -= 3
