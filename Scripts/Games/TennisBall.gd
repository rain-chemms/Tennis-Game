extends RigidBody2D

var hitTime:int = 0#小球的反弹次数,球速随反弹速度增加
var speed:float = 10.0#当前小球的速度

@export var baseSpeed:float = 300.0#小球基础速度
@export var speedIncreaseUnit:float = 5.0#小球每次反弹时增加的速度
@export var maxSpeed:float = 1200.0#小球的最大速度

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 物理属性设置
	mass = 1.0           # 质量
	gravity_scale = 0.0  # 重力缩放,禁用重力
	linear_damp = 0.1    # 线性阻尼
	angular_damp = 0.1   # 角阻尼
	
	# 碰撞设置
	contact_monitor = true
	max_contacts_reported = 5
	# 创建物理材质
	
	var physics_material = PhysicsMaterial.new()
	physics_material.bounce = 0.5      # 弹性
	physics_material.friction = 0.3    # 摩擦力
	
	# 应用物理材质
	physics_material_override = physics_material
	
	#设置初始速度
	linear_velocity = Vector2(baseSpeed, baseSpeed)
	pass # Replace with function body.
	


func _physics_process(delta: float) -> void:
	#刷新速度值
	speed = baseSpeed
	if hitTime >= 0:
		speed += speedIncreaseUnit * hitTime;
	if speed > maxSpeed:
		speed = maxSpeed
	elif speed < 0.0:
		speed = 0.0
	#修改速度变化
	linear_velocity = linear_velocity.normalized() * speed
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node) -> void:
	hitTime += 1
	pass # Replace with function body.
