extends Control

const player_compass_doodle = preload("res://ui/overlays/player_compass/player_compass_doodle.tscn")
var player_doodles : Dictionary

func _ready() -> void:
	var plys = get_tree().get_nodes_in_group("player_character")
	for ply : Player in plys:
		ply.on_screen_notifier.screen_entered.connect(_on_player_screen_enter.bind(ply))
		ply.on_screen_notifier.screen_exited.connect(_on_player_screen_exit.bind(ply))

func _process(delta: float) -> void:
	#var party = Controller.party
	for doodle in player_doodles.keys():
		#pivot_offset
		var center_to_player = player_doodles.get(doodle).position - get_viewport().get_camera_2d().get_screen_center_position()
		var screen_width = get_viewport_rect().size.x
		var screen_height = get_viewport_rect().size.y
		var screen_edge_position = Vector2(screen_width / 2 + center_to_player.normalized().x * 130, screen_height / 2 + center_to_player.normalized().y * 75)
		doodle.position = screen_edge_position + Vector2(0, -8)
		doodle.get_node("AnimatedSprite2D").frame = (2 if center_to_player.x < 0 else 0) + (1 if center_to_player.y > 0.01 else 0)

func _on_player_screen_enter(ply : Player):
	if ply in Controller.party:
		var doodle = player_doodles.find_key(ply)
		if doodle:
			player_doodles.erase(doodle)
			doodle.queue_free()
	
func _on_player_screen_exit(ply : Player):
	if ply in Controller.party:
		var doodle = player_compass_doodle.instantiate()
		add_child(doodle)
		doodle.gui_input.connect(_on_doodle_input.bind(ply))
		player_doodles.get_or_add(doodle, ply)

func _on_doodle_input(event : InputEvent, ply : Player) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if ply:
				Controller.player_focused.emit(ply)
