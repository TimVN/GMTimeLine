countdownFont = font_add("Viga-Regular.ttf", 60, false, false, 32, 128);

counter = 0;

updateCounter = function(ms) {
	counter = ms;
}

var waves = new Sequence([
	new Timeline()
		.delay(5, updateCounter)
		.instantiate(200, 200, 10, 1, OMonster, WaitingMode.Destroy)
		.await()
		.instantiate(200, 200, 10, 0.5, OMonster, WaitingMode.Destroy)
		.instantiate(200, 300, 10, 0.5, OMonster, WaitingMode.Destroy)
		.await(),
		
	new Timeline()
		.delay(3, updateCounter)
		.instantiate(200, 200, 20, 0.3, OMonster, WaitingMode.Destroy)
		.await()
]);

waves.start();