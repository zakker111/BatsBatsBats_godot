#NOTE:z index needs to be 1 to show always top of eweryhing else in inspector
extends KinematicBody2D

#script global variables
onready var healthbar = get_node("HealthBar")
var run_speed = 80
var velocity = Vector2.ZERO
var state_machine
var health
var max_health = 10

func _ready():
	#default healt on start
	health = max_health
	#add_child(healthbar)
	healthbar._on_max_health_ubdated(health)
	healthbar._on_health_update(health, 0)
	#when ready state machine gets animationtree playback
	state_machine = $AnimationTree.get("parameters/playback")
	add_to_group("player")
	
func get_input():
	#set velocity at start to zero
	velocity = Vector2.ZERO
	#attack is input_map mouse left return to get other inputs
	if Input.is_action_just_pressed("attack"):
		state_machine.travel("attack1")
		return
	#inputs for movement sprite scale for flipping sprite input_map wasd
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
		$Sprite.scale.x = 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
		$Sprite.scale.x = -1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y = 1
	#velosity is runspeed
	velocity = velocity.normalized() * run_speed
	#if velocity is something else than 0 running
	if velocity.length() != 0:
		state_machine.travel("run")
	#if velocity is 0 idling
	if velocity.length() == 0:
		state_machine.travel("idle")

#in physics process chek inputs and velocity
func _physics_process(delta):
	get_input()
	velocity = move_and_slide(velocity)

#if get hit use hurt function and show hurt animation
func take_damage(ammount) -> void:
	#decrease health 
	health -= ammount
	#ubdate healthbar
	healthbar._on_health_update(health, ammount)
	#show hurt animation
	state_machine.travel("hurt")
	#if health 0 use die() function
	if (health <= 0):
		die()

#if died cant move and show die animation
func die() -> void:
	state_machine.travel("die")
	set_physics_process(false)
	var parent = get_parent()
	$CollisionShape2D.disabled = true
	#use level clean up function
	parent._do_game_clean_up()
	#free player from memory
	queue_free()

#when sword hits to hurbox wich is in enemies this hitbox is done in animation player and enemies needs hurtbox
func _on_SwordHit_area_entered(area) -> void:
	if area.is_in_group("hurtbox"):
		var ammount = 1
		#to get parent of area enemy scripts needs to bee root of kinematc body to use parent methods
		var parent = area.get_parent()
		parent.take_damage(ammount)
	else:
		pass
		#just for debuggin
		#print(area.get_instance_id())

#this is events area2d in player to chek special things
func _on_Events_area_entered(area) -> void:
	#if area is in consumables group 
	if(area.is_in_group("consumable")):
		#if areas name is Potion
		if area.name == "Potion":
			#if health is smaller than max_health drink_potion() returns healing ammount add it to players health
			if health < max_health:
				#using potion drink potion method
				health += (area.drink_potion())
				#ubdate health bar
				healthbar._on_health_update(health, area.drink_potion())
