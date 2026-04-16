extends Node2D

#常量
const PLAYER_SCRIPT = preload("res://Scripts/Games/Player.gd")
const TENNISBALL_SCRIPT = preload("res://Scripts/Games/TennisBall.gd")
const PLAYER_SCENE = preload("res://Scenes/Player.tscn")

'''------------------------------------------------------------'''
#单人游戏处理相关
@export var timer:Timer = null#计时器

@export var tennisBall:TENNISBALL_SCRIPT = null#小球体
@export var leftPlayer:PLAYER_SCRIPT = null#左侧玩家
@export var rightPlayer:PLAYER_SCRIPT = null#右侧玩家

@export var tennisWeb:RigidBody2D = null#球网,获取其位置进行玩家位置初始化
@export var playerInitYOffset:float = 0.0#玩家初始位置与球网的Y偏移量
@export var playerInitXOffset:float = 0.0#玩家初始位置与球网的X偏移量
@export var massagePanel:Node2D = null#信息显示面板

@export var gameOverPanel:Control = null#结算界面

@export var winnerLabel:Label = null#胜利者文字显示
@export var leftPointLabel:Label = null
@export var rightPointLabel:Label = null
const LEFTWIN_LABELSETTINGS = preload("res://Perfabs/LabelSettings/LeftWin.tres")
const RIGHTWIN_LABELSETTINGS = preload("res://Perfabs/LabelSettings/RightWin.tres")
const TIEGAME_LABELSETTINGS = preload("res://Perfabs/LabelSettings/TieGame.tres")

@export var playerContainer:Node2D = null

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
	var leftG:int = Global.leftGoal
	var rightG:int = Global.rightGoal
	#更新得分
	if leftPointLabel!=null:
		leftPointLabel.text = str(leftG)
	if rightPointLabel!=null:
		rightPointLabel.text = str(rightG)
	#更新显示文字
	if winnerLabel!=null:
		if rightG == leftG:#平局
			winnerLabel.text = "TIE"
			winnerLabel.label_settings = TIEGAME_LABELSETTINGS
		elif  rightG > leftG:#右侧获胜
			winnerLabel.text = "RIGHT"
			winnerLabel.label_settings = RIGHTWIN_LABELSETTINGS
		elif rightG < leftG:#左侧获胜
			winnerLabel.text = "LEFT"
			winnerLabel.label_settings = LEFTWIN_LABELSETTINGS
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
	#删除当前所有,创建新的玩家
	ClearPlayerContainer()
	leftPlayer = PLAYER_SCENE.instantiate()
	rightPlayer = PLAYER_SCENE.instantiate()
	playerContainer.add_child(leftPlayer)
	playerContainer.add_child(rightPlayer)
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
'''------------------------------------------------------------'''
#通用函数方法
func ClearPlayerContainer()->void:
	if playerContainer!=null:
		for child in playerContainer.get_children():
			child.queue_free()
			
'''------------------------------------------------------------'''
#多人游戏处理相关
var peer:ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var ip:String = "127.0.0.1"
var port:int = 8989
var isHost:bool = false
#Host最大的连接数
const MAX_CLIENTS:int = 4
func JoinGame():
	var error = peer.create_client(ip,port)
	if error != OK:
		print("加入游戏失败")
		return error
	multiplayer.multiplayer_peer = peer
	pass

func CreateGame():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, MAX_CLIENTS)
	if error != OK:
		print("创建游戏房间失败")
		return error
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	#创建游戏时生成玩家
	#清除playerContiner中的玩家
	ClearPlayerContainer()
	add_net_player(multiplayer.get_unique_id())
	pass

func add_net_player(id:int)->void:
	var newPlayer = PLAYER_SCENE.instantiate()
	newPlayer.name = str(id)
	#设置玩家的阵营
	if newPlayer!=null and (newPlayer is PLAYER_SCRIPT):
		newPlayer.side = Global.choiceSide
	#设置玩家出生地点
	if newPlayer!=null:
		var webPos:Vector2 = Vector2.ZERO
		if tennisWeb!=null:
			webPos = tennisBall.global_position
		if newPlayer.side:
			newPlayer.global_position = webPos + Vector2(playerInitXOffset,playerInitYOffset)
		else:
			newPlayer.global_position = webPos + Vector2(-playerInitXOffset,-playerInitYOffset)
			
	if playerContainer != null:
		playerContainer.add_child(newPlayer)
	pass
	
func _on_peer_connected(id:int) -> void:
	print("已连接新的客户端ID:"+str(id))
	add_net_player(id)
	pass

func Disconnect()->void:
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()

func ChangeIP(newIP:String)->void:
	ip = newIP
	pass

func ChangePort(newPort:String)->void:
	var port:int = 8989
	if newPort.is_valid_int():
		port = newPort.to_int()
	port = port
	pass
