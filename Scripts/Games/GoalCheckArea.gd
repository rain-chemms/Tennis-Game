extends Area2D

@export var checkSide:bool = false#要检测的一方,球接触检测线时检测的那一方得分

const TENNISBALL_SCRIPT = preload("res://Scripts/Games/TennisBall.gd")

#检测小球是否进入
func CheckTennisBallIn(body:Node2D)->void:
	#若进入物体为目标球,重置球的位置并得分
	if body is TENNISBALL_SCRIPT:
		print("BallIn")
		body.ResetPlace()
		if checkSide:#右侧玩家得分
			Global.rightGoal += 1
		else:
			Global.leftGoal += 1
	pass
	
