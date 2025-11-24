@tool
# WindManager.gd
extends Node3D
class_name WindManager

@export var wind_direction: Vector3 = Vector3.FORWARD
@export var wind_strength: float = 2.0

static var instance: WindManager = null

var shaft: MeshInstance3D
var head: MeshInstance3D

func _ready():
	instance = self
	_create_arrow()
	_update_arrow()

func _create_arrow():
	# Shaft
	shaft = MeshInstance3D.new()
	var cyl = CylinderMesh.new()
	cyl.height = 1.0
	cyl.radius = 0.05
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.0,0.7,1.0)
	cyl.material = mat
	shaft.mesh = cyl
	add_child(shaft)

	# Head (Kegel)
	head = MeshInstance3D.new()
	var cone = CylinderMesh.new()
	cone.height = 0.3
	cone.bottom_radius = 0.0
	cone.radius = 0.12
	var mat2 = StandardMaterial3D.new()
	mat2.albedo_color = Color(0.0,0.7,1.0)
	cone.material = mat2
	head.mesh = cone
	add_child(head)

func _update_arrow():
	if not shaft or not head:
		return

	var dir = wind_direction
	if dir.length() < 0.001:
		dir = Vector3.FORWARD
	else:
		dir = dir.normalized()

	var length = max(wind_strength, 0.01)

	# Shaft: skalieren entlang Y und verschieben
	var shaft_height = length * 0.6
	shaft.scale = Vector3(1, shaft_height, 1)
	shaft.transform.origin = dir * (shaft_height * 0.5)

	# Head: Spitze am Ende
	var head_pos = dir * (shaft_height + length * 0.15)
	head.scale = Vector3.ONE * (length * 0.4)
	head.transform.origin = head_pos
