extends Node2D

@onready var grid_system = $"../GridSystem"
@onready var tile_map_layer: TileMapLayer = $TileMapLayer
var rng = RandomNumberGenerator.new()


func _create_water_puzzle(key_pos: Vector2):
	for i in range(-2,3):
		for j in range(-2,3):
			var curr_pos = Vector2(i,j) + key_pos
			if tile_map_layer.get_cell_atlas_coords(curr_pos) != Vector2i(2,0):
				if curr_pos == key_pos:
					tile_map_layer.set_cell(curr_pos, 0, Vector2i(1,0))
				elif Vector2(i,j) == Vector2(-2,-2) or Vector2(i,j) == Vector2(-2,2) or Vector2(i,j) == Vector2(2,-2) or Vector2(i,j) == Vector2(2,2):
					tile_map_layer.set_cell(curr_pos, 0, Vector2i(1,0))
				else:
					tile_map_layer.set_cell(curr_pos, 0, Vector2i(0,0))

func _create_fence_puzzle(key_pos: Vector2):
	for i in range(-2,3):
		for j in range(-2,3):
			var curr_pos = Vector2(i,j) + key_pos
			if tile_map_layer.get_cell_atlas_coords(curr_pos) != Vector2i(2,0):
				if curr_pos == key_pos:
					tile_map_layer.set_cell(curr_pos, 0, Vector2i(1,0))
				elif Vector2(i,j).distance_to(Vector2(0,0)) <= 1.5:
					tile_map_layer.set_cell(curr_pos, 0, Vector2i(1,0))
				else:
					tile_map_layer.set_cell(curr_pos, 0, Vector2i(4,0))

func _create_dual_puzzle(key_pos: Vector2):
	#add walls 
	for i in range(-2,3):
		var curr_pos = Vector2(i,-1) + key_pos
		tile_map_layer.set_cell(curr_pos, 0, Vector2i(2,0))
	
	
	tile_map_layer.set_cell(Vector2(-2,0) + key_pos, 0, Vector2i(2,0))
	tile_map_layer.set_cell(Vector2(2,0) + key_pos, 0, Vector2i(2,0))
	tile_map_layer.set_cell(Vector2(-2,1) + key_pos, 0, Vector2i(2,0))
	tile_map_layer.set_cell(Vector2(2,1) + key_pos, 0, Vector2i(2,0))
	tile_map_layer.set_cell(Vector2(-2,2) + key_pos, 0, Vector2i(2,0))
	tile_map_layer.set_cell(Vector2(2,2) + key_pos, 0, Vector2i(2,0))
	tile_map_layer.set_cell(Vector2(-2,3) + key_pos, 0, Vector2i(2,0))
	tile_map_layer.set_cell(Vector2(2,3) + key_pos, 0, Vector2i(2,0))
	
	for i in range(-1,2):
		var curr_pos = Vector2(i, 1) + key_pos
		tile_map_layer.set_cell(curr_pos, 0, Vector2i(0,0))
	
	for i in range(-1,2):
		var curr_pos = Vector2(i, 3) + key_pos
		tile_map_layer.set_cell(curr_pos, 0, Vector2i(4,0))
		

func _manhattan_distance(a: Vector2, b: Vector2) -> float:
	return abs(a.x - b.x) + abs(a.y - b.y)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await grid_system.grid_initialized
	var location = Vector2(0,0)
	randomize()
	for i in range(100):	
		for j in range(100):		
			tile_map_layer.set_cell(Vector2i(i,j),0 ,Vector2i(1,0))
			
	#add rooms
	var room_locations = []
	var room_sizes = []
	
	for i in range(10):
		var room_size = Vector2(rng.randi_range(15,20),rng.randi_range(15,20))
		# make the room far enough from the others
		var room_location = Vector2(rng.randi_range(0,100-room_size.x),rng.randi_range(0,100-room_size.y))

		while(true):
			var too_close = false
			for other_room_location in room_locations:
				if room_location.distance_to(other_room_location) < 22:
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
					grid_system.set_cell_type(Vector2(room_location.x + x, room_location.y + y), GlobalTypes.Cell_Type.WALL)
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
	
	#for i in len(room_locations):
		#if rng.randf() < 0.3:
			##add random tiles to make the room look more interesting
			#var water_loc = Vector2(rng.randi_range(0,room_sizes[i].x) + room_locations[i].x,rng.randi_range(0,room_sizes[i].y) + room_locations[i].y)
			#var water_radius = rng.randi_range(2,5)
			#for xx in range(room_sizes[i].x):
				#for yy in range(room_sizes[i].y):
					#var curr_loc = Vector2(xx + room_locations[i].x,yy + room_locations[i].y)
					#if water_loc.distance_to(curr_loc) < water_radius:
						##check if the tile is not a wall
						#if tile_map_layer.get_cell_atlas_coords(curr_loc) != Vector2i(2,0):
							#tile_map_layer.set_cell(curr_loc,0,Vector2i(0,0))
	
	#generate key scene object
	for i in range(len(room_locations)):
		var key = preload("res://entities/key/key.tscn").instantiate()
		
		#add variation to the key position
		var key_pos = room_locations[i]*16 + round(room_sizes[i] / 2) *16
		key_pos += Vector2(rng.randi_range(-3,3)*16, rng.randi_range(-3,3)*16)
		key.position = key_pos
		add_child(key)
		
		if i == 0 or rng.randf() < 0.2:
			_create_water_puzzle(key_pos/16)
		elif rng.randf() < 0.5:
			_create_fence_puzzle(key_pos/16)
		#check for enough free tiles below
		else:
			var free = true
			for k in range(-5,5):
				for j in range(-5,5):
					if tile_map_layer.get_cell_atlas_coords(Vector2(k,j) + key_pos/16) == Vector2i(2,0):
						free = false
			if free:
				_create_dual_puzzle(key_pos/16)
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
