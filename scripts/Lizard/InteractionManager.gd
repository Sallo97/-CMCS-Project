class_name InteractionManager

static var lizs_interacting := []

static func start_interaction(l1: Lizard, l2: Lizard):
	if lizs_interacting.find(l1) != -1 || lizs_interacting.find(l2) != -1 || l1.is_queued_for_deletion() || l2.is_queued_for_deletion():
		return
	lizs_interacting.append(l1)
	lizs_interacting.append(l2)
	stop_lizard(l1, l2)
	
	
static func stop_lizard(l1:Lizard, l2:Lizard):
	l1.stop_velocity()
	l2.stop_velocity()
	var stop_timer: Timer = Timer.new()
	l1.get_tree().root.add_child(stop_timer)
	stop_timer.autostart = true
	stop_timer.one_shot = true
	stop_timer.wait_time = 0.5
	stop_timer.start()
	stop_timer.timeout.connect(arranging_them.bindv([l1,l2]))

static func arranging_them(l1:Lizard, l2:Lizard):
	l1.look_at_from_position(l1.position, l2.position)
	l2.look_at_from_position(l2.position, l1.position)
	# l1.position += l1.global_transform * Vector3.BACK * 0.1
	var distance = l2.position - l1.position
	distance.y = 0
	l1.position -= distance * 0.2
	distance = l1.position - l2.position
	distance.y = 0
	l2.position -= distance * 0.2
	deciding_interaction(l1,l2)

static func deciding_interaction(l1:Lizard, l2:Lizard):
	if(l1.sex != l2.sex):
		lizard_love(l1, l2)
	elif(l1.sex == Constants.Sex.MALE):
		lizard_fight(l1, l2)
	lizs_interacting = lizs_interacting.filter(
		func(l):
			return l != l1 && l != l2)

static func lizard_fight(l1:Lizard, l2:Lizard):
	l1.get_node("FightParticles").emitting = true
	l2.get_node("FightParticles").emitting = true
	# var timer: Timer = Timer.new()
	# timer.autostart = false
	# timer.one_shot = true
	# timer.wait_time = 0.5
	# timer.timeout.connect((func (): 
	# 	if l1 != null: l1.get_node("FightParticles").emitting = false))
	# l1.add_child(timer)
	# timer.start()
	# timer = Timer.new()
	# timer.autostart = false
	# timer.one_shot = true
	# timer.wait_time = 0.5
	# timer.timeout.connect((func (): 
	# 	if l2 != null: l2.get_node("FightParticles").emitting = false))
	# l2.add_child(timer)
	# timer.start()

	var prob_win_l1: float = 0.5
	match l1.morph:
		Constants.Morph.ORANGE:
			prob_win_l1 += 0.2
		Constants.Morph.YELLOW:
			prob_win_l1 -= 0.2

	match l2.morph:
		Constants.Morph.ORANGE:
			prob_win_l1 -= 0.2
		Constants.Morph.YELLOW:
			prob_win_l1 += 0.2		
	
	var win: bool = randf() <= prob_win_l1
	var timer_attack : Timer = Timer.new()
	timer_attack.autostart = true
	timer_attack.one_shot = true
	timer_attack.wait_time = 0.5
	if win:
		l1.update_animation_parameters(1)
		l1.add_child(timer_attack)
		timer_attack.timeout.connect(LizardPool.instance().despawn.bind(l2))
	else:
		l2.update_animation_parameters(1)
		l2.add_child(timer_attack)
		timer_attack.timeout.connect(LizardPool.instance().despawn.bind(l1))

		
	

static func lizard_love(l1:Lizard, l2:Lizard):
	l1.get_node("LoveParticles").emitting = true
	l2.get_node("LoveParticles").emitting = true
	
	var timer: Timer = Timer.new()
	timer.autostart = false
	timer.one_shot = true
	timer.wait_time = 0.5
	timer.timeout.connect((func (): 
		if l1 != null: l1.get_node("LoveParticles").emitting = false))
	
	var prob_mate: float = 0.5
	var male
	if(l1.sex == Constants.Sex.MALE):
		male = l1
	else:
		male = l2
		
	match male.morph:
		Constants.Morph.ORANGE:
			prob_mate += 0.2
		Constants.Morph.BLUE:
			prob_mate -= 0.1
		Constants.Morph.YELLOW:
			prob_mate -= 0.1
	
	var mate: bool = randf() <= prob_mate
	mate = true
	if mate:
		var timer_love : Timer = Timer.new()
		timer_love.autostart = true
		timer_love.one_shot = true
		timer_love.wait_time = 0.5
		l1.update_animation_parameters(2)
		l2.update_animation_parameters(2)
		l1.add_child(timer_love)
		timer_love.timeout.connect(LizardPool.instance().spawn_child.bindv([l1,l2]))
