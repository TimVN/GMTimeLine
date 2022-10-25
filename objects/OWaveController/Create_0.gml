wave = new Wave()
	.spawn(room_width / 2, 200, 1, 1, OMonster, SpawnMode.Destroy, { direction: 270 })
	.spawn(room_width / 2, room_height - 200, 1, 1, OMonster, SpawnMode.Default, { direction: 90 })
	.spawn(200, room_height / 2, 1, 1, OMonster, SpawnMode.Default, { direction: 0 })
	.spawn(room_width - 200, room_height / 2, 1, 1, OMonster, SpawnMode.Default, { direction: 180 })
	.await()
	.delay(0.5)
	.custom(function(event) {
		var confirm = show_question("Do you want to continue?")		
		if (confirm) {
			event.finish()
		}
	})
	.await()
	.spawn(200, 200, 5, 0.1, OMonster, SpawnMode.Destroy)
	.await()
	.delay(0.5)
	.spawn(200, 200, 1, 1, OMonster)
	.spawn(200, 225, 1, 1, OMonster)
	.spawn(200, 250, 3, 1, OMonster)
	.await()
	.delay(2)
	.spawn(250, 225, 10, 0.1, OMonster, SpawnMode.Destroy)
	.spawn(250, 275, 10, 0.1, OMonster, SpawnMode.Destroy);

wave.onFinish(function(data) {
	show_debug_message(data);
});

setTimeout(function() {
	show_debug_message(wave._timeline[0]);
	wave.start();
}, room_speed);
