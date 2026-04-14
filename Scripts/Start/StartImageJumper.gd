extends Node

@export var animationPlayer:AnimationPlayer;
@export var normalPlaySpeed:float = 1.0#动画播放速度
@export var accelerateSpeed:float = 4.0#加速时动画播放速度

func _ready() -> void:
	if animationPlayer:
		animationPlayer.speed_scale = normalPlaySpeed
	pass

func _input(event: InputEvent) -> void:
	if event.is_action("JumpStartImage"):
		if animationPlayer:
			animationPlayer.speed_scale = accelerateSpeed
	else:
		if animationPlayer:
			animationPlayer.speed_scale = normalPlaySpeed	
	pass	
