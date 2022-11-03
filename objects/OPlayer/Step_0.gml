speed = 0;

direction = point_direction(x, y, mouse_x, mouse_y);

if (keyboard_check(ord("W"))) {
	speed = 6;
}

if (mouse_check_button_pressed(mb_left)) {
	var bullet = instance_create_layer(x, y, "Instances", OBullet);
	
	bullet.direction = direction;
	bullet.image_angle = direction;
	bullet.speed = 25;
}