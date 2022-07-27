tool
extends GridMap

# Exports
export (int) var terrain_size := 32
export (float) var noise_period = 20.0
export (float) var noise_octaves = 1
export (float) var noise_persistence = 0.8
export (float) var noise_lacunarity = 2.0
export (float) var ramp_chance = 0.1
export (bool) var refresh = false

# Constants
enum {
	TILE_PLANE,
	TILE_RAMP,
	TILE_SIDE_CLIFF = 5,
	TILE_SIDE_CORNER = 9,
	TILE_SIDE_CORNER_INNER = 13
}

# etc.
var noise_generator: OpenSimplexNoise


func _ready() -> void:
	if not Engine.editor_hint:
		generate_terrain()


func _process(delta: float) -> void:
	if refresh or (not Engine.editor_hint and Input.is_key_pressed(KEY_F)):
		generate_terrain()
		refresh = false


func generate_terrain() -> void:
	## Clearing grid
	clear()
	
	## Configuring noise generator
	noise_generator = OpenSimplexNoise.new()
	noise_generator.seed = OS.get_ticks_msec()
	noise_generator.octaves = noise_octaves
	noise_generator.period = noise_period
	noise_generator.persistence = noise_persistence
	noise_generator.lacunarity = noise_lacunarity
	
	## Generating terrain
	for x in range(-terrain_size / 2, terrain_size / 2):
		for y in range(-terrain_size / 2, terrain_size / 2):
			set_cell_item(
				x,
				get_interpolated_height_at_point(x, y) / 0.5,
				y,
				define_tile(x, y),
				0
			)
	
	## Maybe some terrain fixes
	
	## Spawning objects


func define_tile(x: int, y: int) -> int:
	var tile := {
		"type": 0
	}
	
	var neighbors = check_neighbors(x, y)
	if neighbors & (1 << 0):
		if neighbors & (1 << 2):
			tile.type = TILE_SIDE_CORNER_INNER + 3
		elif neighbors & (1 << 6):
			tile.type = TILE_SIDE_CORNER_INNER
		else:
			if randf() > ramp_chance:
				tile.type = TILE_SIDE_CLIFF + 3
			else:
				tile.type = TILE_RAMP + 3
	elif neighbors & (1 << 2):
		if neighbors & (1 << 4):
			tile.type = TILE_SIDE_CORNER_INNER + 2
		else:
			if randf() > ramp_chance:
				tile.type = TILE_SIDE_CLIFF + 2
			else:
				tile.type = TILE_RAMP + 2
	elif neighbors & (1 << 4):
		if neighbors & (1 << 6):
			tile.type = TILE_SIDE_CORNER_INNER + 1
		else:
			if randf() > ramp_chance:
				tile.type = TILE_SIDE_CLIFF + 1
			else:
				tile.type = TILE_RAMP + 1
	elif neighbors & (1 << 6):
		if randf() > ramp_chance:
			tile.type = TILE_SIDE_CLIFF
		else:
			tile.type = TILE_RAMP
	elif neighbors & (1 << 1):
		tile.type = TILE_SIDE_CORNER + 3
	elif neighbors & (1 << 3):
		tile.type = TILE_SIDE_CORNER + 2
	elif neighbors & (1 << 5):
		tile.type = TILE_SIDE_CORNER + 1
	elif neighbors & (1 << 7):
		tile.type = TILE_SIDE_CORNER
	else:
		tile.type = TILE_PLANE
	
	return tile.type


func check_neighbors(x: float, y: float):
	var res = 0
	var angle = 0.0
	var base_height : float = get_interpolated_height_at_point(x, y)
	for i in 8:
		angle = deg2rad(i * 45);
		if (get_interpolated_height_at_point(x + good_sign(cos(angle)), y + good_sign(sin(angle))) - base_height) > 0:
			res = res|(1 << i)
	return res


func get_interpolated_height_at_point(x, y):
	var height = get_height_at_point(x, y)
	var height_x0 = get_height_at_point(x-1, y)
	var height_x1 = get_height_at_point(x+1, y)
	var height_y0 = get_height_at_point(x, y-1)
	var height_y1 = get_height_at_point(x, y+1)
	
	if height < height_x0 and (height_x0 == height_x1):
		return height_x0
	elif height < height_y0 and (height_y0 == height_y1):
		return height_y0
	else:
		return height


func get_height_at_point(x, y) -> float:
	return int(noise_generator.get_noise_2d(x, y) * 3) * 0.5


func good_sign(num):
	if num > 0.1:
		return 1
	elif num < -0.1:
		return -1
	else:
		return 0
