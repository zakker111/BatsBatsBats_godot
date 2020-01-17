extends Node

var bat
var player
var potion
var rand
var spawn_timer = null
var spawn_time
var killed_counter = 0
var UiKillCounter
var end_menu
onready var endmenuscene = load("res://EndMenu.tscn")
#texture in inspector for dead bats
export(Texture) var texture
#onready is same ase making it var something = something on func_ready():
onready var batscene = load("res://bat.tscn")
onready var adventurescene = load("res://Adventurer.tscn")
onready var potionscene = load("res://Potion.tscn")
onready var map = get_node("TileMap")

#if needs to ad all enemies call just "res://Enemies.tscn" maybe make list of em and call random enemy

func _ready():
	#ui needs to be in canvas layer to work properly
	UiKillCounter = get_node("Ui/LevelGui/RichTextLabel")
	rand = RandomNumberGenerator.new()
	#intantiate bat and player
	player = adventurescene.instance()
	#player needs to only call once at start of level position is default x0 y0
	player.position = map.map_to_world(Vector2(0,0))
	add_child(player)
	#spawn timer setup
	setup_spawn_timer()

#when timer in inspector hits its value this loops aka one shot off
func _on_Timer_timeout() -> void:
	spawn_timer.start()

func _do_spawn_enemies() -> void:
	#to instance new bat 
	bat = batscene.instance()
	#position for new bat using map and random_x_y() method
	bat.position = map.map_to_world(random_x_y())
	#ad bat to children
	add_child(bat)

func _do_spawn_potions() -> void:
	#to spawn potion is 1 in 10 change
	var rand = floor(rand_range(0, 8))
	#if rand is 0 spawn potion
	if rand == 0:
		potion = potionscene.instance()
		potion.position = map.map_to_world(random_x_y())
		add_child(potion)
			

#fuction to make random x and y with in hard coded area
func random_x_y():
	#randomizing every time
	rand.randomize()
	#x,y gets random number in range 
	var x = floor(rand_range(-4, 4))
	var y = floor(rand_range(-3, 3))
	#returns Vector2
	return Vector2(x,y)

#setup for random timer
func setup_spawn_timer() -> void:
	spawn_time = floor(rand_range(0,2))
	spawn_timer = Timer.new()
	spawn_timer.set_one_shot(true)
	spawn_timer.set_wait_time(spawn_time)
	spawn_timer.connect("timeout", self, "on_spawn_timer_complete")
	add_child(spawn_timer)

#when random spawn timer ends chek to make enemies and potions
func on_spawn_timer_complete() -> void:
	_do_spawn_enemies()
	_do_spawn_potions()
	
#when enemy is dead count it and update UI
func count_killed() -> void:
	killed_counter += 1
	UiKillCounter.text = str(killed_counter)
	#end_menu._do_update_kill_count_label(killed_counter)

#when player dies do some cleaning
func _do_game_clean_up():
	#stop timers
	var timer = get_node("Timer")
	timer.stop()
	spawn_timer.stop()
	#loop trought bats and clean em up
	for N in get_node(".").get_children():
		if N.get_child_count() > 0:
			N.queue_free()
	#clean tilemap
	var tilemap = get_node("TileMap")
	tilemap.queue_free()
	#show end menu
	_do_show_end_menu()
	
#instantiate end menu
func _do_show_end_menu():
	end_menu = endmenuscene.instance()
	add_child(end_menu)
	var EndMenu = get_node("EndMenu")
	EndMenu._do_update_kill_count_label(killed_counter)

#method for laying dead bat sprites in floor funktion takes Vector2
func _do_replace_dead_bodies(vector2) -> void:
	#texture is set in inspector uses same texture as bat but only last frame
	var sprite = Sprite.new()
	sprite.texture = texture
	sprite.position = vector2
	sprite.vframes = 3
	sprite.hframes = 5
	sprite.frame = 14
	add_child(sprite)