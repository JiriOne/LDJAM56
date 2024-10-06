extends Camera2D

@export var max_player_dist = 0.5
@export var move_speed = 150

@onready var level: Node2D = $".."
var focused_player : Player
var direction_modifier : Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.position.x = 32
	self.position.y = 32
	Controller.player_focused.connect(focus_on_player)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var ply = focused_player
	if ply:
		var target : Vector2 = ply.global_position
		if self.global_position.round() != target.round():
			self.position += self.global_position.direction_to(target) * delta * move_speed
		else:
			focused_player = null

func focus_on_player(ply : Player) -> void:
	focused_player = ply
	direction_modifier = (ply.global_position - self.global_position).normalized()
