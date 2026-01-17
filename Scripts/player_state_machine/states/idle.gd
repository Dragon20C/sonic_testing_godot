extends PuppetS

func _on_enter(_context : Dictionary = {}) -> void:
	puppet.anim_controller.set_base("idle")
	#print("Entered %s state" % name)
	
	if _context.has("stopping"):
		if _context.get("stopping") == true:
			puppet.anim_controller.play("stopping",true)
		
	#puppet.animator.play("idle")

func _on_exit() -> void:
	#print("Exited %s state" % name)
	pass

func _on_update(_delta : float) -> void:
	pass

func _on_physics_update(_delta : float) -> void:
	
	#if Input.is_action_just_pressed("attack"):
		#puppet.anim_controller.play("landing",true)
	
	puppet.apply_decceleration(_delta)
	puppet.move_and_slide()
	
	handle_transitions()
	

func handle_transitions() -> void:
	match puppet.is_on_floor():
		true:
			if Input.is_action_just_pressed("attack"):
				transition("Attack",{"AttackType":"Basic"})
			
			if not puppet.input_dir.is_equal_approx(Vector2.ZERO):
				transition("Move")
			
			if Input.is_action_just_pressed("jump"):
				transition("Jump")
		false:
			transition("Air")
