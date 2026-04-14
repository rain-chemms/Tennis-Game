extends Node

func ExitTheGame()->void:
	get_tree().quit()
	pass

func _on_pressed() -> void:
	ExitTheGame()
	pass # Replace with function body.
