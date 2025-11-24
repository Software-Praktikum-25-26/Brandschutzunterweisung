@tool
extends Node3D

## Wind Gizmo - Interactive wind direction and force controller
## Usage: Add this script to a Node3D in your scene

@export_range(0.0, 100.0, 0.1) var wind_force: float = 10.0:
	set(value):
		wind_force = value
		_update_gizmo()

@export var wind_direction: Vector3 = Vector3.FORWARD:
	set(value):
		wind_direction = value.normalized() if value.length() > 0 else Vector3.FORWARD
		_update_gizmo()

@export var gizmo_color: Color = Color.CYAN
@export var arrow_length: float = 2.0

func _update_gizmo():
	if Engine.is_editor_hint():
		update_gizmos()

# Get the wind direction in global space
func get_global_wind_direction() -> Vector3:
	return global_transform.basis * wind_direction

# Get wind force
func get_wind_force() -> float:
	return wind_force

# For editor visualization
func _get_configuration_warnings() -> PackedStringArray:
	var warnings = PackedStringArray()
	if wind_force <= 0:
		warnings.append("Wind force is 0 or negative. Set a positive value.")
	return warnings
