wave = new Wave([
	spawn(room_width / 2, 200, 1, 1, OMonster, { direction: 270 }),
	spawn(room_width / 2, room_height - 200, 1, 1, OMonster, { direction: 90 }),
	spawn(200, room_height / 2, 1, 1, OMonster, { direction: 0 }),
	spawn(room_width - 200, room_height / 2, 1, 1, OMonster, { direction: 180 }),
	await(),
	delay(0.5),
	spawn(200, 200, 5, 0.1, OMonster),
	await(),
	delay(0.5),
	spawn(200, 200, 1, 1, OMonster),
	spawn(200, 225, 1, 1, OMonster),
	spawn(200, 250, 3, 1, OMonster),
	await(),
	delay(2),
	spawn(250, 225, 10, 0.1, OMonster),
	spawn(250, 275, 10, 0.1, OMonster),
]);

setTimeout(function() {
	wave.start();
}, room_speed);
