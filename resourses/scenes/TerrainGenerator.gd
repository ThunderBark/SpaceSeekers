tool
extends Navigation


const RAMP_CHANCE = 0.1

export (PackedScene) var tile_plane
export (PackedScene) var tile_ramp
export (PackedScene) var tile_sideCliff
export (PackedScene) var tile_sideCorner
export (PackedScene) var tile_sideCornerInner
enum {
	TILE_PLANE, 
	TILE_RAMP, 
	TILE_SIDE_CLIFF, 
	TILE_SIDE_CORNER,
	TILE_SIDE_CORNER_INNER
}

export (Vector2) var terrain_size := Vector2(32, 32)
export (Vector2) var sector_size := Vector2(16, 16)
export (float) var noise_period = 20.0
export (float) var noise_octaves = 4
export (float) var noise_persistence = 0.8
export (float) var noise_lacunarity = 2.0

export (bool) var refresh = false
export (bool) var next_sector = false
export (bool) var clean_scene = false

var tilemap := []
var noise_generator
var cur_sector = 0

func _ready() -> void:
	generate_terrain()


func _process(_delta):
	if Engine.editor_hint:
		if refresh:
			generate_terrain()
			cur_sector = 0
			refresh = false
		
		if next_sector:
			var sector_cnt = int((terrain_size.x * terrain_size.y)/(sector_size.x * sector_size.y))
			if (cur_sector < sector_cnt) and cur_sector >= 0:
				cur_sector += 1
				generate_sector(
					int(cur_sector / int(terrain_size.x / sector_size.x)), 
					int(cur_sector % int(terrain_size.y / sector_size.y))
				)
			else:
				print("All sectors generated!")
			next_sector = false
		
		if clean_scene:
			## Clear map
			tilemap.clear()
			if get_child_count() > 0:
				for child in get_children():
					remove_child(child)
			cur_sector = -1
			clean_scene = false
	else:
		pass


func generate_terrain():
	## Clear map
	tilemap.clear()
	if get_child_count() > 0:
		for child in get_children():
			remove_child(child)
	
	# Configure noise generator
	noise_generator = OpenSimplexNoise.new()
	noise_generator.seed = randi()
	noise_generator.octaves = noise_octaves
	noise_generator.period = noise_period
	noise_generator.persistence = noise_persistence
	noise_generator.lacunarity = noise_lacunarity
	
	## Generating tilemap info
	for x in terrain_size.x:
		tilemap.append([])
		for y in terrain_size.y:
			tilemap[x].append({"height": get_point_height(x, y)})
	
	## Defining tiles
	for x in terrain_size.x:
		for y in terrain_size.y:
			var tile_info = define_tile(x, y)
			tilemap[x][y].type = tile_info.type
			tilemap[x][y].rotation = tile_info.rotation
#			print("x: " + String(x) + ", y: " + String(y) + ", " + String(tilemap[x][y]))
	
	## Fixing tilemap info
	# Nothing yet
	
	## Placing tiles one sector at a time
	generate_sector(0, 0)
#	var sector_cnt = int((terrain_size.x * terrain_size.y)/(sector_size.x * sector_size.y))
#	for i in int(terrain_size.x / sector_size.x):
#		for j in int(terrain_size.y / sector_size.y):
#			var sector_origin = Vector2(
#				sector_size.x * i - terrain_size.x / 2,
#				sector_size.y * j - terrain_size.y / 2
#			)
#			generate_sector(i, j)


func generate_sector(i, j):
	print("Generation sector: " + String(i) + ", " + String(j))
	var tile : Spatial
	var local_x := 0.0
	var local_y := 0.0
	for x in sector_size.x:
		for y in sector_size.y:
			local_x = sector_size.x * i + x
			local_y = sector_size.y * j + y
			match tilemap[local_x][local_y].type:
				TILE_PLANE:
					tile = tile_plane.instance()
				TILE_RAMP:
					tile = tile_ramp.instance() 
				TILE_SIDE_CLIFF:
					tile = tile_sideCliff.instance()
				TILE_SIDE_CORNER:
					tile = tile_sideCorner.instance() 
				TILE_SIDE_CORNER_INNER:
					tile = tile_sideCornerInner.instance()
			add_child(tile)
			#tile.set_owner(get_tree().edited_scene_root)
			tile.translation = Vector3(
				local_x - terrain_size.x / 2, 
				tilemap[local_x][local_y].height, 
				local_y - terrain_size.y / 2
			)
			tile.rotation_degrees = tilemap[local_x][local_y].rotation


func define_tile(x, y):
	var tile = {
		"type": TILE_PLANE,
		"rotation": Vector3(0, 0, 0)
	}
	if (x == 0) or (x == terrain_size.x - 1) or (y == 0) or (y == terrain_size.y - 1):
		return tile
	
	var neighbors = check_neighbors(x, y)
	if neighbors & (1 << 0):
		if neighbors & (1 << 2):
			tile.type = TILE_SIDE_CORNER_INNER
			tile.rotation = Vector3(0, -90, 0)
		elif neighbors & (1 << 6):
			tile.type = TILE_SIDE_CORNER_INNER
		else:
			if randf() > RAMP_CHANCE:
				tile.type = TILE_SIDE_CLIFF
				tile.rotation = Vector3(0, -90, 0)
			else:
				tile.type = TILE_RAMP
				tile.rotation = Vector3(0, -90, 0)
	elif neighbors & (1 << 2):
		if neighbors & (1 << 4):
			tile.type = TILE_SIDE_CORNER_INNER
			tile.rotation = Vector3(0, 180, 0)
		else:
			if randf() > RAMP_CHANCE:
				tile.type = TILE_SIDE_CLIFF
				tile.rotation = Vector3(0, 180, 0)
			else:
				tile.type = TILE_RAMP
				tile.rotation = Vector3(0, 180, 0)
	elif neighbors & (1 << 4):
		if neighbors & (1 << 6):
			tile.type = TILE_SIDE_CORNER_INNER
			tile.rotation = Vector3(0, 90, 0)
		else:
			if randf() > RAMP_CHANCE:
				tile.type = TILE_SIDE_CLIFF
				tile.rotation = Vector3(0, 90, 0)
			else:
				tile.type = TILE_RAMP
				tile.rotation = Vector3(0, 90, 0)
	elif neighbors & (1 << 6):
		if randf() > RAMP_CHANCE:
			tile.type = TILE_SIDE_CLIFF
		else:
			tile.type = TILE_RAMP
	elif neighbors & (1 << 1):
		tile.type = TILE_SIDE_CORNER
		tile.rotation = Vector3(0, -90, 0)
	elif neighbors & (1 << 3):
		tile.type = TILE_SIDE_CORNER
		tile.rotation = Vector3(0, 180, 0)
	elif neighbors & (1 << 5):
		tile.type = TILE_SIDE_CORNER
		tile.rotation = Vector3(0, 90, 0)
	elif neighbors & (1 << 7):
		tile.type = TILE_SIDE_CORNER
	
	return tile


func check_neighbors(x, y):
	var res = 0
	var angle = 0.0
	var base_height : float = tilemap[x][y].height
	for i in 8:
		angle = deg2rad(i * 45);
		if (tilemap[x + good_sign(cos(angle))][y + good_sign(sin(angle))].height - base_height) > 0:
			res = res|(1 << i)
	return res


func get_point_height(x, y):
	var height = int(noise_generator.get_noise_2d(x, y) * 3) * 0.5
	var height_x0 = int(noise_generator.get_noise_2d(x-1, y) * 3) * 0.5
	var height_x1 = int(noise_generator.get_noise_2d(x+1, y) * 3) * 0.5
	var height_y0 = int(noise_generator.get_noise_2d(x, y-1) * 3) * 0.5
	var height_y1 = int(noise_generator.get_noise_2d(x, y+1) * 3) * 0.5
	if height < height_x0 and (height_x0 == height_x1):
		return height_x0
	elif height < height_y0 and (height_y0 == height_y1):
		return height_y0
	else:
		return height


func good_sign(num):
	if num > 0.1:
		return 1
	elif num < -0.1:
		return -1
	else:
		return 0
