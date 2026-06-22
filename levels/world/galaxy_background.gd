extends Sprite2D

@export var rotation_speed: float = 0.003
@export var orbit_speed: float = 0.04

var _time: float = 0.0
var _base_position: Vector2
var _safe_radius: Vector2

func _ready() -> void:
	_base_position = global_position

	# calcule la marge réelle disponible sans jamais sortir du cadre
	var viewport_size: Vector2 = get_viewport_rect().size
	var texture_size: Vector2 = texture.get_size()

	# marge disponible de chaque côté
	var margin_x: float = (texture_size.x - viewport_size.x) / 2.0
	var margin_y: float = (texture_size.y - viewport_size.y) / 2.0

	# amplitude totale des composantes = 1.0 + 0.3 = 1.3x en X, 1.0 + 0.4 = 1.4x en Y
	# on garde une marge de sécurité de 20% en plus pour la rotation
	_safe_radius = Vector2(
		margin_x / 1.3 * 0.8,
		margin_y / 1.4 * 0.8
	)

func _process(delta: float) -> void:
	_time += delta

	var offset: Vector2 = Vector2(
		cos(_time * orbit_speed) * _safe_radius.x + cos(_time * orbit_speed * 2.3) * _safe_radius.x * 0.3,
		sin(_time * orbit_speed * 1.7) * _safe_radius.y + sin(_time * orbit_speed * 0.6) * _safe_radius.y * 0.4
	)

	global_position = _base_position + offset
	rotation += rotation_speed * delta
