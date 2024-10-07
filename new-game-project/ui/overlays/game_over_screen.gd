extends Control

func _ready() -> void:
	Controller.game_over.connect(func(): self.visible = true)

func _on_reset_button_pressed() -> void:
	Controller.party.clear()
	Controller.enemies.clear()
	get_tree().reload_current_scene()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
