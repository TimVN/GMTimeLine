global.paused = false;

function Base() constructor {
	finish = undefined;
}

enum SpawnMode {
	Default,
	Destroy,
}

function spawn(x, y, amount, interval, obj, mode = SpawnMode.Default, properties = {}) {
	return new Spawn(x, y, amount, interval, obj, mode, properties);
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
		
		if (_instanceCount == 0 && _mode == SpawnMode.Destroy) {
			finish();
		}
	}
	
	function start() {		
		_position++;
		
		var instance = instance_create_layer(_x, _y, "Instances", _obj);
		
		instance.destroy = onDestroy;
		
		_instanceCount++;
		
		if (_properties != undefined) {
			var keys = variable_struct_get_names(_properties);
			
			for (var i = 0; i < array_length(keys); i++) {
				variable_instance_set(instance,  keys[i], variable_struct_get(_properties, keys[i]));
			}
		}
		
		// show_debug_message("Waiting " + string(_interval) + " second(s) before spawning the next entity");
		
		if (_position == _amount) {
			if (_mode == SpawnMode.Default) {
				finish();
			}
			
			return;
		}
		
		setTimeout(function() {
			start();
		}, _interval * room_speed);
	}
}

function await() {
	return new Await();
}

function Await() constructor {
	name = "Await";
	type = "await";
	
	function start() {
		show_debug_message("Awaiting...");
	}
}

function delay(seconds) {
	return new Delay(seconds);
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

/** Wave 
  * 
  *
**/
function Wave(timeline) constructor {
	_timeline = timeline;
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
					endedAt: date_current_datetime(),
				});
			}
		}
	}
	
	for (var i = 0; i < array_length(timeline); i++) {
		_timeline[i].finish = function() {
			onTaskFinish();
		};
	}
	
	function start() {
		// show_debug_message("Starting from position " + string(_position));
		if (_startedAt == undefined) {
			_startedAt = date_current_datetime();
		}
		
		var batch = [];
		
		for (var i = _position; i < array_length(_timeline); i++) {
			array_push(batch, i);
			_position = i;
			_runningTasks++;
			
			// show_debug_message("Starting " + _timeline[i].name + " task. There are now " + string(_runningTasks) + " tasks running");
			
			if (_timeline[i].type == "await" || _timeline[i].type == "delay") {
				show_debug_message("Next item is delayed");
				
				if (_timeline[i].type == "await") {
					_runningTasks = max(0, _runningTasks - 1);
				}
				
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
	
	function onFinish(callback) {
		_onFinishCallback = callback;
	}
}