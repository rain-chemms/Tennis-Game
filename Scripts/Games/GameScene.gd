extends Node2D

@export var timer:Timer = null#计时器

func _ready() -> void:
	#默认启动计时器
	if timer!=null:
		timer.start()
	pass

func GameOver()->void:
	print("GameOver")
	pass

func _on_clock_timer_timeout() -> void:
	GameOver()
	pass # Replace with function body.
