extends Node3D
class_name InputTesting

enum actions {Attack,Special,Move}
enum move_actions {Left,Right,Forward,Backward}

const INPUT_ACTIONS : Array[String] = ["move_forward",
	"move_backward",
	"move_left",
	"move_right", 
	"attack",
	"jump",
	]

var MAX_GAP_MS : int = 200

# dict stores time and input type
# e.g {type : "MoveForward",time : 0.1,duration : float = 0.0}
var timeline: Array[Dictionary] = []
var active_inputs: Dictionary = {}
const MAX_TIMELINE_SIZE : int = 6

var combos_list : Array = []

func _ready() -> void:
	combos_list = [
		{"name":"AttackChain3","inputs": ["attack","attack","attack"]},
		{"name":"AttackChain2","inputs": ["attack","attack"]},
		{"name":"AttackChain1","inputs": ["attack"]},
		{"name":"DashForward","inputs": ["move_forward","move_forward"]},
		{"name":"DashBackward","inputs": ["move_backward","move_backward"]},
		{"name":"DashRight","inputs": ["move_right","move_right"]},
		{"name":"DashLeft","inputs": ["move_left","move_left"]},
	]
	combos_list.sort_custom(_sort_combos_by_length_desc)

func _sort_combos_by_length_desc(a, b) -> int:
	return a["inputs"].size() > b["inputs"].size()
	


func _physics_process(delta: float) -> void:
	for input_name in INPUT_ACTIONS:

		if Input.is_action_just_pressed(input_name):
			_start_input(input_name)

		if Input.is_action_just_released(input_name):
			_end_input(input_name)

	_update_active_durations(delta)
	
	if inputs_have_settled():
		evaluate_combos()

func inputs_have_settled() -> bool:
	if timeline.is_empty():
		return false
		
	var last_input : Dictionary = timeline[-1]
	var now := Time.get_ticks_msec()
	return now - last_input["start_time"] >= MAX_GAP_MS


func _start_input(action_name: String) -> void:
	if active_inputs.has(action_name):
		return

	var entry : Dictionary = {
		"type": action_name,
		"start_time": Time.get_ticks_msec(),
		"duration": 0.0,
		"consumed": false
	}

	active_inputs[action_name] = entry
	timeline.append(entry)

	_trim_timeline()

func _end_input(action_name: String) -> void:
	active_inputs.erase(action_name)

func _trim_timeline() -> void:
	while timeline.size() > MAX_TIMELINE_SIZE:
		timeline.pop_front()

func _update_active_durations(delta: float) -> void:
	for entry in active_inputs.values():
		entry["duration"] += delta

func evaluate_combos() -> void:
	for combo_data in combos_list:
		var combo_name : String = combo_data["name"]
		var combo_inputs : Array = combo_data["inputs"]

		if try_match_combo(combo_inputs, MAX_GAP_MS):
			print("%s has been matched" % combo_name)
			# Only match one combo per frame
			break



func try_match_combo(combo: Array, max_gap_ms: int) -> bool:
	var combo_index : int = combo.size() - 1
	var last_time : int = -1

	for i in range(timeline.size() - 1, -1, -1):
		var entry := timeline[i]

		if entry["consumed"]:
			continue

		if entry["type"] != combo[combo_index]:
			continue

		if last_time != -1:
			if last_time - entry["start_time"] > max_gap_ms:
				return false

		last_time = entry["start_time"]
		combo_index -= 1

		if combo_index < 0:
			consume_inputs(i, combo.size())
			return true

	return false


func consume_inputs(start_index: int, count: int) -> void:
	var remaining : int = count

	for i in range(start_index, timeline.size()):
		if remaining <= 0:
			return

		if timeline[i]["consumed"]:
			continue

		timeline[i]["consumed"] = true
		remaining -= 1



func _on_timer_timeout() -> void:
	if active_inputs.is_empty():
		return
	
	#print(active_inputs)
