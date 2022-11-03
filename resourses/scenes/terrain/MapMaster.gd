extends Spatial


onready var tile_grid_map := $TerrainGridMap
onready var object_generator := $TerrainGridMap/ObjectGenerator

export (int) var terrain_size : int = 32
export (int) var sector_size : int = 16

onready var sector_cnt : int = pow((terrain_size / sector_size), 2) 
var cur_sector : int = 0

func _ready():
	tile_grid_map.clear()
	tile_grid_map.shake_noise()

func _process(delta):
	if cur_sector < sector_cnt:
		var point : = Vector2(
			-terrain_size/2 + sector_size * (cur_sector/(terrain_size / sector_size)) + sector_size/2,
			-terrain_size/2 + sector_size * (cur_sector%(terrain_size / sector_size)) + sector_size/2
		)
		tile_grid_map.generate_sector(point, sector_size)
		print("Generating sector at: ", point)
		cur_sector += 1