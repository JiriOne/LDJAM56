extends Node2D

@onready var grid_system = $"../GridSystem"
@onready var tile_map_layer: TileMapLayer = $TileMapLayer
var rng = RandomNumberGenerator.new()
@onready var camera_2d: Camera2D = $"../Camera2D"


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
	grid_system.initialize()
	var location = Vector2(0,0)
	randomize()
	for i in range(50):	
		for j in range(50):		
			tile_map_layer.set_cell(Vector2i(i,j),0 ,Vector2i(1,0))
			
	#add rooms
	var room_locations = []
	var room_sizes = []
	
	for i in range(6):
		
		#make first room bigger:
		var room_size
		if i == 0:
			room_size = Vector2(rng.randi_range(8,10),rng.randi_range(8,10))
		else:
			room_size = Vector2(rng.randi_range(4,8),rng.randi_range(4,8))
		# make the room far enough from the others
		var room_location = Vector2(rng.randi_range(0,50-room_size.x),rng.randi_range(0,50-room_size.y))

		while(true):
			var too_close = false
			for other_room_location in room_locations:
				if room_location.distance_to(other_room_location) < 12:
					too_close = true
					break
			if too_close:
				room_location = Vector2(rng.randi_range(0,50-room_size.x),rng.randi_range(0,50-room_size.y))
			else:
				break

		room_locations.append(room_location)
		room_sizes.append(room_size)
	
	
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
				
			if rng.randf() < 0.1:
				var enemy = preload("res://entities/enemy/enemy.tscn").instantiate()
				enemy.position = Vector2(x,y)*16 + Vector2(rng.randi_range(-3,3),rng.randi_range(-3,3))*16
				enemy.gridPosition = enemy.position/16
				var cell = grid_system.get_cell_data(enemy.gridPosition)
				cell.has_enemy = true
				grid_system.add_child(enemy)

			if x < int(center_b.x):
				x += 1
			else:
				x -= 1
		while y != int(center_b.y):
			tile_map_layer.set_cell(Vector2i(x, y), 0, Vector2i(3, 0))

			for r in range(3):
				tile_map_layer.set_cell(Vector2i(x+rng.randi_range(-2,2), y), 0, Vector2i(3, 0))
				
			if rng.randf() < 0.1:
				var enemy = preload("res://entities/enemy/enemy.tscn").instantiate()
				enemy.position = Vector2(x,y)*16 + Vector2(rng.randi_range(-3,3),rng.randi_range(-3,3))*16
				enemy.gridPosition = enemy.position/16
				var cell = grid_system.get_cell_data(enemy.gridPosition)
				cell.has_enemy = true
				grid_system.add_child(enemy)
				
			if y < int(center_b.y):
				y += 1
			else:
				y -= 1
	
	const door_scene = preload("res://entities/door/door.tscn")
	
	# Create walls
	for i in range(len(room_locations)):
		var room_size = room_sizes[i]
		# make the room far enough from the others
		var room_location = room_locations[i]
		for x in range(room_size.x):
			for y in range(room_size.y):
				# Set the walls
				if x == 0 or y == 0 or x == room_size.x - 1 or y == room_size.y - 1:
					tile_map_layer.set_cell(Vector2i(room_location.x + x, room_location.y + y), 0, Vector2i(2, 0))
					grid_system.set_cell_type(Vector2(room_location.x + x, room_location.y + y), GlobalTypes.Cell_Type.WALL)
				else:
					# Clear the inside of the room
					tile_map_layer.set_cell(Vector2i(room_location.x + x, room_location.y + y), 0, Vector2i(1, 0))
		# Create key door
		var random_pos_in_room = Vector2(randi_range(2, room_size.x - 2), randi_range(2, room_size.y - 2))
		var wall_origins = [Vector2.ZERO, Vector2(room_size.x - 1, 0), Vector2(0, room_size.y - 1)]
		var random_wall_origin = wall_origins.pick_random()
		var random_wall_direction = Vector2.RIGHT
		if random_wall_origin == Vector2.ZERO:
			random_wall_direction = [Vector2.RIGHT, Vector2.DOWN].pick_random()
		else:
			random_wall_direction = random_wall_origin.orthogonal()
		var door_pos = random_pos_in_room.project(random_wall_direction) + random_wall_origin
		tile_map_layer.set_cell(Vector2i(room_location.x + door_pos.x, room_location.y + door_pos.y), 0, Vector2i(1, 0))
		grid_system.set_cell_type(Vector2(room_location.x + door_pos.x, room_location.y + door_pos.y), GlobalTypes.Cell_Type.DOOR)
		var door_entity = door_scene.instantiate()
		door_entity.position = GlobalUtil.grid_to_world(room_location + door_pos)
		grid_system.add_door(door_entity, room_location + door_pos)
		grid_system.add_child(door_entity)
	
	for i in range(10):
		var heart = preload("res://entities/heart/heart.tscn").instantiate()
		var heart_pos = Vector2(rng.randi_range(0,50),rng.randi_range(0,50))
		heart.position = GlobalUtil.grid_to_world(heart_pos)
		grid_system.add_child(heart)
		
	#generate key scene object
	var key_positions = []
	for i in range(len(room_locations)):
		var key = preload("res://entities/key/key.tscn").instantiate()
		
		#set first key pos to the room
		var key_pos
		if i == 0:
			key_pos = room_locations[i] + round(room_sizes[i] / 2)
			key_pos += Vector2(rng.randi_range(-3,3), rng.randi_range(-3,3))
		else:
			key_pos = Vector2(rng.randi_range(10,40), rng.randi_range(10,40))
			
			#check if key in room
			var in_room = false
				
			for j in range(len(room_locations)):
				if key_pos.x >= room_locations[j].x and key_pos.x <= room_locations[j].x + room_sizes[j].x and key_pos.y >= room_locations[j].y and key_pos.y <= room_locations[j].y + room_sizes[j].y:
					in_room = true
					break

			while in_room:
				key_pos = Vector2(rng.randi_range(10,40), rng.randi_range(10,40))
				in_room = false
				for j in range(len(room_locations)):
					if key_pos.x >= room_locations[j].x and key_pos.x <= room_locations[j].x + room_sizes[j].x and key_pos.y >= room_locations[j].y and key_pos.y <= room_locations[j].y + room_sizes[j].y:
						in_room = true
						break
						
			var close_to_key = false
				
			for other in key_positions:
				if key_pos.distance_to(other) < 8:
					close_to_key = true
					break

			while close_to_key:
				key_pos = Vector2(rng.randi_range(10,40), rng.randi_range(10,40))
				close_to_key = false
				for other in key_positions:
					if key_pos.distance_to(other) < 8:
						close_to_key = true
						
			var close_to_room = false

			for j in range(len(room_locations)):
				if key_pos.distance_to(room_locations[j] + round(room_sizes[j] / 2)) < 8:
					close_to_room = true
					break

			while close_to_room:
				key_pos = Vector2(rng.randi_range(10,40), rng.randi_range(10,40))
				close_to_room = false
				for j in range(len(room_locations)):
					if key_pos.distance_to(room_locations[j] + round(room_sizes[j] / 2)) < 8:
						close_to_room = true
						
			var there_is_cat_here_ohno = false

			if grid_system.get_cell_data(key_pos).has_enemy:
				there_is_cat_here_ohno = true
			
			while there_is_cat_here_ohno:
				key_pos = Vector2(rng.randi_range(10,40), rng.randi_range(10,40))
				if grid_system.get_cell_data(key_pos).has_enemy:
					there_is_cat_here_ohno = true
						
				
			
		
		key_positions.append(key_pos)	
		key.position = GlobalUtil.grid_to_world(key_pos)
		var cell_data = grid_system.get_cell_data(key_pos)
		cell_data.has_key = true
		cell_data.key = key
		add_child(key)
		
		if i == 0:
			#no puzzle
			var la = "makes no sense"
		if i > 0 and i < 3:
			_create_water_puzzle(key_pos)
		elif i > 0 and i < 5:
			_create_fence_puzzle(key_pos)
		elif i > 0:
			_create_dual_puzzle(key_pos)
	
	
	for i in range(len(room_locations)):
		var player
		
		if i < 2:
			player = preload("res://entities/frog/frog.tscn").instantiate()
		else:
			player = preload("res://entities/mole/mole.tscn").instantiate()
			
		player.position = GlobalUtil.grid_to_world(room_locations[i] + round(room_sizes[i] / 2))

		player.gridPosition = player.position/16
		if i == 0:
			Controller.party.append(player)
			camera_2d.focus_on_player(player)
			
		grid_system.add_child(player)
	
	for i in range(50):
		for j in range(50):
			if grid_system.get_cell_data(Vector2(i,j)).type != GlobalTypes.Cell_Type.DOOR:
				if tile_map_layer.get_cell_atlas_coords(Vector2(i,j)) == Vector2i(1,0) or tile_map_layer.get_cell_atlas_coords(Vector2(i,j)) == Vector2i(3,0) :
					grid_system.set_cell_type(Vector2(i,j), GlobalTypes.Cell_Type.GROUND)
				elif tile_map_layer.get_cell_atlas_coords(Vector2(i,j)) == Vector2i(2,0):
					grid_system.set_cell_type(Vector2(i,j), GlobalTypes.Cell_Type.WALL)
				elif tile_map_layer.get_cell_atlas_coords(Vector2(i,j)) == Vector2i(0,0):
					grid_system.set_cell_type(Vector2(i,j), GlobalTypes.Cell_Type.WATER)
				elif tile_map_layer.get_cell_atlas_coords(Vector2(i,j)) == Vector2i(4,0):
					grid_system.set_cell_type(Vector2(i,j), GlobalTypes.Cell_Type.FENCE)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
