extends Node2D

const PLAYER_SCRIPT = preload("res://Scripts/Games/Player.gd")
const TENNISBALL_SCRIPT = preload("res://Scripts/Games/TennisBall.gd")

@export var timer:Timer = null#计时器

@export var tennisBall:TENNISBALL_SCRIPT = null#小球体
@export var leftPlayer:PLAYER_SCRIPT = null#左侧玩家
@export var rightPlayer:PLAYER_SCRIPT = null#右侧玩家

@export var tennisWeb:RigidBody2D = null#球网,获取其位置进行玩家位置初始化
@export var playerInitYOffset:float = 0.0#玩家初始位置与球网的Y偏移量
@export var playerInitXOffset:float = 0.0#玩家初始位置与球网的X偏移量
@export var massagePanel:Node2D = null#信息显示面板

@export var gameOverPanel:Control = null#结算界面

func _ready() -> void:
	#默认启动计时器
	if timer != null:
		timer.paused
	if massagePanel != null:
		massagePanel.visible = false
	pass

func GameOver()->void:
	print("GameOver")
	#取消玩家控制权
	if leftPlayer != null:
		leftPlayer.isBot = true
		leftPlayer.isControl = false
	if rightPlayer != null:
		rightPlayer.isBot = true
		rightPlayer.isControl = false
	if massagePanel != null:
		massagePanel.visible = false
	#显示结算界面
	if gameOverPanel!=null:
		gameOverPanel.visible = true
	pass

func SignalGameStart()->void:
	#重置的分数
	Global.leftGoal = 0
	Global.rightGoal = 0
	#打开信息显示面板
	if massagePanel != null:
		massagePanel.visible = true
	if timer!=null:
		timer.wait_time = Global.matchTime
		timer.start()
	#重置球体的位置和打击次数
	if tennisBall!=null:
		tennisBall.ResetPlace()
	#重置两侧玩家的位置
	var webPos:Vector2 = Vector2.ZERO
	if tennisWeb!=null:
		webPos = tennisBall.global_position
	if rightPlayer!=null:
		rightPlayer.global_position = webPos + Vector2(playerInitXOffset,playerInitYOffset)
	if leftPlayer!=null:
		leftPlayer.global_position = webPos + Vector2(-playerInitXOffset,-playerInitYOffset)
	#玩家阵营设置
	if rightPlayer!=null and leftPlayer!=null:
		#右侧为玩家,左侧为机器时
		if Global.choiceSide:
			rightPlayer.isControl = true
			rightPlayer.isBot = false
			leftPlayer.isControl = false
			leftPlayer.isBot = true
		else:
			leftPlayer.isControl = true
			leftPlayer.isBot = false
			rightPlayer.isControl = false
			rightPlayer.isBot = true	
	pass

func _on_clock_timer_timeout() -> void:
	GameOver()
	pass # Replace with function body.
