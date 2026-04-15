extends Node2D

const PLAYER_SCRIPT = preload("res://Scripts/Games/Player.gd")
const TENNISBALL_SCRIPT = preload("res://Scripts/Games/TennisBall.gd")

@export var timer:Timer = null#计时器

@export var tennisBall:TENNISBALL_SCRIPT = null#小球体
@export var tennisInitPos = Vector2(576,323)
@export var leftPlayer:PLAYER_SCRIPT = null#左侧玩家
@export var rightPlayer:PLAYER_SCRIPT = null#右侧玩家

@export var tennisWeb:RigidBody2D = null#球网,获取其位置进行玩家位置初始化
@export var playerInitYOffset:float = 0.0#玩家初始位置与球网的Y偏移量
@export var playerInitXOffset:float = 0.0#玩家初始位置与球网的X偏移量
@export var timeClock:Node2D = null#计时表

func _ready() -> void:
	#默认启动计时器
	if timer != null:
		timer.paused
	if timeClock != null:
		timeClock.visible = false
	pass

func GameOver()->void:
	print("GameOver")
	pass

func SignalGameStart()->void:
	#重置的分数
	Global.leftGoal = 0
	Global.rightGoal = 0
	#计时器重新计时并显示时钟
	if timeClock != null:
		timeClock.visible = true
	if timer!=null:
		timer.wait_time = Global.matchTime
		timer.start()
	#重置球体的位置和打击次数
	if tennisBall!=null:
		tennisBall.hitTime = 0
		tennisBall.global_position = tennisInitPos
		tennisBall.linear_velocity = Vector2.ZERO#使其静止
	#重置两侧玩家的位置
	var webPos:Vector2 = Vector2.ZERO
	if tennisWeb!=null:
		webPos = tennisBall.global_position
	if rightPlayer!=null:
		rightPlayer.global_position = webPos + Vector2(playerInitXOffset,playerInitYOffset)
		#右侧为Bot
		rightPlayer.isControl = false
		rightPlayer.isBot = true
	if leftPlayer!=null:
		leftPlayer.global_position = webPos + Vector2(-playerInitXOffset,-playerInitYOffset)
		#左侧为玩家
		leftPlayer.isControl = true
		leftPlayer.isBot = false
	pass

func _on_clock_timer_timeout() -> void:
	GameOver()
	pass # Replace with function body.
