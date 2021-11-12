extends Node

var mana_costs : Array = [1.0,2.0,3.0]
var cooldowns : Array = [4.0,5.0,6.0]
var ability_levels : Array = [7,8,9]
var char_damage : float setget ,get_char_damage
var hex_damage : float setget ,get_hex_damage
var slam_damage : float setget ,get_slam_damage
var slam_slow_percentage : float setget ,get_slam_slow_percentage
var slam_slow_duration : float setget ,get_slam_slow_duration
var glas_slow_percentage : float setget ,get_glas_slow_percentage
var glas_slow_duration : float setget ,get_glas_slow_duration
var glas_speed_percentage : float setget ,get_glas_speed_percentage
var glas_speed_duration : float setget ,get_glas_speed_duration

func get_char_damage():
	return 10
func get_hex_damage():
	return 11
func get_slam_damage():
	return 12
func get_slam_slow_percentage():
	return 13
func get_slam_slow_duration():
	return 14
func get_glas_slow_percentage():
	return 15
func get_glas_slow_duration():
	return 16
func get_glas_speed_percentage():
	return 17
func get_glas_speed_duration():
	return 18
