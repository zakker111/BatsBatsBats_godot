extends Control

onready var health_bar = $HealthBar

#ubdate healthbar
func _on_health_update(health, ammount) -> void:
	health_bar.value = health

#ubdate max health to health bar
func _on_max_health_ubdated(max_health) -> void:
	health_bar.max_value = max_health

#disable health bar
func disable() -> void:
	health_bar.visible = false