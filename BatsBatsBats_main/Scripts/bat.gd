extends KinematicBody2D

onready var healthbar = get_node("HealthBar")
var alive 
var state_machine
var health
var target
var speed = 30.0
var ai_attack_time = 1
var ai_timer = null
var is_attaking = false

func _ready():
	#start health and ubdate it to healthbar takes value randomly 2-3
	health = floor(rand_range(2, 4))
	#add_child(healthbar)
	healthbar._on_max_health_ubdated(health)
	healthbar._on_health_update(health, 0)
	alive = true
	#this needs to be here to animation statemachine to work
	state_machine = $AnimationTree.get("parameters/playback")
	#target is player aka adventurer
	target = get_node("/root/Main/Level/Adventurer")
	#setupping ai timer for attaking timeout
	setup_ai_timer()

func _process(delta):
	#if dead disable collision and hurt boxes
	if (health <= 0 && alive == true):
		$Area2d/Hurtbox.disabled = true
		$CollisionShape2D.disabled = true
		alive = false

#movement code needs to be in physics process
func _physics_process(delta) -> void:
	#direction to target aka player global position
	var direction = (target.global_position - global_position).normalized()
	#motion to pass move and collide function
	var motion = direction.normalized() * speed * delta
	#chekking collisions with move and collide and moving to player position
	var collision = move_and_collide(motion)
	#if collided
	if collision:
		#node gets collider of what collided with
		var node = collision.collider
		#chekking if collider is in group player(rigidbody2d aka adventurer in this case) and if is_attaking is false
		if node.is_in_group("player")&& is_attaking == false:
			#funktion to attack player
			attack_player(node)
	
#damage function to ubdate healthbar/health and show hurt/die animation
func take_damage(ammount) -> void:
	health -= ammount
	healthbar._on_health_update(health, ammount)
	state_machine.travel("hurt")
	if (health <= 0):
		state_machine.travel("die")
		healthbar.disable()
		set_physics_process(false)
		#use level.count.killed method for gui
		get_parent().count_killed()
		#yeld for while to let dead animation finishing
		yield(get_tree().create_timer(1.0), "timeout")
		#using Level._do_replace_dead_bodies() method get_position() gives Vector2
		get_parent()._do_replace_dead_bodies(get_position())
		#free bat from memory
		queue_free()
	
#function to attack player
func attack_player(node) -> void: #-> void means this function doesnt return anything
	#damage ammount
	var ammount = 1
	#attaking is true
	is_attaking = true
	#setting speed to zero 
	speed = 0
	#using node.take_damage() function
	node.take_damage(ammount)
	#starting timer function
	ai_timer.start()
	
#setting up timer for ai_timer
func setup_ai_timer() -> void:
	ai_timer = Timer.new()
	ai_timer.set_one_shot(true)
	ai_timer.set_wait_time(ai_attack_time)
	#calling on_ai_timer_timeout_complete when timer completed
	ai_timer.connect("timeout", self, "on_ai_timer_timeout_complete")
	add_child(ai_timer)
	
func on_ai_timer_timeout_complete() -> void:
	#not attaking anymore so attaking is false
	is_attaking = false
	#setting speed back to default
	speed = 30.0
