extends Node

signal player_focused(ply)

var keys = 0
var player_turn = false
var party = []

#restart the game
func _restart_game():
	get_tree().reload_current_scene()

#called when pressing the space bar
func _input(event):
	if event.is_action_pressed("ui_select"):
		_restart_game()
