tool
extends Navigation

export (PackedScene) var tile_plane
export (PackedScene) var tile_ramp
export (PackedScene) var tile_sideCliff
export (PackedScene) var tile_sideCorner
export (PackedScene) var tile_sideCornerInner
export (Vector2) var terrain_size := Vector2(10, 10)
export (float) var noise_period = 20.0
export (float) var noise_octaves = 4
export (float) var noise_persistence = 0.8
export (float) var noise_lacunarity = 2.0

export (bool) var refresh = false
export (bool) var has_generate_ramps = false

var tilemap := []
var noise
const RAMP_CHANCE = 10.0

func _ready() -> void:
	generate_terrain()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if refresh:
		generate_terrain()
		refresh = false


func generate_terrain() -> void:
	tilemap.clear()
	if get_child_count() > 0:
		for child in get_children():
			remove_child(child)
	noise = OpenSimplexNoise.new()

	# Configure
	noise.seed = randi()
	noise.octaves = noise_octaves
	noise.period = noise_period
	noise.persistence = noise_persistence
	noise.lacunarity = noise_lacunarity
	
	## Generating main planes
	for x in terrain_size.x:
		tilemap.append([])
		for y in terrain_size.y:
			var tile : Spatial = tile_plane.instance()
			add_child(tile)
			#test.set_owner(get_tree().edited_scene_root)
			tilemap[x].append(tile.get_path())
			tile.translation = Vector3(
				x - terrain_size.x / 2, 
				get_point_height(x, y), 
				y - terrain_size.y / 2
			)
	
	## Generating ramps
	if has_generate_ramps:
		check_for_ramps()


func check_for_ramps():
	for x in range(1, terrain_size.x - 1):
		for y in range(1, terrain_size.y - 1):
			change_tile(x, y, check_neighbors(x, y))


func check_neighbors(x, y):
	var res = 0
	var angle = 0.0
	var base_height : float = get_node(tilemap[x][y]).translation.y
	for i in 8:
		angle = deg2rad(i * 45);
		if (get_node(tilemap[x + good_sign(cos(angle))][y + good_sign(sin(angle))]).translation.y - base_height) > 0:
			res = res|(1 << i)
	
	#print(String(get_node(tilemap[x][y]).translation) + " " + String(res))
	return res


func change_tile(x, y, neighbors) -> void:
	var tile: Spatial
	if neighbors & (1 << 0):
		if neighbors & (1 << 2):
			tile = tile_sideCornerInner.instance()
			tile.rotation_degrees = Vector3(0, -90, 0)
		elif neighbors & (1 << 6):
			tile = tile_sideCornerInner.instance()
		else:
			if (randi() % 100 + 1) > RAMP_CHANCE:
				tile = tile_sideCliff.instance()
				tile.rotation_degrees = Vector3(0, -90, 0)
			else:
				tile = tile_ramp.instance()
				tile.rotation_degrees = Vector3(0, -90, 0)
	elif neighbors & (1 << 2):
		if neighbors & (1 << 4):
			tile = tile_sideCornerInner.instance()
			tile.rotation_degrees = Vector3(0, 180, 0)
		else:
			if (randi() % 100 + 1) > RAMP_CHANCE:
				tile = tile_sideCliff.instance()
				tile.rotation_degrees = Vector3(0, 180, 0)
			else:
				tile = tile_ramp.instance()
				tile.rotation_degrees = Vector3(0, 180, 0)
	elif neighbors & (1 << 4):
		if neighbors & (1 << 6):
			tile = tile_sideCornerInner.instance()
			tile.rotation_degrees = Vector3(0, 90, 0)
		else:
			if (randi() % 100 + 1) > RAMP_CHANCE:
				tile = tile_sideCliff.instance()
				tile.rotation_degrees = Vector3(0, 90, 0)
			else:
				tile = tile_ramp.instance()
				tile.rotation_degrees = Vector3(0, 90, 0)
	elif neighbors & (1 << 6):
		if (randi() % 100 + 1) > RAMP_CHANCE:
			tile = tile_sideCliff.instance()
		else:
			tile = tile_ramp.instance()
	elif neighbors & (1 << 1):
		tile = tile_sideCorner.instance()
		tile.rotation_degrees = Vector3(0, -90, 0)
	elif neighbors & (1 << 3):
		tile = tile_sideCorner.instance()
		tile.rotation_degrees = Vector3(0, 180, 0)
	elif neighbors & (1 << 5):
		tile = tile_sideCorner.instance()
		tile.rotation_degrees = Vector3(0, 90, 0)
	elif neighbors & (1 << 7):
		tile = tile_sideCorner.instance()
	else:
		return
	
	add_child(tile)
	#tile.set_owner(get_tree().edited_scene_root)

	tile.translation = get_node(tilemap[x][y]).translation
	get_node(tilemap[x][y]).queue_free()

	tilemap[x][y] = tile.get_path()


func get_point_height(x, y):
	var height = int(noise.get_noise_2d(x, y) * 3) * 0.5
	var height_x0 = int(noise.get_noise_2d(x-1, y) * 3) * 0.5
	var height_x1 = int(noise.get_noise_2d(x+1, y) * 3) * 0.5
	var height_y0 = int(noise.get_noise_2d(x, y-1) * 3) * 0.5
	var height_y1 = int(noise.get_noise_2d(x, y+1) * 3) * 0.5
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
