@tool
extends Platform
class_name Obstacle

@onready var hyperparam: ObstacleParam = load("res://scripts/class/obstacles/hyperparam.tres")
var radius: float = 0.0
var levi_speed: float
var rot_speed: float

func _ready() -> void:
	if Engine.is_editor_hint():
		add_to_group(&"Obstacle", true)
		return
	
	sync_to_physics = false
	self.collision_layer = 1 << 1
	self.collision_mask = 0
		
	var noti: VisibleOnScreenNotifier2D = find_child("VisibleOnScreenNotifier2D")
	if noti == null:
		noti = VisibleOnScreenNotifier2D.new()
		add_child(noti)
	
	noti.rect = Rect2(-50, -50, 100, 100)
	noti.screen_exited.connect(queue_free)
	
	self.scale.x = int(randf() < 0.5) * -2 + 1
	#self.gravity_scale = 0.0
	#self.linear_damp_mode = RigidBody2D.DAMP_MODE_REPLACE
	#self.angular_damp_mode = RigidBody2D.DAMP_MODE_REPLACE
	#self.linear_velocity.y = hyperparam.levi_scale + randf() * sign(hyperparam.levi_scale) * hyperparam.abs_vel.y
	self.rotation = randf() * 2 * PI
	#self.angular_velocity = Utility.rand_normal(0.5) * hyperparam.avg_ang_vel
	rot_speed = Utility.rand_normal(0) * hyperparam.avg_ang_vel
	#levi_speed = hyperparam.levi_scale + randf() * sign(hyperparam.levi_scale) * hyperparam.abs_vel.y
	levi_speed = hyperparam.levi_scale
	
	_take_radius()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	position.y += delta * levi_speed
	rotation += delta * rot_speed

func _take_radius() -> void:
	var collission_shape = $Shape
	match collission_shape.get_class():
		"CollisionShape2D":
			var shape: Shape2D = collission_shape.shape
			match shape.get_class():
				"RectangleShape2D":
					shape = shape as RectangleShape2D
					radius = shape.size.length() / 2
				"CircleShape2D":
					shape = shape as CircleShape2D
					radius = shape.radius
				"CapsuleShape2D":
					shape = shape as CapsuleShape2D
					radius = shape.radius + shape.height / 2
				"ConvexPolygonShape2D":
					shape = shape as ConvexPolygonShape2D
				"ConcavePolygonShape2D":
					shape = shape as ConcavePolygonShape2D
				"ConvexPolygonShape2D", "ConcavePolygonShape2D":
					for vec: Vector2 in shape.points:
						var l: float = vec.length()
						if radius < l:
							radius = l
					radius /= 2
		"CollisionPolygon2D":
			for vec: Vector2 in collission_shape.polygon:
				var l: float = vec.length()
				if radius < l:
					radius = l
			radius /= 2

func get_space_radius() -> float:
	_take_radius()
	return radius
