extends Node2D
@onready var tile_map_layer: TileMapLayer = $TileMapLayer
var rng = RandomNumberGenerator.new()


func _manhattan_distance(a: Vector2, b: Vector2) -> float:
	return abs(a.x - b.x) + abs(a.y - b.y)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var location = Vector2(0,0)
	randomize()
	for i in range(100):	
		for j in range(100):		
			tile_map_layer.set_cell(Vector2i(i,j),0 ,Vector2i(1,0))
			
	#add rooms
	var room_locations = []
	var room_sizes = []
	
	for i in range(10):
		var room_size = Vector2(rng.randi_range(10,15),rng.randi_range(10,15))
		# make the room far enough from the others
		var room_location = Vector2(rng.randi_range(0,100-room_size.x),rng.randi_range(0,100-room_size.y))

		while(true):
			var too_close = false
			for other_room_location in room_locations:
				if room_location.distance_to(other_room_location) < 17:
					too_close = true
					break
			if too_close:
				room_location = Vector2(rng.randi_range(0,100-room_size.x),rng.randi_range(0,100-room_size.y))
			else:
				break

		room_locations.append(room_location)
		room_sizes.append(room_size)
		for x in range(room_size.x):
			for y in range(room_size.y):
				# Set the walls
				if x == 0 or y == 0 or x == room_size.x - 1 or y == room_size.y - 1:
					tile_map_layer.set_cell(Vector2i(room_location.x + x, room_location.y + y), 0, Vector2i(2, 0))
				else:
					# Clear the inside of the room
					tile_map_layer.set_cell(Vector2i(room_location.x + x, room_location.y + y), 0, Vector2i(1, 0))
	
	#add straight corridors
	for i in range(len(room_locations)-1):
		var room_a = room_locations[i]
		var room_b = room_locations[i+1]
		var center_a = room_a + room_sizes[i] / 2
		var center_b = room_b + room_sizes[i+1] / 2
		var x = int(center_a.x)
		var y = int(center_a.y)
		while x != int(center_b.x):
			tile_map_layer.set_cell(Vector2i(x, y), 0, Vector2i(3, 0))

			#add random tiles to make the corridor look more interesting
			for r in range(3):
				tile_map_layer.set_cell(Vector2i(x, y+rng.randi_range(-2,2)), 0, Vector2i(3, 0))

			if x < int(center_b.x):
				x += 1
			else:
				x -= 1
		while y != int(center_b.y):
			tile_map_layer.set_cell(Vector2i(x, y), 0, Vector2i(3, 0))

			for r in range(3):
				tile_map_layer.set_cell(Vector2i(x+rng.randi_range(-2,2), y), 0, Vector2i(3, 0))
			if y < int(center_b.y):
				y += 1
			else:
				y -= 1

	for i in len(room_locations):
		var room_size = room_sizes[i]
		for x in range(room_size.x):
				for y in range(room_size.y):
					# Set the walls
					if x == 0 or y == 0 or x == room_size.x - 1 or y == room_size.y - 1:
						tile_map_layer.set_cell(Vector2i(room_locations[i].x + x, room_locations[i].y + y), 0, Vector2i(2, 0))
					else:
						# Clear the inside of the room
						tile_map_layer.set_cell(Vector2i(room_locations[i].x + x, room_locations[i].y + y), 0, Vector2i(1, 0))
	
	#TODO:
		"""
		- remve duplicate tiles
		"""


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
