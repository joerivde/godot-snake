class_name UIController extends Node

enum ActiveMenu {NONE = 0, MAIN_MENU = 1, GAME_OVER_MENU = 2}

@export var game_points_value_label: Label
@export var game_time_value_label: Label
@export var game_over_menu_time_value_label: Label
@export var game_over_menu_point_value_label: Label
@export var root_menu_container: Control
@export var main_menu_container: Control
@export var game_over_menu_container: Control
@export var btn_start_game: Button
@export var btn_quit: Button
@export var btn_try_again: Button
@export var btn_goto_main_menu: Button

signal on_start_game_requested()
signal on_quit_game_requested()

func _ready() -> void:
	self.btn_start_game.pressed.connect(self.on_btn_start_game_click)
	self.btn_quit.pressed.connect(self.on_btn_quit_click)
	self.btn_try_again.pressed.connect(self.on_btn_try_again_click)
	self.btn_goto_main_menu.pressed.connect(self.on_btn_goto_main_menu_click)

func set_points(new_points: int) -> void:
	self.game_points_value_label.text = "%03d" % new_points

func update_elapsed_time(minutes: int, seconds: int) -> void:
	# print_debug("Elapsed time: %s:%s" % [minutes_padded, seconds_padded])
	self.game_time_value_label.text = "%02d:%02d" % [minutes, seconds]

func on_btn_start_game_click() -> void:
	# print_debug("clicked btn_start_game")
	emit_signal("on_start_game_requested")

func on_btn_try_again_click() -> void:
	# TODO: Potentially different signal?
	emit_signal("on_start_game_requested")

func on_btn_quit_click() -> void:
	emit_signal("on_quit_game_requested")

func on_btn_goto_main_menu_click() -> void:
	self.set_active_menu(ActiveMenu.MAIN_MENU)

func set_active_menu(menu_to_activate: ActiveMenu) -> void:
	match menu_to_activate:
		ActiveMenu.NONE:
			self.root_menu_container.visible = false
		ActiveMenu.MAIN_MENU:
			self.root_menu_container.visible = true
			self.main_menu_container.visible = true
			self.game_over_menu_container.visible = false
		ActiveMenu.GAME_OVER_MENU:
			self.root_menu_container.visible = true
			self.main_menu_container.visible = false
			self.game_over_menu_container.visible = true

func set_game_over_menu_stats(minutes: int, seconds: int, points: int) -> void:
	self.game_over_menu_time_value_label.text = "%02d:%02d" % [minutes, seconds]
	self.game_over_menu_point_value_label.text = "%03d" % points
