extends RigidBody2D  # Confere que este nó suporta apply_central_impulse

@onready var line: Line2D = $Line2D  # Nó filho criado no editor
var start_pos: Vector2 = Vector2.ZERO
var dragging: bool = false
const SHOT_POWER: float = 10.0  # Multiplicador para calibrar a força do tiro

func _ready() -> void:
	# Esconde o indicador até o início do arraste
	line.visible = false

func _input(event: InputEvent) -> void:
	# Inicia arraste ao pressionar o botão esquerdo
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			start_pos = event.position
			dragging = true
			line.visible = false
		else:
			# Soltou: dispara a bola
			dragging = false
			_shoot_ball(event.position)
	# Atualiza indicador enquanto arrasta
	elif event is InputEventMouseMotion and dragging:
		_update_indicator(start_pos, event.position)

func _update_indicator(start_pos: Vector2, current_pos: Vector2) -> void:
	line.visible = true
	var dir = start_pos - current_pos
	line.points = [Vector2.ZERO, dir]
	line.rotation = dir.angle()

func _shoot_ball(end_pos: Vector2) -> void:
	line.visible = false
	var dir = (start_pos - end_pos).normalized()
	var strength = (start_pos - end_pos).length()
	# Aplica o impulso diretamente no centro do corpo
	apply_central_impulse(dir * strength * SHOT_POWER)
	# (Opcional) Debug: print(linear_velocity)
