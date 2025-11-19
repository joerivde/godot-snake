class_name GameFieldController extends Node

@export var game_field_container: Control
@export var game_field: Control

# func _ready() -> void:
# 	# Wait for one frame
# 	await get_tree().process_frame
# 	set_game_field_size()

func set_game_field_size(
	field_data: GameFieldData
) -> void:
	var container_size = game_field_container.size
	game_field.set_size(field_data.game_field_size, true)
	var new_game_field_pos: Vector2 = Vector2(0.0, 0.0)
	new_game_field_pos.x = (container_size.x - field_data.game_field_size.x) / 2
	new_game_field_pos.y = (container_size.y - field_data.game_field_size.y) / 2
	game_field.set_position(new_game_field_pos, true)
