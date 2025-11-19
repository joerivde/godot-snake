class_name GameFieldUtils

static func calc_game_field_tile_size(
	game_field_container_width: float,
	game_field_container_height: float,
	required_tiles_x: int,
	required_tiles_y: int
) -> float:
	var tile_size_x: float = game_field_container_width / required_tiles_x
	var tile_size_y: float = game_field_container_height / required_tiles_y
	return minf(tile_size_x, tile_size_y)

static func build_game_field_data(
	field_data: GameFieldData,
	container_size: Vector2,
	tile_amount_x: int,
	tile_amount_y: int,
) -> void:
	field_data.tile_size = calc_game_field_tile_size(
		container_size.x,
		container_size.y,
		tile_amount_x,
		tile_amount_y,
	)

	field_data.game_field_size.x = field_data.tile_size * tile_amount_x
	field_data.game_field_size.y = field_data.tile_size * tile_amount_y

	field_data.tiles.x = tile_amount_x
	field_data.tiles.y = tile_amount_y
