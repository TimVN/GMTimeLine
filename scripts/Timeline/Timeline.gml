function Base() constructor {
	// This function is attached later by the parent wave class
	// It is called by events when they are considered finished
	finish = undefined;
}

enum SpawnMode {
	Default,
	Destroy,
}

function Spawn(x, y, amount, interval, obj, mode, properties) constructor {
	name = "Spawn";
	type = "spawn";
	_x = x;
	_y = y;
	_amount = amount;
	_interval = interval;
	_obj = obj;
	_mode = mode;
	_properties = properties;

	_position = 0;
	_instanceCount = 0;
	
	function onDestroy(instanceId) {
		instance_destroy(instanceId);
		
		_instanceCount--;
		
		// If there's no more instances in this group and the mode is set to 'Destroy'
		// We call the "finish" function. This will continue the timeline of events
		if (_instanceCount == 0 && _mode == SpawnMode.Destroy) {
			finish(index);
		}
	}
	
	function start() {
		_position++;
		
		var instance = instance_create_layer(_x, _y, "Instances", _obj);
		
		// Pass the onDestroy function. Use it to destroy instances
		// Do not use instance_destroy. Simply call destroy(id)
		instance.destroy = onDestroy;
		
		_instanceCount++;
		
		// The 'properties' argument takes a struct with any property you want
		// This includes built-ins (direction, speed, etc.)
		if (_properties != undefined) {
			var keys = variable_struct_get_names(_properties);
			
			for (var i = 0; i < array_length(keys); i++) {
				variable_instance_set(instance,  keys[i], variable_struct_get(_properties, keys[i]));
			}
		}
		
		// If all instances were spawned
		if (_position == _amount) {
			// If the Default mode is used, this event is considered finished after spawning all of them
			if (_mode == SpawnMode.Default) {
				finish(index);
			}
			
			return;
		}
		
		// We're not done spawning, so we set another timeout that will repeat this function
		setTimeout(function() {
			start();
		}, _interval * game_get_speed(gamespeed_fps));
	}
}

function Await() constructor {
	name = "Await";
	type = "await";
	
	function start() {
		// This looks odd, but this event is simply used to indicate we
		// want the system to wait for the current batch of events to end
		show_debug_message("Waiting for active events to complete");
		
		finish(index);
	}
}

function Delay(seconds, callback) : Base() constructor {
	name = "Delay";
	type = "delay";
	
	_delay = seconds * game_get_speed(gamespeed_fps);
	_callback = callback;
	
	function start() {
		show_debug_message("Delaying timeline for " + string(_delay / game_get_speed(gamespeed_fps)) + " seconds");
		
		setTimeout(function() {
			finish(index);
		}, _delay, _callback);
	}
}

function Custom(callback) constructor {
	name = "Custom function";
	type = "custom";
	_callback = callback;
	
	function start() {
		_callback(self, index);
	}
}

function Limit(seconds) constructor {
	name = "Limit";
	type = "optional";
	
	_delay = seconds * game_get_speed(gamespeed_fps);
	_runningEvents = 0;
	
	function start(item, batch) {
		_item = item;
		_batch = batch;
		_runningEvents = item._runningEvents;
		
		// We instantly remove this from the timeline, the timeout will still run
		// If events finish before the timeout, we don't want to be waiting for this timeout
		finish(index);
		
		setTimeout(function() {
			for (var i = 0; i < array_length(_batch); i++) {
				// We loop through the batch passed to this event and finish them
				// If they're already finished, they will be ignored
				finish(_batch[i]);
			}
		}, _delay);
	}
}

/// @function                Timeline()
/// @description             Creates a new timeline
/// @return {Struct.Timeline}
function Timeline() constructor {
	_timeline = [];
	_batch = [];
	_position = 0;
	_runningEvents = 0;
	
	_startedAt = undefined;
	_onFinishCallback = undefined;
	
	onEventFinished = function(index) {
		var _inBatch = false;
		
		// We need to know if the event with index $index is still part of the active batch
		// Reason being that adding a limit event to the batch could clear the batch
		// if the limit is reached before all events in the batch have completed
		for (var i = 0; i < array_length(_batch); i++) {
			if (_batch[i] == index) {
				_inBatch = true;
			}
		}
		
		// If it's not, there's no reason to have it call start() again
		if (!_inBatch) {			
			return;
		}
		
		_runningEvents = max(0, _runningEvents - 1);
		
		if (_runningEvents == 0) {
			if (_position < array_length(_timeline) - 1) {
				start();
			} else if (_onFinishCallback != undefined) {
				show_debug_message("Timeline complete");
				
				_onFinishCallback({
					duration: current_time - _startedAt,
				});
			}
		}
	}
	
	// todo: Fix this function, clear all running events
	reset = function() {
		_position = 0;
		_batch = [];
		_runningEvents = 0;
		ds_list_clear(global.timed_functions);
	}
	
	/// @function                start()
	/// @description             Starts/continues the timeline
	/// @return {Struct.Timeline}
	start = function() {
		if (!_startedAt) {
			_startedAt = current_time;
		}
		
		// Used to keep track of events that will be fired simultaneously
		_batch = [];
		
		for (var i = _position; i < array_length(_timeline); i++) {
			// Add the index of the event to the batch
			array_push(_batch, i);
			_position = i;
			_runningEvents++;
			
			// Add a callback to the instance of this wave
			_timeline[i].index = i;
			_timeline[i].finish = function(index) {
				onEventFinished(index);
			};
			
			show_debug_message("Starting " + _timeline[i].name + " event. Active events: " + string(_runningEvents));
			
			// If the current event is of type 'await' or 'delay', we break out of the loop
			if (_timeline[i].type == "await" || _timeline[i].type == "delay") {
				// We also want to skip over this event in the next iteration
				_position++;
				
				break;
			}
		}
		
		show_debug_message("_________________________________________________________________________________");
		for (var i = 0; i < array_length(_batch); i++) {
			// show_debug_message("Starting timeline item " + string(batch[i])  + " (" + string(_timeline[batch[i]].name) + ")");
			// We pass a reference to the timeline and the current batch of events
			_timeline[_batch[i]].start(self, _batch);
		}
		
		return self;
	}
	
	/// @function									spawn()
	/// @description							Creates a spawn event that will instantiate objects
	/// @param {Real}							x The x coordinate
	/// @param {Real}							y The x coordinate
	/// @param {Real}							amount The amount of objects
	/// @param {Real}							interval The interval in between the spawning of objects
	/// @param {Asset.GMObject}		obj The object to be spawned
	/// @param {Real}							mode The spawn mode
	/// @param {Struct}						properties Properties to be applied to the spawned objects
	/// @return {Struct.Timeline}
	spawn = function(x, y, amount, interval, obj, mode = SpawnMode.Default, properties = {}) {
		array_push(_timeline, new Spawn(x, y, amount, interval, obj, mode, properties));
		
		return self;
	}
	
	/// @function                await()
	/// @description             Allows you to wait for previous events to complete
	/// @return {Struct.Timeline}
	await = function() {
		array_push(_timeline, new Await());
		
		return self;
	}
	
	/// @function                delay()
	/// @description             Allows for a delay between events
	/// @param {Real}						 seconds The delay in seconds
	/// @param {Function}				 [onProgress] The function called every frame during the delay passing back remaining time in frames
	/// @return {Struct.Timeline}
	function delay(seconds, onProgress = undefined) {
		array_push(_timeline, new Delay(seconds, onProgress));
		
		return self;
	}
	
	/// @function                delay()
	/// @description             Allows for a custom function to be called in between events, the function gets called back with the timeline instance as its first argument
	/// @param {Function}				 callback The function to be called back
	/// @return {Struct.Timeline}
	custom = function(callback) {
		array_push(_timeline, new Custom(callback));
		
		return self;
	}
	
	/// @function                delay()
	/// @description             Sets a time limit in seconds for a batch of events to finish
	/// @param {Real}						 seconds The limit in seconds
	/// @return {Struct.Timeline}
	limit = function(seconds) {
		array_push(_timeline, new Limit(seconds));
		
		return self;
	}
	
	// Allows you to listen to when this timeline ends
	onFinish = function(callback) {
		_onFinishCallback = callback;
	}
}

/// @function										Sequence()
/// @description								Creates a new sequence
/// @param {Struct.Timeline[])	timelines Array of Timelines
/// @return {Struct.Sequence}
function Sequence(timelines) constructor {
	_timelines = timelines;
	_position = 0;
	
	onTimelineFinished = function() {
		if (_position < array_length(_timelines)) {
			show_debug_message("Next item");
			start();
		}
	}
	
	/// @function                start()
	/// @description						 Starts the sequence
	start = function() {
		if (_position < array_length(_timelines)) {
			_timelines[_position].onFinish(function() {
				onTimelineFinished();
			});

			_timelines[_position].start();
			
			_position++;
		}
	}
}
