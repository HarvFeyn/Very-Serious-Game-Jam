extends CharacterBody2D

@export var speed: float = 300.0

var controls_enabled: bool = true

func _physics_process(_delta: float) -> void:
	if not controls_enabled:
		move_and_slide()
		return

	var direction:float = Input.get_axis("move_left", "move_right")
	velocity.x = direction * speed
	velocity.y = 0

	move_and_slide()

	if direction != 0:
		scale.x = sign(direction)
