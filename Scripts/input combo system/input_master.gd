extends Node
class_name InputMaster

enum inputs {Left,Right,Forward,Backward,Attack,Special,Block}

var time_threshold : float = 0.3 # 250 Ms
var events : Array[Event] = []
var event_size : int = 0

func _update(_delta: float) -> void:
	handle_inputs()
	
	# for debugging
	#if event_size != events.size():
		#var index : int = 0
		#event_size = events.size()
		#for event in events:
			#print("index : %s, %s" %[index,event])
			#index += 1
	
	handle_expired_inputs()

func handle_inputs() -> void:
	if Input.is_action_just_pressed("move_left"):
		var event : Event = Event.new(inputs.Left,Time.get_ticks_msec() / 1000.0)
		events.append(event)
		
	if Input.is_action_just_pressed("move_right"):
		var event : Event = Event.new(inputs.Right,Time.get_ticks_msec() / 1000.0)
		events.append(event)
		
	if Input.is_action_just_pressed("move_forward"):
		var event : Event = Event.new(inputs.Forward,Time.get_ticks_msec() / 1000.0)
		events.append(event)
		
	if Input.is_action_just_pressed("move_backward"):
		var event : Event = Event.new(inputs.Backward,Time.get_ticks_msec() / 1000.0)
		events.append(event)
		
	if Input.is_action_just_pressed("attack"):
		var event : Event = Event.new(inputs.Attack,Time.get_ticks_msec() / 1000.0)
		events.append(event)
		
	if Input.is_action_just_pressed("block"):
		var event : Event = Event.new(inputs.Block,Time.get_ticks_msec() / 1000.0)
		events.append(event)

func match_combo(combo : Combo) -> bool:
	if combo.sequence.size() > events.size():
		return false
	
	var event_index : int = events.size() - 1
	var combo_index : int = combo.sequence.size() - 1
	
	while combo_index >= 0:
		if events[event_index].event_type != combo.sequence[combo_index]:
			return false
		#print("Event type (%s)" % events[event_index].event_type)
		event_index -= 1
		combo_index -= 1
	
	events.clear()
	return true

func handle_expired_inputs() -> void:
	var current_time := Time.get_ticks_msec() / 1000.0
	
	events = events.filter(func(e: Event) -> bool:
		var age := current_time - e.event_time
		return age <= time_threshold
	)
