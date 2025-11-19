extends Node

@export var game_field_controller: GameFieldController
@export var ui_controller: UIController

@export var start_snake_pieces: int
"""
The initial move delay of the snake in ms. E.g. 500ms
"""
@export var init_snake_move_delay_ms: int
"""
The minimum of ms delay the snake can move at. E.g. 50ms
"""
@export var min_move_delay_ms: int
"""
The amount of ms decreased from the snake movement delay per eaten piece
"""
@export var move_delay_ms_decrease: int
@export var level_tiles_x: int
@export var level_tiles_y: int
@export var points_per_eaten_piece: int
@export var snake_piece_scene: PackedScene
@export var eat_piece_scene: PackedScene

var snake_controller: SnakeController
var points: int
var elapsed_seconds: int
var elapsed_ms: int

func _enter_tree() -> void:
	self.snake_controller = SnakeController.new()
	self.snake_controller.snake_piece_scene = self.snake_piece_scene
	self.snake_controller.eat_piece_scene = self.eat_piece_scene
	self.snake_controller.move_delay_ms = self.init_snake_move_delay_ms
	self.snake_controller.normal_piece_eaten.connect(on_normal_piece_eaten)
	self.snake_controller.snake_hit_something.connect(on_snake_hit_something)

func _ready() -> void:
	snake_controller.game_field = game_field_controller.game_field
	# snake_controller.start_snake_pieces = start_snake_pieces

	# Wait for one frame -> allow UI size to be set
	await get_tree().process_frame

	var container_size: Vector2 = game_field_controller.game_field_container.size
	var field_data: GameFieldData = GameFieldData.new()
	GameFieldUtils.build_game_field_data(
		field_data,
		container_size,
		level_tiles_x,
		level_tiles_y,
	)

	# Calculate and set game field size
	game_field_controller.set_game_field_size(field_data)
	# TODO: Set this via a method, maybe?
	snake_controller.game_field_data = field_data
	var start_tile: Vector2i = Vector2i(
		floori(field_data.tiles.x / 2),
		floori(field_data.tiles.y / 2)
	)
	snake_controller.init_snake(
		Vector2(-1.0, 0.0),
		start_tile,
		self.start_snake_pieces,
	)

	self.snake_controller.set_pause(false)
	self.elapsed_seconds = 0
	self.elapsed_ms = 0

func _process(delta: float) -> void:
	self.snake_controller.process(delta)

	var delta_ms: int = floori(delta * 1000)
	self.elapsed_ms += delta_ms

	if self.elapsed_ms > 999:
		self.elapsed_seconds += 1
		self.elapsed_ms -= 1000
		var seconds: int = self.elapsed_seconds % 60
		var minutes: int = TimeUtils.seconds_to_minutes_floored(self.elapsed_seconds)
		self.ui_controller.update_elapsed_time(minutes, seconds)

func _input(event: InputEvent) -> void:
	var move_dir: Vector2i = Vector2.ZERO
	if event.is_action_pressed("left"):
		move_dir = Vector2i(-1, 0)
	elif event.is_action_pressed("right"):
		move_dir = Vector2i(1, 0)
	elif event.is_action_pressed("up"):
		move_dir = Vector2i(0, -1)
	elif event.is_action_pressed("down"):
		move_dir = Vector2i(0, 1)

	if move_dir != Vector2i.ZERO && self.snake_controller.check_if_allowed_direction(move_dir):
		self.snake_controller.move_dir = move_dir

func on_normal_piece_eaten() -> void:
	self.points += self.points_per_eaten_piece
	self.ui_controller.set_points(self.points)
	# print_debug("Normal piece eaten! New points total: %d" % self.points)

	var new_move_delay_ms: int = self.snake_controller.move_delay_ms - self.move_delay_ms_decrease
	if new_move_delay_ms > self.min_move_delay_ms:
		self.snake_controller.move_delay_ms = new_move_delay_ms

	# self.ui_controller.set_points(self.points)

func on_snake_hit_something() -> void:
	print_debug("GAME OVER")
	get_tree().paused = true
