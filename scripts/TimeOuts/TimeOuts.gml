global.Timeouts = [];

function Timeout(func, timeout, timeline, progress) constructor {
    _func = func;
    _timer = timeout;
		_timeline = timeline;
		_progress = progress;
}

/** @param {Function} func
  * @param {Real} timeout
  * @param {Struct.Timeline} timeline
	* @param {Function} onProgress
	*/
function setTimeout(func, timeout, timeline = undefined, onProgress = undefined) {
    var timedFunc = new Timeout(func, timeout, timeline, onProgress);
    array_push(global.Timeouts, timedFunc);

    return timedFunc;
}

function processTimeouts() {
    var funcs = global.Timeouts;

    for (var i = array_length(funcs) - 1; i >= 0; i--) {
        var func = funcs[i];

        if (func._timer > 0)  {
            func._timer -= (1 * global.timeScale);

						if (func._progress != undefined) {
							func._progress(func._timer);
						}

            if (func._timer <= 0) {
                func._func();
                delete func;
                array_delete(funcs, i, 1);
            }
        }
    }
}