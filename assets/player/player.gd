extends KinematicBody2D

const MAX_SPEED : float = 150.0;
const ACCELERATION : float = 800.0;
const GRAV : float = 600.0;
const JUMP_STRENGTH : float = 190.0;
var velocity : Vector2 = Vector2.ZERO;
var vsp : float = 0.0;
var wall_jump_timer = 0;
const WALL_JUMP_TIME = 0.5;

onready var animation_player : AnimationPlayer = $AnimationPlayer;
onready var sprite : Sprite = $Sprite;

func _physics_process(delta):
	## Horizontal movement
	var horizontal_input : float = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left");

	if(horizontal_input != 0.0):
		velocity.x += ACCELERATION * horizontal_input * delta;
		sprite.flip_h = horizontal_input != 1;
	else:
		velocity.x -= sign(velocity.x)*ACCELERATION*delta;
		if(abs(velocity.x) < ACCELERATION*delta):
			 velocity.x = 0.0;

	if(abs(velocity.x) > MAX_SPEED):
		velocity.x = sign(velocity.x)*MAX_SPEED;
	
	## Vertical movement
	if(vsp < 10):
		vsp+=GRAV;
	
	### Wall Jump
	if(is_on_wall() and !is_on_floor()):
		if(horizontal_input):
			wall_jump_timer = WALL_JUMP_TIME;
		if(wall_jump_timer > 0):
			velocity.y = 0.0;
			vsp = 0.0;
			if(Input.is_action_just_pressed("ui_up")):
				velocity.y-=JUMP_STRENGTH;
				velocity.x-=horizontal_input*(JUMP_STRENGTH/2);
			else:
				wall_jump_timer-=delta;
	
	### Jump
	if(is_on_floor()):
		vsp = 0.0;
		if(Input.is_action_just_pressed("ui_up")):
			velocity.y-=JUMP_STRENGTH;
	 
	velocity.y+=vsp*delta;

	## Apply collision
	velocity = move_and_slide(velocity, Vector2(0, -1));
	
	## Set animation
	if(velocity.y > 0.0):
		animation_player.play("Fall");
	elif(velocity.y < 0.0):
		animation_player.play("Rise");
	else:
		if velocity.x as int != 0.0:
			animation_player.play("Run");
		else:
			if(is_on_wall() and !is_on_floor() and wall_jump_timer > 0):
				animation_player.play("Slide");
			else:
				animation_player.play("Idle");
	
	animation_player.playback_speed = (abs(velocity.x)/MAX_SPEED) + 0.5;	

func _on_exit_area_entered(body):
	var current_scene = get_tree().get_current_scene().get_name();
	
	match(current_scene):
		"Level1" : get_tree().change_scene("res://Level2.tscn");
	
	print(current_scene)