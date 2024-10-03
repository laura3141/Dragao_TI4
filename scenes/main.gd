extends Node

@export var snake_scene: PackedScene
@export var snake_segment: PackedScene
@export var dir_scene: PackedScene
@export var esq_scene: PackedScene
@export var esticadir_scene: PackedScene  # Nova cena esticada para direita
@export var esticaesq_scene: PackedScene  # Nova cena esticada para esquerda

# Game variables
var score: int
var game_started: bool = false

# Grid variables
var cells: int = 32
var cell_size: int = 32

# Food variables
var food_pos: Vector2
var regen_food: bool = true

# Snake variables
var old_data: Array
var snake_data: Array
var snake: Array

# Movement variables
var start_pos = Vector2(15.5, 27.5)
var up = Vector2(0, -1)
var down = Vector2(0, 1)
var left = Vector2(-1, 0)
var right = Vector2(1, 0)
var move_direction: Vector2
var can_move: bool = true

# Variáveis para rastrear a última direção
var last_move_direction: Vector2
var consecutive_moves: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	new_game()

func new_game():
	get_tree().paused = false
	get_tree().call_group("segments", "queue_free")
	$GameOverMenu.hide()
	score = 0
	$Hud.get_node("ScoreLabel").text = "SCORE: " + str(score)
	move_direction = up
	last_move_direction = move_direction
	can_move = true
	generate_snake()
	move_food()

func generate_snake():
	old_data.clear()
	snake_data.clear()
	snake.clear()
	for i in range(3):
		add_segment(start_pos + Vector2(0, i))

func add_segment(pos):
	snake_data.append(pos)
	var SnakeSegment = snake_scene.instantiate()
	SnakeSegment.position = (pos * cell_size) + Vector2(0, cell_size)
	add_child(SnakeSegment)
	snake.append(SnakeSegment)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_snake()

func move_snake():
	if can_move:
		var new_direction: Vector2 = Vector2.ZERO

		if Input.is_action_just_pressed("move_up") and move_direction != down:
			new_direction = up
		elif Input.is_action_just_pressed("move_down") and move_direction != up:
			new_direction = down
		elif Input.is_action_just_pressed("move_left") and move_direction != right:
			new_direction = left
		elif Input.is_action_just_pressed("move_right") and move_direction != left:
			new_direction = right

		if new_direction != Vector2.ZERO:
			if new_direction == last_move_direction:
				consecutive_moves += 1  # Incrementa o contador se for a mesma direção
			else:
				consecutive_moves = 1  # Reseta o contador se for uma nova direção

			last_move_direction = new_direction  # Atualiza a última direção
			move_direction = new_direction  # Atualiza a direção de movimento

			can_move = false
			add_scene_snake_segment()  # Adiciona o segmento da cobra

			# Lógica para adicionar as cenas corretas
			if move_direction == left:
				if consecutive_moves == 1:
					add_scene_esq()
				else:
					add_scene_esticaesq()
			elif move_direction == right:
				if consecutive_moves == 1:
					add_scene_dir()
				else:
					add_scene_esticadir()

			move_by_one_tile()

func move_by_one_tile():
	old_data = [] + snake_data
	snake_data[0] += move_direction
	for i in range(len(snake_data)):
		if i > 0:
			snake_data[i] = old_data[i - 1]
		snake[i].position = (snake_data[i] * cell_size) + Vector2(0, cell_size)

	check_out_of_bounds()
	check_self_eaten()
	check_food_eaten()

	can_move = true

# Funções para adicionar cenas específicas
func add_scene_dir():
	if dir_scene != null:
		var scene_instance = dir_scene.instantiate()
		scene_instance.position = (snake_data[0] * cell_size) + Vector2(0, cell_size)
		add_child(scene_instance)
		print("Cena para direita instanciada.")
	else:
		print("A cena 'dir_scene' não foi atribuída no editor!")

func add_scene_esq():
	if esq_scene != null:
		var scene_instance = esq_scene.instantiate()
		scene_instance.position = (snake_data[0] * cell_size) + Vector2(0, cell_size)
		add_child(scene_instance)
		print("Cena para esquerda instanciada.")
	else:
		print("A cena 'esq_scene' não foi atribuída no editor!")

func add_scene_esticaesq():
	if esticaesq_scene != null:
		var scene_instance = esticaesq_scene.instantiate()
		scene_instance.position = (snake_data[0] * cell_size) + Vector2(0, cell_size)
		add_child(scene_instance)
		print("Cena esticada para esquerda instanciada.")
	else:
		print("A cena 'esticaesq_scene' não foi atribuída no editor!")

func add_scene_esticadir():
	if esticadir_scene != null:
		var scene_instance = esticadir_scene.instantiate()
		scene_instance.position = (snake_data[0] * cell_size) + Vector2(0, cell_size)
		add_child(scene_instance)
		print("Cena esticada para direita instanciada.")
	else:
		print("A cena 'esticadir_scene' não foi atribuída no editor!")

func add_scene_snake_segment():
	if snake_segment != null:
		var scene_instance = snake_segment.instantiate()
		scene_instance.position = (snake_data[0] * cell_size) + Vector2(0, cell_size)
		add_child(scene_instance)
		print("Cena 'snake_segment' instanciada para frente/trás.")
	else:
		print("A cena 'snake_segment' não foi atribuída no editor!")

func check_out_of_bounds():
	if snake_data[0].x < 0 or snake_data[0].x > cells - 1 or snake_data[0].y < 0 or snake_data[0].y > cells - 1:
		end_game()

func check_self_eaten():
	for i in range(1, len(snake_data)):
		if snake_data[0] == snake_data[i]:
			end_game()

func check_food_eaten():
	if snake_data[0] == food_pos:
		score += 1
		$Hud.get_node("ScoreLabel").text = "SCORE: " + str(score)
		add_segment(old_data[-1])
		move_food()

func move_food():
	while regen_food:
		regen_food = false
		food_pos = Vector2(randi_range(0, cells - 1), randi_range(0, cells - 1))
		for i in snake_data:
			if food_pos == i:
				regen_food = true
	$Food.position = (food_pos * cell_size) + Vector2(0, cell_size)
	regen_food = true

func end_game():
	$GameOverMenu.show()
	game_started = false
	get_tree().paused = true

func _on_game_over_menu_restart():
	new_game()
