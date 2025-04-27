extends Node2D

# Pré-carregue só uma vez; fica mais leve.
const FIREBALL_SCENE := preload("res://scenes/bola_de_fogo.tscn")
const SUN_SCENE      := preload("res://scenes/novo_sol.tscn")
const RAY_SCENE      := preload("res://scenes/raio.tscn")
const HEAT_SCENE     := preload("res://scenes/onda_de_calor.tscn")

@onready var path := %PathFollow2D   # nó que define a posição de tiro

var difficulty      := 1             # cresce a cada “nível”
@export var base_interval   := 1.5           # segundos; começa folgado…
@export var min_interval    := 0.25          # …mas nunca fica menor que isso
var time_since_wave := 0.0           # cronômetro até a próxima onda
var next_delay      := 1.5           # intervalo sorteado da vez
var level_clock     := 0.0           # tempo corrido para subir nível
@export var level_every     := 10.0          # sobe a dificuldade a cada 10 s

@export var fireball_inverted_chance := 1
@export var fireball_base := 0
@export var sun_inverted_chance := 1
@export var sun_base := 0
@export var ray_inverted_chance := 1
@export var ray_base := 0
@export var heat_inverted_chance := 1
@export var heat_base := 0

@onready var player := get_tree().get_first_node_in_group("player") 

func _process(delta: float) -> void:
	time_since_wave += delta
	level_clock     += delta

	# Hora de soltar a próxima leva?
	if time_since_wave >= next_delay:
		spawn_wave()
		time_since_wave = 0.0
		# Sorteia já o atraso do próximo disparo dentro de uma “janela”
		next_delay = randf_range(base_interval * 0.5, base_interval * 1.5)

	# A cada 'level_every' segundos, o jogo fica mais difícil
	if level_clock >= level_every:
		increase_difficulty()
		level_clock = 0.0


func increase_difficulty() -> void:
	difficulty += 1
	# Intervalos médios 10 % menores, mas respeitando o limite mínimo
	base_interval = max(min_interval, base_interval * 0.9)


func spawn_wave() -> void:
	# Exemplo simples — incremente ou personalize do jeito que quiser
	var fireballs   := int(difficulty / fireball_inverted_chance) + fireball_base
	var suns        := int(difficulty / sun_inverted_chance) + sun_base
	var rays        := int(difficulty / ray_inverted_chance) + ray_base
	var heat_waves  := int(difficulty / heat_inverted_chance) + heat_base

	_spawn_projectiles(FIREBALL_SCENE, fireballs)
	_spawn_projectiles(SUN_SCENE,      suns)
	_spawn_projectiles(RAY_SCENE,      rays)
	_spawn_projectiles(HEAT_SCENE,     heat_waves)


func _spawn_projectiles(scene: PackedScene, amount: int) -> void:
	for i in range(amount):
		var proj = scene.instantiate()
		# Posiciona em ponto aleatório do PathFollow
		path.progress_ratio = randf()
		proj.global_position = path.global_position

		# === só para Fireball: calcula direção até o jogador ===
		if proj is Area2D:
			var dir = (player.global_position - proj.global_position).normalized()
			proj.velocity = dir * proj.speed          # velocidade = direção × speed
			proj.rotation = dir.angle()               # vira a sprite (opcional)

		add_child(proj)
