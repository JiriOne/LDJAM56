extends Node2D

var grid: Array = []
@export var grid_width: int = 10
@export var grid_height: int = 10
@export var grid_delta: int = 16

func _ready() -> void:
	for i in grid_width:
		grid.append([])
		for j in grid_height:
			var cell_data = GridCellData.new()
			cell_data.pos = Vector2(i, j)
			grid[i].append(cell_data)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_cell_data(x, y) -> GridCellData:
	return grid[x][y]


func calc_valid_move_targets(origin, move_targets : Array[Vector2]) -> Array[GridCellData]:
	var result : Array[GridCellData] = []
	print(origin)
	print(move_targets)
	for target in move_targets:
		target = target + origin
		if (target.x >= grid_width) or (target.y >= grid_height) or (target.x < 0) or (target.y < 0):
			printerr("WARNING: Found move target outside of grid")
			return []
		var cell : GridCellData = get_cell_data(target.x, target.y)
		if cell.type == GlobalTypes.Cell_Type.GROUND and not cell.has_enemy:
			result.append(cell)
	return result
