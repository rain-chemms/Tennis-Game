extends Node2D

@export var leftPointLabel:Label = null
@export var rightPointLabel:Label = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if leftPointLabel!=null:
		leftPointLabel.text = str(Global.leftGoal)
	if rightPointLabel!=null:
		rightPointLabel.text = str(Global.rightGoal)
	pass
