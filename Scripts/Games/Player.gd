extends RigidBody2D

var side:bool = false#代表玩家所属的阵营边 false为左,true为右

var isControl:bool = true#代表当前玩家是否为当前客户端控制

var direction:Vector2 = Vector2.ZERO#玩家移力大小的前进向量

@export var moveForce:float = 500.0#玩家的移动力
@export var normalMaxSpeed:float = 500.0#玩家正常移动的速度
var isSlowMode:bool = false#玩家是否处于低速模式
@export var slowMaxSpeed:float = 2.5#玩家慢速移动的速度

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 物理属性设置
	gravity_scale = 0.0  # 重力缩放,禁用重力
	linear_damp = 0.2    # 线性阻尼
	angular_damp = 0.2   # 角阻尼
	# 碰撞设置
	contact_monitor = true
	max_contacts_reported = 5
	# 创建物理材质
	var physics_material = PhysicsMaterial.new()
	physics_material.bounce = 0.5      # 弹性
	physics_material.friction = 0.3    # 摩擦力
	# 应用物理材质
	physics_material_override = physics_material
	pass # Replace with function body.

func _physics_process(delta: float) -> void:	
	#应用速度大小限制
	var nowSpeed:float = linear_velocity.length()
	if isSlowMode:
		if nowSpeed > slowMaxSpeed:
			nowSpeed = slowMaxSpeed
	else:
		if nowSpeed > normalMaxSpeed:
			nowSpeed = normalMaxSpeed
	linear_velocity = linear_velocity.normalized() * nowSpeed
	pass

	
func _input(event: InputEvent) -> void:
	#优先计算玩家的速度和方向
	#Y方向
	direction = Vector2.ZERO
	if event.is_action_pressed("MoveUp"):
		direction.y += -1.0
		#给予玩家力
	elif event.is_action_pressed("MoveDown"):
		direction.y += 1.0
	#X方向
	if event.is_action_pressed("MoveLeft"):
		direction.x += -1.0
	elif event.is_action_pressed("MoveRight"):
		direction.x += 1.0
	apply_central_impulse(direction * moveForce)
	
	#判定低速条件
	if event.is_action_pressed("SlowSpeed"):
		isSlowMode = true
	else:
		isSlowMode = false
	pass
	
