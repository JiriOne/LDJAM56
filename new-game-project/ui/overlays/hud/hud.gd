extends Control

func _ready() -> void:
	Controller.hud_update.connect(_on_hud_update)

func _on_hud_update() -> void:
	$KeyDisplay/KeyCounter.text = str(Controller.keys)
