extends StateMachine
class_name PuppetSM

@export var puppet : Player

func set_puppet_on_state() -> void:
	for state in _states:
		_states[state].puppet = puppet
