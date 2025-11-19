class_name UIController extends Node

@export var points_label: Label
@export var time_label: Label

func set_points(new_points: int) -> void:
	points_label.text = "%03d" % new_points

func update_elapsed_time(minutes: int, seconds: int) -> void:
	# print_debug("Elapsed time: %s:%s" % [minutes_padded, seconds_padded])
	time_label.text = "%02d:%02d" % [minutes, seconds]
