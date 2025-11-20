class_name TimeUtils

static func seconds_to_minutes_floored(seconds: int) -> int:
	return floori(seconds / 60.0)

static func seconds_to_minutes_and_remaining_seconds(seconds: int) -> Array[int]:
	var remaining_seconds: int = seconds % 60
	var minutes: int = TimeUtils.seconds_to_minutes_floored(seconds)
	return [minutes, remaining_seconds]
