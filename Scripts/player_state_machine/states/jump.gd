extends PuppetS

func _on_enter(_context : Dictionary = {}) -> void:
	#print("Entered %s state" % name)
	puppet.velocity.y = puppet.jump_force
	puppet.anim_controller.set_base("jumping")

func _on_exit() -> void:
	#print("Exited %s state" % name)
	pass

func _on_update(_delta : float) -> void:
	pass

func _on_physics_update(_delta : float) -> void:
	puppet.velocity.y -= puppet.gravity * _delta
	puppet.handle_movement(_delta)
	
	handle_transitions()

func handle_transitions() -> void:
	
	if Input.is_action_just_pressed("attack"):
		transition("attack",{"AttackType" : "Air"})
		return
	
	match puppet.is_on_floor():
		true:
			if not puppet.input_dir.is_equal_approx(Vector2.ZERO):
				transition("Move")
			else:
				transition("Idle")
		false:
			# only transition to air state if we are falling
			if puppet.velocity.y < 0.0:
				transition("Air")
