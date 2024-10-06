extends CharacterBody2D
class_name Player

# -------- Interfaced Variables -----------
var move_conditional : Callable
var attack_conditional : Callable
var shadow_texture : CompressedTexture2D
# -----------------------------------------

# Grid System Reference
var grid_system

signal player_selected

@export var selected : bool = false
@export var gridPosition : Vector2 = Vector2.ZERO
@export var attackDamage = 15


var available_targets : Array[Vector2]

@onready var globalUtil = get_node("/root/GlobalUtil")
@onready var controller = get_node("/root/Controller")
@onready var animationPlayer = $AnimationPlayer

var current_attack_cell : GridCellData
var current_attack_pos : Vector2
var pos_before_move : Vector2
var turn_taken : bool = false

enum State {
	IDLE,
	MOVING_TO_ENEMY,
	MOVING_FROM_ENEMY
}

var current_state : State = State.IDLE

## Shadow stuff
var move_shadows : Array
var move_shadow_scene = preload("res://entities/move_shadow/move_shadow.tscn")
var valid_move_targets : Array[GridCellData]
var attack_shadows : Array
var attack_shadow_scene = preload("res://entities/attack_shadow/attack_shadow.tscn")
var valid_attack_targets : Array[GridCellData]

func _ready() -> void:
	grid_system = get_parent()
	await grid_system.grid_initialized
	Controller.party.append(self)
	set_grid_pos(gridPosition)
	var movement_file = FileAccess.open(self.get_script().get_path().get_base_dir() + "/movement.txt", FileAccess.READ)
	var available_targets_text = movement_file.get_as_text()
	available_targets = translate_targets(available_targets_text)

func _physics_process(delta: float) -> void:
	match current_state:
		self.State.MOVING_TO_ENEMY:
			position = lerp(position, current_attack_pos, 0.1 * delta * pos_before_move.distance_to(current_attack_pos))
		self.State.MOVING_FROM_ENEMY:
			position = lerp(position, pos_before_move, 0.2 * delta * pos_before_move.distance_to(current_attack_pos))
			if pos_before_move.distance_squared_to(position) < 0.01:
				current_state = self.State.IDLE

func set_grid_pos(pos) -> void:
	# Remove from old cell in the grid system
	var data_old : GridCellData = grid_system.get_cell_data(gridPosition)
	data_old.has_player = false
	grid_system.update_cell(data_old)
	# Set world pos
	self.position = globalUtil.grid_to_world(pos)
	gridPosition = pos
	# Make update in the grid system
	var data : GridCellData = grid_system.get_cell_data(pos)
	data.has_player = true
	data.player = self
	grid_system.update_cell(data)

func translate_targets(available_targets_text) -> Array[Vector2]:
	var lines : PackedStringArray = available_targets_text.split("\n", false)
	var lineLength = len(lines[0])
	var result : Array[Vector2] = []
	var origin = Vector2(-int(floor(lineLength / 2)), -int(floor(lines.size() / 2)))
	for linenum in range(lines.size()):
		var line = lines[linenum]
		assert(len(line) == lineLength, "Move targets text is WRONG")
		for i in range(len(line)):
			var c = line[i]
			match c:
				'x':
					result.append(origin + Vector2(linenum, i))
	return result

func show_targets() -> void:
	var move_targets : Array[Vector2]
	valid_move_targets = grid_system.calc_valid_targets(self.gridPosition, available_targets, move_conditional)
	valid_attack_targets = grid_system.calc_valid_targets(self.gridPosition, available_targets, attack_conditional)
	for target in valid_move_targets:
		var new_ms = move_shadow_scene.instantiate()
		new_ms.set_texture(shadow_texture)
		new_ms.position = globalUtil.grid_to_world(target.pos)
		move_shadows.append(new_ms)
		grid_system.add_child(new_ms)
		new_ms.connect("request_move_here", _on_move_request)
	for target in valid_attack_targets:
		var new_as = attack_shadow_scene.instantiate()
		new_as.position = globalUtil.grid_to_world(target.pos)
		attack_shadows.append(new_as)
		grid_system.add_child(new_as)
		new_as.connect("request_attack_here", _on_attack_request)

func hide_targets() -> void:
	for shadow in move_shadows:
		shadow.queue_free()
	move_shadows.clear()
	for shadow in attack_shadows:
		shadow.queue_free()
	attack_shadows.clear()

func start_attack(target_grid_pos) -> void:
	pos_before_move = self.position
	current_state = self.State.MOVING_TO_ENEMY
	current_attack_cell = grid_system.get_cell_data(target_grid_pos)
	current_attack_pos = globalUtil.grid_to_world(current_attack_cell.pos)
	animationPlayer.play("basic_attack_start")

func attack_current_target() -> void:
	if current_attack_cell.has_enemy:
		current_attack_cell.enemy.hurt(attackDamage)

func end_attack(target_grid_pos) -> void:
	if not current_attack_cell.has_enemy:
		current_state = self.State.IDLE
		set_grid_pos(current_attack_cell.pos)
	else:
		current_state = self.State.MOVING_FROM_ENEMY

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT and current_state == State.IDLE and turn_taken == false and controller.player_turn == true:
			var plys = get_tree().get_nodes_in_group("player_character")
			for ply in plys:
				if ply == self:
					self.selected = not self.selected
					if self.selected:
						show_targets()
					else:
						hide_targets()
				else:
					ply.hide_targets()
					ply.selected = false

func _on_move_request(grid_pos) -> void:
	self.set_grid_pos(grid_pos)
	turn_taken = true
	hide_targets()
	selected = false

func _on_attack_request(grid_pos) -> void:
	start_attack(grid_pos)
	turn_taken = true
	hide_targets()
	selected = false
