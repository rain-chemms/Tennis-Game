extends Node2D

@export var timer:Timer = null#计时器
@export var separatePoint:Node2D = null#时间分界符标签
#分钟显示器
@export var minText1:Label = null
@export var minText2:Label = null
#秒钟显示器
@export var secText1:Label = null
@export var secText2:Label = null
#计时器显示框中1为个位,2为十位

#读取游戏时间并显示出来
func ReadTimerAndDisplay():
	if timer != null:
		#获取剩余时间
		var seconds:int = int(timer.time_left)
		#时间分界符外观改变
		if separatePoint!=null:
			if seconds % 2 == 0:
				separatePoint.visible = false
			else:
				separatePoint.visible = true
		var min:int = seconds / 60
		var sec:int = seconds % 60
		#限制最大的分钟显示
		if min > 99:
			min = 99
		elif min < 0:
			min = 0
		if sec < 0:
			sec = 0
		#转为字符串
		var minString:String = str(min)
		var secString:String = str(sec)
		if minString.length() < 2:
			minString = "0" + minString
		elif minString.length() <1:
			minString = "00";
		if secString.length() < 2:
			secString = "0" + secString
		elif secString.length() < 1:
			secString = "00"
		#截取字符串并显示
		#分钟
		minText2.text = minString[0]
		minText1.text = minString[1]
		#秒钟
		secText1.text = secString[0]
		secText2.text = secString[1]
	pass
	
func _process(delta: float) -> void:
	ReadTimerAndDisplay()
	pass
