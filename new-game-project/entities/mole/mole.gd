extends Player

const molshoop_scene = preload("res://entities/molshoop/molshoop.tscn")

func _ready() -> void:
	super()
	shadow_texture = $CanvasGroup/Sprite2D.texture
	move_conditional = func(origin, cell, target):
		return grid_system.is_path_to_target_of_types(origin, target, [GlobalTypes.Cell_Type.GROUND, GlobalTypes.Cell_Type.WALL]) \
			and (cell.type == GlobalTypes.Cell_Type.GROUND \
				or (cell.type == GlobalTypes.Cell_Type.DOOR and Controller.keys > 0)) \
			and not cell.has_player \
			and not cell.has_enemy
	attack_conditional = func(origin, cell, target): 
		return grid_system.is_path_to_target_of_types(origin, target, [GlobalTypes.Cell_Type.GROUND]) \
			and cell.type == GlobalTypes.Cell_Type.GROUND \
			and not cell.has_player \
			and cell.has_enemy
	movement_action = func(old_cell_data, target_cell_data):
		# Did the mole dig?
		if !grid_system.is_path_to_target_of_types(old_cell_data.pos, target_cell_data.pos, [GlobalTypes.Cell_Type.GROUND]):
			if old_cell_data.has_molshoop or target_cell_data.has_molshoop:
				return
			var molshoop_from = molshoop_scene.instantiate()
			var molshoop_to = molshoop_scene.instantiate()
			molshoop_from.position = GlobalUtil.grid_to_world(old_cell_data.pos)
			molshoop_to.position = GlobalUtil.grid_to_world(target_cell_data.pos)
			molshoop_from.other_pos = target_cell_data.pos
			molshoop_to.other_pos = old_cell_data.pos
			old_cell_data.has_molshoop = true
			old_cell_data.molshoop = molshoop_from
			target_cell_data.has_molshoop = true
			target_cell_data.molshoop = molshoop_to
			add_sibling(molshoop_from)
			add_sibling(molshoop_to)
