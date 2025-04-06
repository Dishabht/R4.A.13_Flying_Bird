extends Node

@export var pipe_scene : PackedScene

var game_running : bool
var game_over : bool
var scroll
var score
var scroll_speed : float = 4.0
var screen_size : Vector2i
var ground_height : int
var pipes : Array
const PIPE_DELAY : int = 100
const PIPE_RANGE : int = 250

@onready var start_panel = $StartPanel  # Récupère le StartPanel qui est le parent de ToucheLabel et TitreImage

func _ready():
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	new_game()

	# Afficher le StartPanel avec tous ses enfants
	start_panel.visible = true

func new_game():
	game_running = false
	game_over = false
	score = 0
	scroll = 0
	scroll_speed = 4.0
	$ScoreLabel.text = "SCORE: " + str(score)
	$GameOver.hide()
	get_tree().call_group("pipes", "queue_free")
	pipes.clear()
	generate_pipes()
	$Bird.reset()
	$PipeTimer.wait_time = 2.0

func _input(event):
	if not game_over:
		if event is InputEventKey:
			if event.keycode == KEY_SPACE and event.pressed:
				if not game_running:
					# Lorsque l'utilisateur appuie sur Espace, on commence le jeu et on cache le StartPanel
					start_game()
					start_panel.visible = false  # Masquer tout le StartPanel (titre + texte)

				else:
					if $Bird.flying:
						$Bird.flap()
						check_top()

func start_game():
	game_running = true
	$Bird.flying = true
	$Bird.flap()
	$PipeTimer.start()

func _process(delta):
	if game_running:
		scroll += scroll_speed
		if scroll >= screen_size.x:
			scroll = 0
		$Ground.position.x = -scroll

		for pipe in pipes:
			pipe.position.x -= scroll_speed

		scroll_speed = min(scroll_speed + delta * 0.1, 10.0)

func _on_pipe_timer_timeout():
	generate_pipes()
	$PipeTimer.wait_time = randf_range(1.0, 2.0)
	$PipeTimer.start()

func generate_pipes():
	var pipe = pipe_scene.instantiate()
	pipe.position.x = screen_size.x + PIPE_DELAY
	pipe.position.y = (screen_size.y - ground_height) / 2 + randi_range(-PIPE_RANGE, PIPE_RANGE)
	
	# Personnalisation du mouvement vertical
	pipe.range = randf_range(30.0, 70.0)
	pipe.speed = randf_range(20.0, 50.0)

	pipe.hit.connect(bird_hit)
	pipe.scored.connect(scored)
	add_child(pipe)
	pipes.append(pipe)

func scored():
	score += 1
	$ScoreLabel.text = "SCORE: " + str(score)

func check_top():
	if $Bird.position.y < 0:
		$Bird.falling = true
		stop_game()

func stop_game():
	$PipeTimer.stop()
	$GameOver.show()
	$Bird.flying = false
	game_running = false
	game_over = true

func bird_hit():
	$Bird.falling = true
	stop_game()

func _on_ground_hit():
	$Bird.falling = false
	stop_game()

func _on_game_over_restart():
	new_game()
