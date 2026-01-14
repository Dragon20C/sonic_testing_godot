extends Node
class_name Event

var event_type : int = 0
var event_time : float = 0.0

func _init(_event : int, _time : float) -> void:
	event_type = _event
	event_time = _time

func _to_string() -> String:
	return "event : %s, time : %s" %[event_type,event_time]
