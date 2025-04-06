extends Area2D

signal hit
signal scored

@export var speed := 30.0
@export var range := 50.0

var base_y := 0.0
var moving_upper := false
var moving_lower := false
var base_upper_y := 0.0
var base_lower_y := 0.0

func _ready():
	# Sauvegarde des positions initiales
	base_upper_y = $Upper.position.y
	base_lower_y = $Lower.position.y

	# Choix aléatoire du tuyau à bouger
	if randi_range(0, 1) == 0:
		moving_upper = true
	else:
		moving_lower = true

func _process(delta):
	var offset = sin(Time.get_ticks_msec() / 300.0) * range

	if moving_upper:
		$Upper.position.y = base_upper_y + offset
	if moving_lower:
		$Lower.position.y = base_lower_y + offset

func _on_body_entered(body):
	hit.emit()

func _on_score_area_body_entered(bdy):
	scored.emit()
