extends Node2D

signal request_move_here(grid_pos)

@onready var globalUtil = get_node("/root/GlobalUtil")

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			request_move_here.emit(globalUtil.world_to_grid(position))

func set_texture(tex : CompressedTexture2D) -> void:
	$CanvasGroup/Sprite2D.texture = tex
