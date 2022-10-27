global.timeScale = 1;
timeBeforeNextRound = 0;

/// @param {Real} msLeft
var updateTime = function(msLeft) {
	timeBeforeNextRound = msLeft;
}

wave = new Timeline()
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

var secondWave = new Timeline()
	.keyPress(vk_enter)
	.every(function(done) {
		// This function is called every step until done() is called
		// This allows you to run any logic you want before continuing
		// The done function can also be passed to other instances for example
		if (keyboard_check_pressed(vk_shift)) {
			done();
		}
	})
	.once(function(done, data) {
		if (data.test) {
			done();
		}
	},
	{
		test: true
	})
	// .keyPress(vk_enter)
	// .keyReleased(vk_enter)
	.spawn(10, 10, 2, 0.2, OMonster, SpawnMode.Default)
	.await();
	
var sequence = new Sequence([secondWave, wave]);

// sequence.start();

test = new Timeline()
	.once(function(done) {
		OLog.logString("Waiting for enter key to be pressed");
		done();
	})
	.keyPress(vk_enter)
	.once(function(done) {
		OLog.logString("Delaying timeline for 2 seconds");
		done();
	})
	.delay(2, updateTime)
	.once(function(done) {
		OLog.logString("Spawning some instances");
		done();
	})
	.spawn(room_width / 2, room_height / 2, 1, 1, OMonster, SpawnMode.Destroy, {
		direction: 90,
	})
	.await()
	.once(function(done) {
		OLog.logString("Waiting for all instances to be destroyed\nSetting timescale to 3, delaying timeline for 2 seconds");
		global.timeScale = 3;
		
		done();
	})
	.delay(4, updateTime)
	.once(function(done) {
		OLog.logString("Starting a function that will scale up the timescale over time\nSpawning more instances, delaying timeline until they are all destroyed");
		done();
	})
	.every(function(done, data) {
		data.timer++;
		
		global.timeScale = data.timer / 50;
		
		if (data.timer == 200) {
			done();
		}
	},
	{
		timer: 0
	})
	.spawn(room_width / 2, room_height / 2, 10, 1, OMonster, SpawnMode.Destroy, {
		direction: 90,
	})
	.await()
	.once(function(done) {
		OLog.logString("Timeline finished");
		global.timeScale = 1;
		
		done();
	});

setTimeout(function() {
	test.start();
}, 1);

defaultFont = font_add("Viga-Regular.ttf", 20, false, false, 32, 128);
countdownFont = font_add("Viga-Regular.ttf", 60, false, false, 32, 128);

function Test(nr) constructor {
	_nr = nr;
}

var t1 = new Test(10);
var t2 = new Test(20);

show_debug_message(t1._nr);