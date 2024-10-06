extends Player

func _ready() -> void:
	super()
	shadow_texture = $CanvasGroup/Sprite2D.texture
	move_conditional = func(origin, cell, target):
		return grid_system.is_path_to_target_ground(origin, target) \
			and cell.type == GlobalTypes.Cell_Type.GROUND \
			and not cell.has_player \
			and not cell.has_enemy
	attack_conditional = func(origin, cell, target): 
		return grid_system.is_path_to_target_ground(origin, target) \
			and cell.type == GlobalTypes.Cell_Type.GROUND \
			and not cell.has_player \
			and cell.has_enemy
