extends Node2D

signal grid_initialized

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
	grid_initialized.emit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_cell_data(pos) -> GridCellData:
	return grid[pos.x][pos.y]

func update_cell(data : GridCellData) -> void:
	if (data.pos.x >= grid_width) or (data.pos.y >= grid_height) or (data.pos.x < 0) or (data.pos.y < 0):
		printerr("WARNING: Tried to update cell that is out of bounds")
		return
	grid[data.pos.x][data.pos.y] = data

func set_cell_type(pos, type) -> void:
	var data = get_cell_data(pos)
	data.type = type
	update_cell(data)

func calc_valid_targets(origin, targets : Array[Vector2], conditional : Callable) -> Array[GridCellData]:
	var result : Array[GridCellData] = []
	for target in targets:
		target = target + origin
		if (target.x >= grid_width) or (target.y >= grid_height) or (target.x < 0) or (target.y < 0):
			printerr("WARNING: Found calculating target outside of grid")
			return []
		var cell : GridCellData = get_cell_data(target)
		if conditional.call(origin, cell, target):
			result.append(cell)
	return result

func is_path_to_target_ground(origin, target) -> bool:
	var dir = ceil((target - origin).normalized())
	var step_pos : Vector2 = origin + dir
	var trace_positions = []
	while step_pos != target:
		trace_positions.append(step_pos)
		step_pos = step_pos + dir
	return trace_positions.all(func(pos): return self.get_cell_data(pos).type == GlobalTypes.Cell_Type.GROUND)
