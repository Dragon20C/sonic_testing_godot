extends PuppetS

enum modifiers {BasicAttack,AirAttack,SpecialAttack,BackAttack}
var current_modifier : modifiers = modifiers.BasicAttack
var is_attacking : bool = false
var basic_combo_time_limit : float = 0.35 # 350 Ms
var basic_combo_duration : float = 0.0
var attack_timeline : Array[String] = []
var current_combo_index : int = 0

func _on_enter(_context : Dictionary = {}) -> void:
	#print("Entered %s state" % name)
	current_combo_index = 0
	basic_combo_duration = 0.0
	puppet.anim_controller.set_base("idle")
	attack_timeline.clear()
	
	if _context.has("AttackType"):
		var type : String = _context.get("AttackType")
		
		match type:
			"Basic":
				attack_timeline.append("Attack")
				current_modifier = modifiers.BasicAttack
			"Air":
				puppet.anim_controller.play("air_attack",true)
				current_modifier = modifiers.AirAttack
			"Special":
				current_modifier = modifiers.SpecialAttack
			"Back":
				current_modifier = modifiers.BackAttack
			_:
				print("Unknown attack type %s" % type)

func _on_exit() -> void:
	#print("Exited %s state" % name)
	pass

func _on_update(_delta : float) -> void:
	pass

func _on_physics_update(_delta : float) -> void:
	
	handle_modifiers(_delta)

func handle_transitions() -> void:
	match puppet.is_on_floor():
		true:
			if not puppet.input_dir.is_equal_approx(Vector2.ZERO):
				puppet.anim_controller.play("landing",true)
				puppet.velocity = Vector3.ZERO
				await puppet.animator.animation_finished
				transition("Move")
			else:
				puppet.anim_controller.play("landing",true)
				puppet.velocity = Vector3.ZERO
				await puppet.animator.animation_finished
				transition("Idle")

func handle_modifiers(delta : float) -> void:
	match current_modifier:
		modifiers.BasicAttack:
			
			basic_combo_duration += delta
			# keeps track if multiple combo attack inputs but only for a short duration
			if Input.is_action_just_pressed("attack") and basic_combo_duration < basic_combo_time_limit:
				# limit the combo to 3 since thats how many we can do.
				if attack_timeline.size() < 3:
					attack_timeline.append("attack")
			
			if current_combo_index != attack_timeline.size() and not is_attacking:
				is_attacking = true
				puppet.anim_controller.play("attack_" + str(current_combo_index + 1),true)
				await puppet.animator.animation_finished
				current_combo_index += 1
				is_attacking = false
			
			
			if current_combo_index == attack_timeline.size():
				transition("Idle")
			
		
		modifiers.AirAttack:
			puppet.velocity *= 0.9
			puppet.move_and_slide()
			
			await puppet.animator.animation_finished
			
			if puppet.is_on_floor():
				transition("Idle")
			else:
				transition("Air",{"delay" : true})
			
			return
