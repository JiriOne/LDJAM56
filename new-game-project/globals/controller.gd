extends Node

signal player_focused(ply)

var keys = 0
var player_turn = true
var party = [] 
var enemies = []

#restart the game
func _restart_game():
	get_tree().reload_current_scene()

#called when pressing the space bar
func _input(event):
	if event.is_action_pressed("ui_select"):
		_restart_game()
	if event.is_action_pressed("ui_left"):
		print(party)
	
	

func _process(delta: float) -> void:
	
	#check player done
	if player_turn == true:
		if len(party) > 0:
			var all_done_players = true
			for member in party:
				
				if member.turn_taken == false:
					all_done_players = false
					break
			
			if all_done_players == true:
				for enemy in enemies:
					enemy.turn_taken = false
				player_turn = false
		else:
			player_turn = false
			
		
	#check enemy done
	if player_turn == false:
		if len(enemies) > 0:
			var all_done_enemies = true
			for enemy in enemies:
				
				if enemy.turn_taken == false:
					all_done_enemies = false
					break
			
			if all_done_enemies == true:
				for boi in party:
					boi.turn_taken = false
				player_turn = true
		else:
			for boi in party:
				boi.turn_taken = false
			player_turn = true
		
