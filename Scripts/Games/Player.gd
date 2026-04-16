extends RigidBody2D

var direction:Vector2 = Vector2.ZERO#玩家移力大小的前进向量

@export var side:bool = false#代表玩家所属的阵营边 false为左,true为右
@export var moveForce:float = 500.0#玩家的移动力
@export var normalMaxSpeed:float = 500.0#玩家正常移动的速度
var isSlowMode:bool = false#玩家是否处于低速模式
@export var slowMaxSpeed:float = 2.5#玩家慢速移动的速度

@export var isControl:bool = false#代表当前玩家是否为当前客户端控制
@export var isBot:bool = false#是否为机器控制
@export var botSlowActiveDistance:float = 100.0#机器控制时与球距离多少时进行减速急停
@export var botMoveForce:float = 1500.0#玩家的移动力
@export var botAggresiveDistance:float = 200.0#机器发动攻击时与球距离的多少

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
	#机器控制生效
	CheckBotControl()
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
	#玩家可控时才可以相应操作
	if !isControl:
		return
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

const BALL_SCRIPT = preload("res://Scripts/Games/TennisBall.gd")
#机器控制角色移动
func CheckBotControl()->void:
	if !isBot:
		return
	#获取活动场景根节点
	#实时获取场景中的球的位置
	var balls = get_tree().get_nodes_in_group("TennisBall")
	#计算最近的球的索引
	var minDistance:float = INF
	var minDistance_Vector2:Vector2 = Vector2.ZERO
	var minDistanceBall = null
	for ball in balls:
		if ball != null:
			var dis = global_position.distance_to(ball.global_position)
			#print(dis)
			if dis < minDistance:
				minDistance = dis
				minDistance_Vector2.x = global_position.x - ball.global_position.x
				minDistance_Vector2.y = global_position.y - ball.global_position.y	
				minDistanceBall = ball
	direction = Vector2.ZERO	
	#如果X方向球位于自身左侧 minDistance_Vector2.x>0,自身为左侧的队员side = false
	#给予向左的冲量
	if minDistance_Vector2.x > 0.0 and !side:
		direction.x = -1.0
	#如果X方向球位于自身右侧 minDistance_Vector2.x<0,自身为右侧的队员side = true
	#给予向左的冲量
	if minDistance_Vector2.x < 0.0 and side:
		direction.x = 1.0
	#Y方向跟随
	#球在下方则给予向下的冲量,minDistance_Vector2.y<0
	if minDistance_Vector2.y < 0.0:
		direction.y = 1.0
	#球在上方则给予向上的冲量,minDistance_Vector2.y>0
	if minDistance_Vector2.y > 0.0:
		direction.y = -1.0	
	
	#减速急停检测与接球冲刺	
	#进攻击球设置
	#球位于自身半场之前
	if (minDistance_Vector2.x > 0.0 and side) or (minDistance_Vector2.x < 0.0 and !side):
		#如果在锁定距离之内
		if abs(minDistance) < botSlowActiveDistance:
			isSlowMode = true
		else:#在锁定距离外则依据side判断往哪个方向进行接球冲刺
			isSlowMode = false
			if abs(minDistance) < botAggresiveDistance:#在锁定距离外时,如果处于攻击范围内
				if side:
					direction.x = -1.0
				else:
					direction.x = 1.0
			else:#在非攻击距离时
				#如果球往本半场飞行
				if minDistanceBall!=null:
					if side and minDistanceBall.linear_velocity.x > 0.0:
						direction.x = 1.0
						pass
					elif !side and minDistanceBall.linear_velocity.x < 0.0:
						direction.x = -1.0
	else:
		isSlowMode = false

	#急停检测
	#如果最近的球速度方向上第一个与当前物体碰撞,则进行急停
	var space_state = minDistanceBall.get_world_2d().direct_space_state
	var from = minDistanceBall.global_position
	# 射线终点（在速度方向上）
	var velocity = minDistanceBall.linear_velocity
	var to = from + velocity.normalized() * 10000
	# 创建射线查询参数
	var query = PhysicsRayQueryParameters2D.create(from, to)
	# 设置碰撞掩码
	query.collision_mask = 1
	# 排除自身
	query.exclude = [minDistanceBall]
	# 可以设置碰撞检测类型
	query.collide_with_bodies = true
	query.collide_with_areas = false
	# 执行射线检测
	var result = space_state.intersect_ray(query)
	if result:
		#print("检测到碰撞体: ", result.collider.name)
		#print("碰撞点: ", result.position)
		#print("距离: ", from.distance_to(result.position))
		#print("剩余时间: ", from.distance_to(result.position) / velocity.length())
		#检测到自身,则激活慢速状态
		if result.collider == self:
			isSlowMode = true
	#施加力的作用
	apply_central_force(direction.normalized() * botMoveForce)
	pass
