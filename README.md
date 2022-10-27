# GMTimeLine

A pure code approach to timelines in Game Maker

## Examples

GMTimeline allows you to create timelines by simply chaining events, like so:

```javascript
timer = 0;

/// @param {Real} msLeft
var updateTime = function(msLeft) {
  timer = msLeft;
};

timeline = new Timeline()
  .keyPress(vk_enter) // Wait till the Enter key is pressed
  .delay(2, updateTime) // Wait 2 seconds, pass time passed to updateTime function
  // Instantiate 5 instances of OMonster in intervals of 1 second, wait for the instances to be destroyed
  // before considering the event to be finished
  .instantiate(room_width / 2, 500, 5, 1, OMonster, WaitingMode.Destroy, {
    direction: 0 // Pass properties that will be applied to the instances
  })
  .await() // Wait for the previous event to finish
  .delay(2, updateTime) // Wait for 2 seconds
  .instantiate(room_width / 2, 500, 10, 0.5, OMonster, WaitingMode.Destroy, {
    direction: 180
  })
  .await()
  // Run custom logic once
  .once(
    function(done, data) {
      show_debug_message(data.foo);

      done();
    },
    {
      foo: "bar"
    }
  )
  // Run custom logic every step, until done() is called or timeline is released
  .every(
    function(done, data) {
      var seconds = floor(data._secondsPassed);

      // Every second
      if (data.seconds < seconds) {
        effect_create_above(
          ef_firework,
          random(room_width),
          random(room_height),
          10,
          random(c_white)
        );

        data.seconds = seconds;
      }

      // Stop after 5 seconds
      if (seconds == 5) {
        done();
      }
    },
    {
      seconds: 0
    }
  )
  .await(); // Wait for the previous event to finish

timeline.onFinish(function() {
  // Timeline is finished, stop processing any logic left behind by "every"
  timeline.release();
});

timeline.start();
```

Or how about a sequence of timelines:

```javascript
sequence = new Sequence([
  new Timeline()
    .once(function(done) {
      OLog.logString("Starting a sequence of timelines");

      done();
    })
    .delay(3, updateTime)
    .await(),

  new Timeline()
    .once(function(done) {
      OLog.logString(
        "First timeline in sequence finished, second timeline started"
      );

      done();
    })
    .delay(3, updateTime)
    .await()
]);

sequence.onFinish(function(data) {
  OLog.logString(
    "Sequence complete in " + string(data.duration / 1000) + " seconds"
  );
});

setTimeout(function() {
  sequence.start();
}, 1);
```

## Timeline Functions

<dl>
   <dt><a href="#Timeline">Timeline()</a> ⇒ <code>Struct.Timeline</code></dt>
   <dd>
      <p>Creates a new timeline</p>
   </dd>
   <dt><a href="#start">start()</a> ⇒ <code>Struct.Timeline</code></dt>
   <dd>
      <p>Starts/continues the timeline</p>
   </dd>
   <dd>
   <dt><a href="#await"> await()</a> ⇒ <code>Struct.Timeline</code></dt>
   <dd>
      <p>Creates an Instantiate event that will instantiate objects</p>
   </dd>
   <dt><a href="#delay"> delay(seconds, [callback])</a> ⇒ <code>Struct.Timeline</code></dt>
   <dd>
      <p>Delays events from further execution</p>
   </dd>
   <dt><a href="#limit"> limit(seconds)</a> ⇒ <code>Struct.Timeline</code></dt>
   <dd>
      <p>Limits time for previous batch of events to finish. Takes timescale into account. If limit is reached, the timeline will proceed as if the previous batch completed</p>
   </dd>
   <dt><a href="#instantiate"> instantiate(x, y, amount, interval, obj, mode, properties)</a> ⇒ <code>Struct.Timeline</code></dt>
   <dd>
      <p>Creates an Instantiate event that will instantiate objects</p>
   </dd>
   <dt><a href="#keyPress">keyPress(key)</a> ⇒ <code>Struct.Timeline</code></dt>
   <dd>
      <p>Waits for a key to be pressed</p>
   </dd>
   <dt><a href="#keyReleased">keyReleased(key)</a> ⇒ <code>Struct.Timeline</code></dt>
   <dd>
      <p>Waits for a key to be released</p>
   </dd>
   <dt><a href="#every">every(func, data)</a> ⇒ <code>Struct.Timeline</code></dt>
   <dd>
      <p>Allows for a function to be run every step</p>
   </dd>
   <dt><a href="#once">once(callback, data)</a> ⇒ <code>Struct.Timeline</code></dt>
   <dd>
      <p>Allows for a custom function to be called in between events,
         the function gets called	back a callback function that can be called to proceed with the timeline
      </p>
   </dd>
   <dt><a href="#onFinish">onFinish(callback)</a></dt>
   <dd>
      <p>Allow you to pass a function to be called when the timeline is finished</p>
   </dd>
</dl>

<a name="Timeline"></a>

## Timeline() ⇒ <code>Struct.Timeline</code>

Creates a new timeline

**Kind**: global function  
<a name="start"></a>

## start() ⇒ <code>Struct.Timeline</code>

Starts/continues the timeline

<a name="await"></a>

## await() ⇒ <code>Struct.Timeline</code>

Waits for previous events to finish

<a name="delay"></a>

## delay(seconds, [onProgress]) ⇒ <code>Struct.Timeline</code>

Allows for a delay between events

| Param        | Type                  | Description                                                                            |
| ------------ | --------------------- | -------------------------------------------------------------------------------------- |
| seconds      | <code>Real</code>     | The delay in seconds, takes timescale into account                                     |
| [onProgress] | <code>function</code> | The function called every frame during the delay passing back remaining time in frames |

<a name="limit"></a>

## limit(seconds) ⇒ <code>Struct.Timeline</code>

Sets a time limit in seconds for a batch of events to finish

| Param   | Type              | Description                                        |
| ------- | ----------------- | -------------------------------------------------- |
| seconds | <code>Real</code> | The limit in seconds, takes timescale into account |

<a name="keyPress"></a>

## keyPress(key) ⇒ <code>Struct.Timeline</code>

Waits for a key to be pressed

| Param | Type                                                  | Description       |
| ----- | ----------------------------------------------------- | ----------------- |
| key   | <code>Constant.VirtualKey</code> \| <code>Real</code> | Virtual key index |

<a name="keyReleased"></a>

## keyReleased(key) ⇒ <code>Struct.Timeline</code>

Waits for a key to be released

| Param | Type                                                  | Description       |
| ----- | ----------------------------------------------------- | ----------------- |
| key   | <code>Constant.VirtualKey</code> \| <code>Real</code> | Virtual key index |

<a name="instantiate"></a>

## instantiate(x, y, amount, interval, obj, mode, properties) ⇒ <code>Struct.Timeline</code>

Will instantiate objects at the specified interval

| Param      | Type                     | Description                          |
| ---------- | ------------------------ | ------------------------------------ |
| x          | <code>Real</code>        | x coordinate to spawn instance at    |
| y          | <code>Real</code>        | y coordinate to spawn instance at    |
| amount     | <code>Real</code>        | Amount of instances to spawn         |
| interval   | <code>Real</code>        | Interval between each instance       |
| obj        | <code>Object</code>      | Object to instantiate                |
| mode       | <code>WaitingMode</code> | Waiting mode                         |
| properties | <code>Struct</code>      | Properties to apply to each instance |

<a name="every"></a>

## every(func, data) ⇒ <code>Struct.Timeline</code>

Allows for a function to be run every step

| Param | Type                    | Description                                                                                                               |
| ----- | ----------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| func  | <code>function</code>   | Function to run every step - will be passed a function to indicate that the function is done and the timeline can proceed |
| data  | <code>Struct.Any</code> | Data to be passed to the callback function                                                                                |

<a name="once"></a>

## once(callback, data) ⇒ <code>Struct.Timeline</code>

Allows for a custom function to be called in between events,
the function gets **called back a with callback function that can be called to proceed with the timeline**

| Param    | Type                    | Description                                |
| -------- | ----------------------- | ------------------------------------------ |
| callback | <code>function</code>   | The function to be called back             |
| data     | <code>Struct.Any</code> | Data to be passed to the callback function |

<a name="onFinish"></a>

## onFinish(callback) ⇒ <code>void</code>

Allow you to pass a function to be called when the timeline is finished

| Param    | Type                  | Description                                  |
| -------- | --------------------- | -------------------------------------------- |
| callback | <code>function</code> | Function to be called when timeline finishes |
