extends CharacterBody2D

@onready var globalUtil = get_node("/root/GlobalUtil")

var grid_system
@export var gridPosition : Vector2 = Vector2.ZERO

func _ready() -> void:
	grid_system = get_parent()
	await grid_system.grid_initialized
	position = globalUtil.grid_to_world(gridPosition)
	generator_will_probably_do_this()

func generator_will_probably_do_this():
	var data = grid_system.get_cell_data(gridPosition)
	data.has_enemy = true
	grid_system.update_cell(data)
