extends Node
func grid_to_world(pos : Vector2) -> Vector2:
	return pos * 16

func world_to_grid(pos: Vector2) -> Vector2:
	return pos / 16
