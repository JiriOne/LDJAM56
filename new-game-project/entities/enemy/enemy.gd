extends CharacterBody2D

@onready var globalUtil = get_node("/root/GlobalUtil")
@onready var healthBar = $CanvasGroup/TextureProgressBar

var grid_system
@export var gridPosition : Vector2 = Vector2.ZERO
@export var hp = 100

func _ready() -> void:
	grid_system = get_parent()
	await grid_system.grid_initialized
	position = globalUtil.grid_to_world(gridPosition)
	generator_will_probably_do_this()
	healthBar.value = hp

func generator_will_probably_do_this():
	var data = grid_system.get_cell_data(gridPosition)
	data.has_enemy = true
	data.enemy = self
	grid_system.update_cell(data)

func hurt(dp):
	hp = hp - dp
	healthBar.value = hp
	if hp <= 0:
		print("die")
		self.die()

func die():
	var data : GridCellData = grid_system.get_cell_data(gridPosition)
	data.has_enemy = false
	grid_system.update_cell(data)
	queue_free()
