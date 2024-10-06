extends Camera2D

@onready var level: Node2D = $".."
@onready var player: CharacterBody2D = $"../GridSystem/Player"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.position.x = player.position.x
	self.position.y = player.position.y


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_right"):
		self.position.x += 150 * delta
	if Input.is_action_pressed("ui_left"):
		self.position.x -= 150 * delta
	if Input.is_action_pressed("ui_down"):
		self.position.y += 150 * delta
	if Input.is_action_pressed("ui_up"):
		self.position.y -= 150 * delta
