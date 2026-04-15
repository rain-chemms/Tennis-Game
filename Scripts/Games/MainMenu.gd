extends Control

@export var mainPanel:Control#主界面
@export var settingPanel:Control#设置界面
@export var matchPanel:Control#比赛准备界面

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func ChangeHostPlayerSide(newSide:bool)->void:
	Global.SetPlayerSide(newSide)
	pass

func ChangeMatchTime(newTime:String) -> void:
	var time:float = 0.0
	if newTime!=null and newTime.is_valid_float():
		time = newTime.to_float()
	Global.SetMatchTime(time)
	pass
