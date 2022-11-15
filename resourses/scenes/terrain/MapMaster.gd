extends Spatial


export (PackedScene) var border_wind_scene : PackedScene
export (int) var border_wind_dimension : int

onready var tile_grid_map := $TerrainGridMap
onready var object_generator := $TerrainGridMap/ObjectGenerator

export (int) var wind_border_width : int = 32
export (int) var terrain_size : int = 32
export (int) var sector_size : int = 16

onready var sector_cnt : int = pow((terrain_size / sector_size), 2) 
var cur_sector : int = 0

func _ready():
	tile_grid_map.clear()
	tile_grid_map.shake_noise()

	# Generating border winds
	for i in terrain_size / border_wind_dimension + 2:
		var border_wind : Particles = border_wind_scene.instance()
		border_wind.translation = Vector3(
			((-terrain_size - border_wind_dimension) / 2.0) + i * border_wind_dimension,
			0,
			(-terrain_size - border_wind_dimension) / 2.0
		)
		add_child(border_wind)
		border_wind = border_wind_scene.instance()
		border_wind.translation = Vector3(
			((-terrain_size - border_wind_dimension) / 2.0) + i * border_wind_dimension,
			0,
			(terrain_size + border_wind_dimension) / 2.0
		)
		add_child(border_wind)
	
	for i in terrain_size / border_wind_dimension:
		var border_wind : Particles = border_wind_scene.instance()
		border_wind.translation = Vector3(
			(-terrain_size - border_wind_dimension) / 2.0,
			0,
			((-terrain_size - border_wind_dimension) / 2.0) + i * border_wind_dimension
		)
		add_child(border_wind)
		border_wind = border_wind_scene.instance()
		border_wind.translation = Vector3(
			(terrain_size + border_wind_dimension) / 2.0,
			0,
			((-terrain_size - border_wind_dimension) / 2.0) + i * border_wind_dimension
		)
		add_child(border_wind)

		# print("border_wind")
		# border_wind = border_wind_scene.instance()
		# border_wind.translation = Vector3(
		# 	0,
		# 	0,
		# 	(terrain_size * sector_size / border_wind_dimension) + border_wind_dimension / 2
		# )
		# add_child(border_wind)

func _process(delta):
	if cur_sector < sector_cnt:
		var point : = Vector2(
			-terrain_size/2 + sector_size * (cur_sector/(terrain_size / sector_size)) + sector_size/2,
			-terrain_size/2 + sector_size * (cur_sector%(terrain_size / sector_size)) + sector_size/2
		)
		tile_grid_map.generate_sector(point, sector_size)
		print("Generating sector at: ", point)
		cur_sector += 1
