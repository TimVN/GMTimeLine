global.paused = false;

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
		
		// If there's no more instances in this group, and the mode is set to 'Destroy'
		// We call the "finish" function. This will continue the timeline of events
		if (_instanceCount == 0 && _mode == SpawnMode.Destroy) {
			finish();
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
				finish();
			}
			
			return;
		}
		
		// We're not done spawning, so we set another timeout that will repeat this function
		setTimeout(function() {
			start();
		}, _interval * room_speed);
	}
}

function Await() constructor {
	name = "Await";
	type = "await";
	
	function start() {
		// This looks odd, but this event is simply used to indicate we
		// want the system to wait for the current batch of events to end
		finish();
	}
}

function Delay(seconds) : Base() constructor {
	name = "Delay";
	type = "delay";
	
	_delay = seconds * room_speed;
	
	function start() {
		setTimeout(function() {
			finish();
		}, _delay);
	}
}

function Custom(callback) constructor {
	name = "Custom function";
	type = "custom";
	_callback = callback;
	
	function start() {
		_callback(self);
	}
}

/** Wave 
  * 
  *
**/
function Timeline() constructor {
	_timeline = [];
	_position = 0;
	_runningTasks = 0;
	
	_startedAt = undefined;
	_onFinishCallback = undefined;
	
	function onTaskFinish() {
		_runningTasks = max(0, _runningTasks - 1);
		// show_debug_message("Finished position " + string(_position) + " with " + string(_runningTasks) + " running tasks left - "  + string(_position) + ":" + string(array_length(_timeline)));
		
		if (_runningTasks == 0) {
			if (_position < array_length(_timeline) - 1) {
				start();
			} else if (_onFinishCallback != undefined) {
				_onFinishCallback({
					startedAt: _startedAt,
					endedAt: current_time,
					duration: current_time - _startedAt,
				});
			}
		}
	}
	
	function start() {
		if (_startedAt == undefined) {
			_startedAt = current_time;
		}
		
		// Used to keep track of events that will be fired simultaneously
		var batch = [];
		
		for (var i = _position; i < array_length(_timeline); i++) {
			// Add the index of the event to the batch
			array_push(batch, i);
			_position = i;
			_runningTasks++;
			
			// Add a callback to the instance of this wave
			_timeline[i].finish = function() {
				onTaskFinish();
			};
			
			show_debug_message("Starting " + _timeline[i].name + " task. There are now " + string(_runningTasks) + " tasks running");
			
			// If the current event is of type 'await' or 'delay', we break out of the loop
			if (_timeline[i].type == "await" || _timeline[i].type == "delay") {				
				_position++;
				
				break;
			}
		}
		
		// show_debug_message("Starting a batch with " + string(_runningTasks) + " active tasks");
		
		for (var i = 0; i < array_length(batch); i++) {
			// show_debug_message("Starting timeline item " + string(batch[i])  + " (" + string(_timeline[batch[i]].name) + ")");
			_timeline[batch[i]].start();
		}
	}
	
	spawn = function(x, y, amount, interval, obj, mode = SpawnMode.Default, properties = {}) {
		array_push(_timeline, new Spawn(x, y, amount, interval, obj, mode, properties));
		
		return self;
	}
	
	// Used to indicate we want the previous batch of events to finish
	// before continuing
	await = function() {
		array_push(_timeline, new Await());
		
		return self;
	}
	
	// Allows for a delay between events
	delay = function(seconds) {
		array_push(_timeline, new Delay(seconds));
		
		return self;
	}
	
	// Allows for a custom function to be called in between events
	// The callback passed in gets a reference to this instance as an argument
	custom = function(callback) {
		array_push(_timeline, new Custom(callback));
		
		return self;
	}
	
	// Allows you to listen to when this timeline ends
	function onFinish(callback) {
		_onFinishCallback = callback;
	}
}