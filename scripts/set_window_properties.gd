extends Node

func _ready() -> void:
	# var w_min_size: Vector2 = DisplayServer.window_get_min_size()
	# print("Min window size: ", w_min_size)
	var w_min_size: Vector2i = Vector2i(800, 600)
	DisplayServer.window_set_min_size(w_min_size)
	var win = get_window()
	win.min_size = w_min_size
	win.size = Vector2i(max(win.size.x, w_min_size.x), max(win.size.y, w_min_size.y))
