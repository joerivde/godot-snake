class_name SnakeController

var snake_piece_scene: PackedScene
var eat_piece_scene: PackedScene
var nodes: Array[SnakeNode]
# var fill_nodes: Array[Vector2i]
var current_eat_piece: EatPieceNode = EatPieceNode.new()
var game_field: Control
"""
Normalized vector that represents the next horizontal or vertical tile move
"""
var move_dir: Vector2i
var game_field_data: GameFieldData
var move_delay_ms: int
var remaining_move_delay: int
var paused: bool = true

signal normal_piece_eaten()
signal snake_hit_something()

func init_snake(
	initial_move_dir: Vector2i,
	start_tile: Vector2i,
	start_snake_pieces: int,
) -> void:
	self.move_dir = initial_move_dir
	self.remaining_move_delay = self.move_delay_ms
	var nodes_length: int = 0
	for i in start_snake_pieces:
		var tile_pos: Vector2i = start_tile - (initial_move_dir * i)
		var snake_node: SnakeNode = self.create_new_snake_node(
			self.game_field,
			self.game_field_data.tile_size,
			tile_pos,
			nodes_length
		)
		self.nodes.push_back(snake_node)
		nodes_length += 1

	# Instantiate first eat piece
	self.current_eat_piece.tile_pos = self.get_empty_tile()
	self.current_eat_piece.root_ctrl = instantiate_new_eat_piece_control_at(
		self.game_field,
		self.game_field_data.tile_size,
		self.current_eat_piece.tile_pos,
	)

func create_new_snake_node(
	parent: Control,
	tile_size: float,
	tile_pos: Vector2i,
	nodes_length: int,
) -> SnakeNode:
	var snake_piece_ctrl: Control = self.snake_piece_scene.instantiate()
	snake_piece_ctrl.name = "snake_piece_" + str(nodes_length)
	parent.add_child(snake_piece_ctrl)

	snake_piece_ctrl.size = Vector2(tile_size, tile_size)
	snake_piece_ctrl.position = Vector2(
		tile_size * tile_pos.x,
		tile_size * tile_pos.y
	)
	var snake_node: SnakeNode = SnakeNode.new()
	snake_node.root_ctrl = snake_piece_ctrl
	snake_node.tile_pos = tile_pos
	snake_node.previous_tile_pos = tile_pos
	return snake_node

func instantiate_new_eat_piece_control_at(
	parent: Control,
	tile_size: float,
	tile_pos: Vector2i,
) -> Control:
	var eat_piece: Control = self.eat_piece_scene.instantiate()
	parent.add_child(eat_piece)
	eat_piece.size = Vector2(tile_size, tile_size)
	eat_piece.position = Vector2(
		tile_size * tile_pos.x,
		tile_size * tile_pos.y,
	)
	return eat_piece

func set_pause(pause: bool) -> void:
	self.paused = pause

func process(delta: float) -> void:
	if self.paused == true:
		return

	# Convert seconds to ms
	var delta_ms: int = ceili(delta * 1000)
	if self.remaining_move_delay > 0:
		self.remaining_move_delay -= delta_ms
		# print_debug("remaining_move_delay: %d" % [self.remaining_move_delay])
		return

	self.remaining_move_delay = move_delay_ms
	# print_debug("move")
	# print_debug("remaining_move_delay: %d" % [self.remaining_move_delay])

	# Handle the head
	var nodes_len: int = self.nodes.size()
	var node: SnakeNode = self.nodes[0]
	var new_node_tile_pos: Vector2i = node.tile_pos + move_dir
	# TODO: check if snake hit something and potentially exit early
	# Check if snake is out of game field bounds
	if new_node_tile_pos.x < 0 || new_node_tile_pos.x > self.game_field_data.tiles.x - 1 || new_node_tile_pos.y < 0 || new_node_tile_pos.y > self.game_field_data.tiles.y - 1:
		emit_signal("snake_hit_something")
		return
	# Check if snake hit itself
	# -1, we don't check the last node, because that
	# node will become free once everything moves
	for i in range(1, nodes_len - 1):
		var node_tile_pos: Vector2i = nodes[i].tile_pos
		if node_tile_pos == new_node_tile_pos:
			emit_signal("snake_hit_something")
			return

	# Check if snake head is now at position of thing to eat
	var next_node_should_be_filled = false
	if self.current_eat_piece.tile_pos == new_node_tile_pos:
		node.is_filled = true
		self.set_snake_node_filled(node, true)
		# Delete the current eat piece
		self.current_eat_piece.root_ctrl.queue_free()
		# Instantiate a new one
		self.current_eat_piece.tile_pos = self.get_empty_tile()
		self.current_eat_piece.root_ctrl = instantiate_new_eat_piece_control_at(
			self.game_field,
			self.game_field_data.tile_size,
			self.current_eat_piece.tile_pos,
		)

		emit_signal("normal_piece_eaten")

		# TODO: Potentially spawn extra item -> probably separate method
	elif node.is_filled == true:
		node.is_filled = false
		set_snake_node_filled(node, false)
		next_node_should_be_filled = true

	var tile_size: float = self.game_field_data.tile_size
	node.root_ctrl.position = Vector2(
		tile_size * new_node_tile_pos.x,
		tile_size * new_node_tile_pos.y,
	)
	var previous_tile_pos: Vector2i = node.tile_pos
	node.tile_pos = new_node_tile_pos
	node.previous_tile_pos = previous_tile_pos

	# var filled_nodes_len: int = self.fill_nodes.size()
	for i in range(1, nodes_len):
		node = self.nodes[i]
		new_node_tile_pos = previous_tile_pos
		previous_tile_pos = node.tile_pos
		node.root_ctrl.position = Vector2(
			tile_size * new_node_tile_pos.x,
			tile_size * new_node_tile_pos.y,
		)
		node.tile_pos = new_node_tile_pos
		node.previous_tile_pos = previous_tile_pos

		if next_node_should_be_filled:
			node.is_filled = true
			self.set_snake_node_filled(node, true)
			next_node_should_be_filled = false
		elif node.is_filled == true:
			node.is_filled = false
			self.set_snake_node_filled(node, false)
			next_node_should_be_filled = true

	# Spawn a new node at the last position of the previous node
	if next_node_should_be_filled == true:
		var snake_node: SnakeNode = self.create_new_snake_node(
			self.game_field,
			self.game_field_data.tile_size,
			previous_tile_pos,
			nodes_len
		)
		self.nodes.push_back(snake_node)

# func get_is_filled_node(tile_pos: Vector2i, filled_nodes_len: int) -> bool:
# 	for i in filled_nodes_len:
# 		if self.fill_nodes[i] == tile_pos:
# 			return true
#
# 	return false

func set_snake_node_filled(
	node: SnakeNode,
	filled: bool,
) -> void:
	node.root_ctrl.get_node("normal").visible = not filled
	node.root_ctrl.get_node("filled").visible = filled

func get_empty_tile() -> Vector2i:
	var tile_pos: Vector2i = Vector2i.ZERO
	var tiles: Vector2i = self.game_field_data.tiles
	# print_debug("Tiles x: %d and y: %d" % [tiles.x, tiles.y])
	tile_pos.x = floori(randf() * tiles.x)
	tile_pos.y = floori(randf() * tiles.y)
	# print_debug("Empty pos x: %d and y: %d" % [tile_pos.x, tile_pos.y])
	while is_occupied_tile(tile_pos):
		tile_pos.x = floori(randf() * tiles.x)
		tile_pos.y = floori(randf() * tiles.y)

	return tile_pos


func is_occupied_tile(tile_pos: Vector2i) -> bool:
	var nodes_len: int = nodes.size()
	for i in nodes_len:
		var node: SnakeNode = nodes[i]
		if node.tile_pos == tile_pos:
			return true

	# TODO: add checking fruits
	return false

func check_if_allowed_direction(dir: Vector2i) -> bool:
	# If the new direction doesn't move the head to its
	# previous location -> it's allowed
	var head_node_tile: SnakeNode = self.nodes[0]
	var pos_after_dir: Vector2i = head_node_tile.tile_pos + dir
	# print_debug("head_tile: %s | previous_tile: %s | pos_after_dir: %s" % [head_node_tile.tile_pos, head_node_tile.previous_tile_pos, pos_after_dir])
	return pos_after_dir != head_node_tile.previous_tile_pos


# func reset() -> void:
# 	start_tile = Vector2i.ZERO
# 	nodes.clear()

# func add_node_at_end(ctrl: Control) -> void:
# 	var nodes_size: int = nodes.size()
# 	if nodes_size == 0:
# 		return
#
# 	var last_node: SnakeNode = nodes[nodes_size - 1]
