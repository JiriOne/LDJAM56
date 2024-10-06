extends Node2D

signal request_attack_here(grid_pos)

@onready var globalUtil = get_node("/root/GlobalUtil")

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			request_attack_here.emit(globalUtil.world_to_grid(position))
