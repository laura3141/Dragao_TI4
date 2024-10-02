extends Area2D

var animation_speed = 2
var moving = false
var tile_size = 64
var inputs = {
	"ui_right": Vector2.RIGHT,
	"ui_left": Vector2.LEFT,
	"ui_up": Vector2.UP,
	"ui_down": Vector2.DOWN
}

@onready var ray = $RayCast2D  # A referência do RayCast2D
@onready var animation_player = $AnimationPlayer  # A referência do AnimationPlayer

func _ready():
	if ray:
		position = position.snapped(Vector2.ONE * tile_size)
		position += Vector2.ONE * tile_size / 2
		ray.enabled = true  # Habilita o RayCast2D
	else:
		print("RayCast2D não encontrado!")

	if !animation_player:
		print("AnimationPlayer não encontrado!")

func _unhandled_input(event):
	if moving:
		return
	for dir in inputs.keys():
		if event.is_action_pressed(dir):
			print("Direção pressionada:", dir)  # Verificando se a entrada está sendo detectada
			move(dir)

func move(dir):
	if ray:
		ray.target_position = inputs[dir] * tile_size
		ray.force_raycast_update()

		if !ray.is_colliding():
			print("Movendo na direção:", dir)  # Verificando se a movimentação está sendo chamada
			var tween = get_tree().create_tween()
			tween.tween_property(self, "position", position + inputs[dir] * tile_size, 1.0 / animation_speed).set_trans(Tween.TRANS_SINE)
			moving = true

			# Verificando se o AnimationPlayer existe antes de chamar play
			if animation_player:
				animation_player.play(dir)
			else:
				print("AnimationPlayer não está atribuído corretamente ou é nulo.")
				
			await tween.finished
			moving = false
		else:
			print("Colidindo com algo!")  # Mensagem de colisão
	else:
		print("RayCast2D não está atribuído corretamente ou é nulo.")
