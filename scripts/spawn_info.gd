extends Resource

class_name Spawn_Info

@export var wave : int
@export var enemy : Resource
@export var num_of_enemy_groups : int
@export var enemies_per_group : int
@export var delay_between_spawn : int
@export var speed : int
@export var health : int

var num_groups_spawned := 0
var delay_counter := 0
