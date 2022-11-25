extends Spatial

export(PackedScene) var border_wind_scene: PackedScene
export(PackedScene) var border_damage_area_scene: PackedScene
export(int) var border_wind_dimension: int

onready var tile_grid_map := $TerrainGridMap
onready var object_generator := $TerrainGridMap/ObjectGenerator

export(int) var wind_border_width: int = 32
export(int) var terrain_size: int = 32
export(int) var sector_size: int = 16

onready var sector_cnt: int = pow(terrain_size / sector_size, 2)
var cur_sector: int = 0


signal sector_load_pct(load_pct)


func _ready():
	tile_grid_map.clear()
	tile_grid_map.shake_noise()

	# Generating border winds
	var map_size: int = terrain_size + 2 * wind_border_width
	for i in range(0, map_size):
		for j in range(0, map_size):
			if (((i <= wind_border_width) or (i >= (terrain_size + wind_border_width))) or
				((j <= wind_border_width) or (j >= (terrain_size + wind_border_width)))):
				if (i % (border_wind_dimension / 2) == 0) and (j % (border_wind_dimension / 2) == 0):
					var border_wind : Particles = border_wind_scene.instance()
					border_wind.translation = Vector3(
						-map_size / 2 + i,
						0,
						-map_size / 2 + j
					)
					add_child(border_wind)
	
	var border_damage_area : Area = border_damage_area_scene.instance()
	border_damage_area.translation = Vector3(
		(map_size - wind_border_width) / 2.0,
		2.0,
		0.0
	)
	border_damage_area.scale = Vector3(
		wind_border_width / 2.0,
		3.0,
		map_size / 2.0
	)
	add_child(border_damage_area)

	border_damage_area = border_damage_area_scene.instance()
	border_damage_area.translation = Vector3(
		-(map_size - wind_border_width) / 2.0,
		2.0,
		0.0
	)
	border_damage_area.scale = Vector3(
		wind_border_width / 2.0,
		3.0,
		map_size / 2.0
	)
	add_child(border_damage_area)

	border_damage_area = border_damage_area_scene.instance()
	border_damage_area.translation = Vector3(
		0.0,
		2.0,
		(map_size - wind_border_width) / 2.0
	)
	border_damage_area.scale = Vector3(
		(terrain_size - 1.0) / 2.0,
		3.0,
		wind_border_width / 2.0
	)
	add_child(border_damage_area)

	border_damage_area = border_damage_area_scene.instance()
	border_damage_area.translation = Vector3(
		0.0,
		2.0,
		-(map_size - wind_border_width) / 2.0
	)
	border_damage_area.scale = Vector3(
		(terrain_size - 1.0) / 2.0,
		3.0,
		wind_border_width / 2.0
	)
	add_child(border_damage_area)


func _process(delta):
	if cur_sector < sector_cnt:
		var point := Vector2(
			(
				-terrain_size / 2
				+ sector_size * (cur_sector / (terrain_size / sector_size))
				+ sector_size / 2
			),
			(
				-terrain_size / 2
				+ sector_size * (cur_sector % (terrain_size / sector_size))
				+ sector_size / 2
			)
		)
		tile_grid_map.generate_sector(point, sector_size)
		print("Generating sector at: ", point)
		cur_sector += 1
		emit_signal("sector_load_pct", int((100 * cur_sector) / sector_cnt))
