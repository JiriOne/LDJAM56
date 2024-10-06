extends Node

var keys = 0
var player_turn = false

#restart the game
func _restart_game():
	get_tree().reload_current_scene()

#called when pressing the space bar
func _input(event):
	if event.is_action_pressed("ui_select"):
		_restart_game()
