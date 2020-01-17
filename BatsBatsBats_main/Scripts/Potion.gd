extends Area2D

#BUG bats fly under potion
#groups are added in ready fuction
func _ready():
	add_to_group("consumable")

#function to drink potion returns ammount of healing
func drink_potion():
	var ammount = floor(rand_range(1, 3))
	print (ammount)
	return ammount
	

#free potions from memory when players events group exits from potion area
func _on_Potion_area_exited(area):
	if(area.is_in_group("events")):
		queue_free()

#hide potion sprite when player enters in area
func _on_Potion_area_entered(area):
	if(area.is_in_group("events")):
		var sprite = get_node("Sprite")
		sprite.hide()
