global.timeScale = 1;
timeBeforeNextRound = 0;

input = new Input();

var updateTime = function(msLeft) {
	timeBeforeNextRound = msLeft;
}

wave = new Timeline(input)
	.keyPress(vk_enter)
	.delay(5, updateTime)
	.delay(5, updateTime)
	.spawn(room_width / 2, 200, 1, 1, OMonster, SpawnMode.Destroy, { direction: 270 })
	.spawn(room_width / 2, room_height - 200, 1, 1, OMonster, SpawnMode.Destroy, { direction: 90 })
	.spawn(200, room_height / 2, 1, 1, OMonster, SpawnMode.Destroy, { direction: 0 })
	.spawn(room_width - 200, room_height / 2, 1, 1, OMonster, SpawnMode.Destroy, { direction: 180 })
	.limit(10)
	.await()
	.delay(1)
	/*.custom(function(event, index) {
		show_debug_message(current_time);
		var confirm = show_question("Do you want to continue?");
		
		if (confirm) {
			event.finish(index);
		}
	})*/
	.await()
	.spawn(200, 200, 5, 0.1, OMonster, SpawnMode.Destroy)
	.await()
	.delay(1)
	.spawn(200, 200, 1, 1, OMonster)
	.spawn(200, 225, 1, 1, OMonster)
	.spawn(200, 250, 3, 1, OMonster)
	.await()
	.delay(22)
	.spawn(250, 225, 10, 0.1, OMonster, SpawnMode.Destroy)
	.spawn(250, 275, 10, 0.1, OMonster, SpawnMode.Destroy)
	.await()
	.delay(30, updateTime)
	.await();

/*wave.onFinish(function(data) {
	var seconds = data.duration / 1000;
	
	show_debug_message("The timeline took " + string(seconds) + " seconds to complete");
});*/

var secondWave = new Timeline(input)
	.keyReleased(vk_enter)
	.spawn(10, 10, 2, 0.2, OMonster, SpawnMode.Default)
	.await();
	
var timeline = new Sequence([secondWave, wave]);

timeline.start();

defaultFont = font_add("Viga-Regular.ttf", 20, false, false, 32, 128);
countdownFont = font_add("Viga-Regular.ttf", 60, false, false, 32, 128);