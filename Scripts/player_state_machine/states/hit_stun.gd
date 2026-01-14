extends PuppetS

func _on_enter(_context : Dictionary = {}) -> void:
	#print("Entered %s state" % name)
	pass

func _on_exit() -> void:
	#print("Exited %s state" % name)
	pass

func _on_update(_delta : float) -> void:
	pass

func _on_physics_update(_delta : float) -> void:
	pass
