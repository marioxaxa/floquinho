extends Area2D

@export var speed     := 400.0
@export var lifetime  := 10.0
var velocity := Vector2.ZERO

func _ready() -> void:
	# destrói depois de 'lifetime' segundos
	get_tree().create_timer(lifetime).timeout.connect(queue_free)
	# conecta ao corpo que entrar em contato (Player é um PhysicsBody2D)
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	pass
	#position += velocity * delta

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):   # coloque o Player no grupo "player"
		body.die()                   # método que você criou no Player
		queue_free()                 # some o projétil também
