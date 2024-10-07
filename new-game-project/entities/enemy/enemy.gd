extends CharacterBody2D

@onready var globalUtil = get_node("/root/GlobalUtil")
@onready var healthBar = $CanvasGroup/HealthBar
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var grid_system
@export var gridPosition : Vector2 = Vector2.ZERO
@export var hp = 100
@export var damage = 20
var turn_taken : bool = false
var rng = RandomNumberGenerator.new()
var current_attack_cell : GridCellData
var current_attack_pos : Vector2
var pos_before_move : Vector2

enum State {
	IDLE,
	WALKING,
	AGGROED,
	MOVING_TO_PLAYER,
	MOVING_FROM_PLAYER
}

var current_state : State = State.IDLE

func start_attack(target_grid_pos) -> void:
	pos_before_move = self.position
	current_state = self.State.MOVING_TO_PLAYER
	current_attack_cell = grid_system.get_cell_data(target_grid_pos)
	current_attack_pos = globalUtil.grid_to_world(current_attack_cell.pos)
	animation_player.play("anim_enemy_attack")

func end_attack(target_grid_pos) -> void:
	if not current_attack_cell.has_player:
		current_state = self.State.IDLE
		set_grid_pos(current_attack_cell.pos)
	else:
		current_attack_cell.player.hurt(damage)
		current_state = self.State.MOVING_FROM_PLAYER

func set_grid_pos(pos) -> void:
	# Remove from old cell in the grid system
	var data_old : GridCellData = grid_system.get_cell_data(gridPosition)
	data_old.has_enemy = false
	# Set world pos
	self.position = globalUtil.grid_to_world(pos)
	gridPosition = pos
	# Make update in the grid system
	var data : GridCellData = grid_system.get_cell_data(pos)
	data.has_enemy = true
	data.enemy = self

func _ready() -> void:
	grid_system = get_parent()
	grid_system.initialize()
	position = globalUtil.grid_to_world(gridPosition)
	healthBar.value = hp
	Controller.enemies.append(self)

func hurt(dp):
	hp = hp - dp
	healthBar.value = hp
	if hp <= 0:
		self.die()

func die():
	var data : GridCellData = grid_system.get_cell_data(gridPosition)
	
	var enemy_list_idx = -1
	for idx in range(len(Controller.enemies)):
		if Controller.enemies[idx] == self:
			enemy_list_idx = idx
			break
	
	Controller.enemies.remove_at(enemy_list_idx)
	
	data.has_enemy = false
	queue_free()

func _process(delta: float) -> void:
	var smallest_distance_to_player = 1000000
	var target_player = null
	if Controller.player_turn == false and turn_taken == false and current_state != State.MOVING_TO_PLAYER and current_state != State.MOVING_FROM_PLAYER:
		for player in Controller.party:
			var distance = gridPosition.distance_to(player.gridPosition)
			if distance < smallest_distance_to_player:
				smallest_distance_to_player = distance
				target_player = player

		if smallest_distance_to_player <= 3:
			current_state = State.AGGROED
		else:
			current_state = State.IDLE

		if current_state == State.IDLE:
			current_state = State.WALKING
		
	if current_state == State.WALKING:
		
		var rand_movement = Vector2(rng.randi_range(-1,1),rng.randi_range(-1,1))
		var new_pos = gridPosition + rand_movement
		if new_pos.x > 0 and new_pos.x < 50 and new_pos.y > 0 and new_pos.y < 50 and grid_system.get_cell_data(new_pos).type == GlobalTypes.Cell_Type.GROUND:
			set_grid_pos(gridPosition + rand_movement)
		
		current_state = State.IDLE
		turn_taken = true

	if  current_state == State.MOVING_TO_PLAYER:
		position = lerp(position, current_attack_pos, 0.1 * delta * pos_before_move.distance_to(current_attack_pos))
	if current_state == State.MOVING_FROM_PLAYER:
		position = lerp(position, pos_before_move, 0.2 * delta * pos_before_move.distance_to(current_attack_pos))
		if pos_before_move.distance_squared_to(position) < 0.01:
			current_state = self.State.IDLE
			turn_taken = true

	if current_state == State.AGGROED:
		
		if smallest_distance_to_player <= 1.5:
			print(target_player.gridPosition)
			print(self.gridPosition)
			start_attack(target_player.gridPosition)
			current_state = State.MOVING_TO_PLAYER
			
		else:
			var player = Controller.party[0]
			var distance = gridPosition.distance_to(player.gridPosition)
			var direction = player.gridPosition - gridPosition
			
			direction.x = clamp(direction.x,-1,1)
			direction.y = clamp(direction.y,-1,1)
			
			var cell_data = grid_system.get_cell_data(gridPosition + direction)
			
			if !cell_data.has_enemy and !cell_data.has_player and cell_data.type == GlobalTypes.Cell_Type.GROUND and cell_data.pos > Vector2(0,0) and cell_data.pos < Vector2(99,99):	
				set_grid_pos(gridPosition + direction)
			
			current_state = State.IDLE
			turn_taken = true
