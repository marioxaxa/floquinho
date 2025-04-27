extends RigidBody2D

# -- Configurações ajustáveis no Inspector --
@export var SHOT_POWER: float = 4.0           # Multiplicador da força do tiro
@export var max_pull_distance: float = 50.0  # Distância máxima que a linha pode ser puxada (pixels)
@export var max_speed: float = 500.0          # Velocidade máxima permitida (pixels/segundo)

# -- Referências a nós filhos --
@onready var line: Line2D = $Line2D  # Certifique-se de ter adicionado um Line2D como filho

signal died                      # broadcast so GameManager / UI can react

@export var invulnerable_time := 0.0   # seconds of i-frames (0 = none)
var hit_on_cooldown := false

# -- Estado interno --
var start_pos: Vector2 = Vector2.ZERO
var dragging: bool = false

func _ready() -> void:
	# Esconde o indicador até começar a arrastar
	line.visible = false

func _input(event: InputEvent) -> void:
	# Inicia arraste ao clicar com o botão esquerdo
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			start_pos = event.position
			dragging = true
			line.visible = false
		else:
			# Ao soltar, dispara a bola
			dragging = false
			_shoot_ball(event.position)
	# Enquanto arrasta, atualiza o indicador
	elif event is InputEventMouseMotion and dragging:
		_update_indicator(start_pos, event.position)

func _update_indicator(start_pos: Vector2, current_pos: Vector2) -> void:
	# Calcula vetor bruto de arraste
	var raw_dir = start_pos - current_pos
	# Limita o comprimento desse vetor
	var drag_vec = raw_dir.limit_length(max_pull_distance)
	# Atualiza Line2D
	line.visible = true
	line.points = [Vector2.ZERO, drag_vec]
	line.rotation = drag_vec.angle()

func _shoot_ball(end_pos: Vector2) -> void:
	# Esconde o indicador
	line.visible = false
	# Reaplica o mesmo clamp usado no indicador
	var raw_dir = start_pos - end_pos
	var shoot_vec = raw_dir.limit_length(max_pull_distance)
	var dir = shoot_vec.normalized()
	var strength = shoot_vec.length()
	# Aplica impulso no centro de massa
	apply_central_impulse(dir * strength * SHOT_POWER)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	# Limita a velocidade máxima
	var vel = state.linear_velocity
	if vel.length() > max_speed:
		state.linear_velocity = vel.normalized() * max_speed
		
func die() -> void:
	hit_on_cooldown = true
	died.emit()                       # inform whoever cares
	$CollisionShape2D.disabled = true # disable further hits

	# Example: restart the level after 1 s
	get_tree().create_timer(3.0).timeout.connect(
		func (): get_tree().reload_current_scene()
	)
