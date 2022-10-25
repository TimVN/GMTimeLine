wave = new Timeline()
	.spawn(room_width / 2, 200, 1, 1, OMonster, SpawnMode.Destroy, { direction: 270 })
	.spawn(room_width / 2, room_height - 200, 1, 1, OMonster, SpawnMode.Default, { direction: 90 })
	.spawn(200, room_height / 2, 1, 1, OMonster, SpawnMode.Default, { direction: 0 })
	.spawn(room_width - 200, room_height / 2, 1, 1, OMonster, SpawnMode.Default, { direction: 180 })
	.limit(5)
	.await()
	.custom(function(event, index) {
		show_debug_message(current_time);
		var confirm = show_question("Do you want to continue?");
		
		if (confirm) {
			event.finish(index);
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
	var seconds = data.duration / 1000;
	
	show_debug_message("The timeline took " + string(seconds) + " seconds to complete");
});

wave.start();
