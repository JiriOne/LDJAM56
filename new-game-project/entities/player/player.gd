extends CharacterBody2D
class_name Player

# -------- Interfaced Variables -----------
var move_conditional : Callable
var attack_conditional : Callable
var movement_action : Callable
var shadow_texture : CompressedTexture2D
# -----------------------------------------

# Grid System Reference
var grid_system

@export var selected : bool = false
@export var gridPosition : Vector2 = Vector2.ZERO
@export var attackDamage = 50
@export var hp = 100

var available_targets : Array[Vector2]
@onready var on_screen_notifier = $VisibleOnScreenNotifier2D

@onready var globalUtil = get_node("/root/GlobalUtil")
@onready var controller = get_node("/root/Controller")
@onready var animationPlayer = $AnimationPlayer
@onready var health_bar: TextureProgressBar = $CanvasGroup/HealthBar
@onready var attack_1: AudioStreamPlayer2D = $attack_1
@onready var attack_2: AudioStreamPlayer2D = $attack_2
@onready var attack_3: AudioStreamPlayer2D = $attack_3
@onready var walk: AudioStreamPlayer2D = $walk
@onready var keysound: AudioStreamPlayer2D = $keysound



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
	grid_system.initialize()
	set_grid_pos(gridPosition)
	var movement_file = FileAccess.open(self.get_script().get_path().get_base_dir() + "/movement.txt", FileAccess.READ)
	var available_targets_text = movement_file.get_as_text()
	available_targets = translate_targets(available_targets_text)

# make player grey is turn_taken
func _process(delta: float) -> void:
	if self not in Controller.party:
		$CanvasGroup/Sprite2D.modulate = Color(1, 0, 0)
	else:
		if turn_taken:
			$CanvasGroup/Sprite2D.modulate = Color(0.5, 0.5, 0.5)
		else:
			$CanvasGroup/Sprite2D.modulate = Color(1, 1, 1)

func _physics_process(delta: float) -> void:
	
	#check if close to player in party and if so, join the party
	if self not in Controller.party:
		
		var closest_party_member = get_closest_party_member()
		
		
		if closest_party_member and self.position.distance_to(closest_party_member.position) < 23:
			Controller.party.append(self)
			health_bar.value = hp
			
			var game_win = true
			for member in get_tree().get_nodes_in_group("player_character"):
				print(member)
				if member not in Controller.party:
					print("not in party")
					game_win = false
			
			if game_win == true:
				Controller.game_win.emit()		
	
	match current_state:
		self.State.MOVING_TO_ENEMY:
			position = lerp(position, current_attack_pos, 0.1 * delta * pos_before_move.distance_to(current_attack_pos))
		self.State.MOVING_FROM_ENEMY:
			position = lerp(position, pos_before_move, 0.2 * delta * pos_before_move.distance_to(current_attack_pos))
			if pos_before_move.distance_squared_to(position) < 0.1:
				current_state = self.State.IDLE
				turn_taken = true

func get_closest_party_member() -> Player:
	var closest_party_member = null
	var closest_party_member_dist = 99999999
	for member in Controller.party:
		if member == self:
			continue
		var tmp_dist = member.position.distance_to(self.position)
		if tmp_dist < closest_party_member_dist:
			closest_party_member = member
			closest_party_member_dist = tmp_dist
	return closest_party_member

func set_grid_pos(pos) -> void:
	Controller.player_focused.emit(self)
	walk.play()
	# Remove from old cell in the grid system
	var data_old : GridCellData = grid_system.get_cell_data(gridPosition)
	data_old.has_player = false
	
	# Set world pos
	self.position = globalUtil.grid_to_world(pos)
	gridPosition = pos
	# Make update in the grid system
	var data : GridCellData = grid_system.get_cell_data(pos)
	data.has_player = true
	data.player = self
	
	# Collect key
	if data.has_key:
		keysound.play()
		Controller.key_collected.emit()
		data.key.queue_free()
		data.has_key = false
	
	if data.has_heart:
		data.heart.queue_free()
		data.has_heart = false
		self.hp = 100
		health_bar.value = hp	
			
	# Unlock door
	if data.type == GlobalTypes.Cell_Type.DOOR:
		grid_system.unlock_door(pos)
	
	if data.has_molshoop:
		var otherMolshoopPos = data.molshoop.other_pos
		self.position = globalUtil.grid_to_world(otherMolshoopPos)
		gridPosition = otherMolshoopPos
	
	# Call actions if they are defined by the character
	if movement_action:
		movement_action.call(data_old, data)

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
	var rand_attack_sound = randi_range(0,2)
	match rand_attack_sound:
		0:
			attack_1.play()
		1:
			attack_2.play()
		2:
			attack_3.play()
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
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT and current_state == State.IDLE and turn_taken == false and controller.player_turn == true and self in Controller.party:
			var plys = get_tree().get_nodes_in_group("player_character")
			for ply in plys:
				if ply == self:
					Controller.player_focused.emit(self)
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
	hide_targets()
	selected = false

func hurt(dp):
	hp = hp - dp
	health_bar.value = hp
	if hp <= 0:
		self.die()
		

func die():
	var next_player = get_closest_party_member()
	
	if !next_player:
		Controller.game_over.emit()
	else:
		Controller.player_focused.emit(next_player)
		Controller.party.erase(self)
		queue_free()
