function Timeout(func, timeout, timeline = undefined, progress = undefined) constructor {
	_func = func;
	_timer = timeout;
	_timeline = timeline;
	_progress = progress;
}

function Timeouts() constructor {
	_timeouts = [new Timeout(function() {}, 1)];
	
	// todo: Remove when Feather allows for property descriptors
	// This is hacky
	// Can't describe a class property as of writing, this seems weird but the above tells
	// Feather that it's an array of Timeouts
	array_delete(_timeouts, 0, 1);
	
	/** @param {Function} func
	  * @param {Real} timeout
	  * @param {Struct.Timeline} timeline
		* @param {Function} onProgress
		*/
	function set(func, timeout, timeline = undefined, onProgress = undefined) {
		var timedFunc = new Timeout(func, timeout, timeline, onProgress);
		array_push(_timeouts, timedFunc);

		return timedFunc;
	}

	function process() {
		for (var i = array_length(_timeouts) - 1; i >= 0; i--) {
			var func = _timeouts[i];

			if (func._timer > 0)  {
				func._timer -= (1 * global.timeScale);

				if (func._progress != undefined) {
					func._progress(func._timer);
				}

				if (func._timer <= 0) {
					func._func();
					delete func;
					array_delete(_timeouts, i, 1);
				}
			}
		}
	}
}