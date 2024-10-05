extends CharacterBody2D

var grid_system
var valid_move_targets : Array[GridCellData]
@export var selected : bool = false
@export var gridPosition : Vector2 = Vector2.ZERO

@export_multiline var available_move_targets_text : String
var available_move_targets : Array[Vector2]

@onready var globalUtil = get_node("/root/GlobalUtil")

var move_shadows : Array
var move_shadow_scene = preload("res://entities/move_shadow/move_shadow.tscn")

func _ready() -> void:
	grid_system = get_parent()
	position = globalUtil.grid_to_world(gridPosition)
	available_move_targets = translate_move_targets()
	move_shadows = []

func set_grid_pos(pos) -> void:
	self.position = globalUtil.grid_to_world(pos)
	gridPosition = pos

func translate_move_targets() -> Array[Vector2]:
	var lines : PackedStringArray = available_move_targets_text.split("\n", false)
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
	

func show_move_targets() -> void:
	var move_targets : Array[Vector2]
	valid_move_targets = grid_system.calc_valid_move_targets(self.gridPosition, available_move_targets)
	for target in valid_move_targets:
		var new_ms = move_shadow_scene.instantiate()
		new_ms.position = globalUtil.grid_to_world(target.pos)
		move_shadows.append(new_ms)
		grid_system.add_child(new_ms)
		new_ms.connect("request_move_here", _on_move_request)

func hide_move_targets() -> void:
	for shadow in move_shadows:
		shadow.queue_free()
	move_shadows.clear()


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			selected = not selected
			if selected:
				show_move_targets()
			else:
				hide_move_targets()

func _on_move_request(grid_pos) -> void:
	self.set_grid_pos(grid_pos)
	hide_move_targets()
	selected = false
