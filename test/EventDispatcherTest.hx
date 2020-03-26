import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.EventPhase;
import utest.Assert;

class EventDispatcherTest extends utest.Test {
	function test_addEventListener_hasEventListener() {
		var dispatcher = new EventDispatcher();
		dispatcher.addEventListener("event", function(event:Event) {});
		Assert.isTrue(dispatcher.hasEventListener("event"));
	}

	function test_removeEventListener_hasEventListener() {
		var dispatcher = new EventDispatcher();
		function listener(e:Event) {}
		dispatcher.addEventListener("event", listener);
		dispatcher.removeEventListener("event", listener);
		Assert.isFalse(dispatcher.hasEventListener("event"));
	}

	function test_dispatchEvent_basic() { // same as _nocapture below, but without explicit useCapture
		var caughtEvent = false;
		var correctPhase = true;
		var dispatcher = new EventDispatcher();
		dispatcher.addEventListener("event", function(event:Event) {
			caughtEvent = true;
			if (event.eventPhase == EventPhase.CAPTURING_PHASE) {
				correctPhase = false;
			}
		});
		dispatcher.dispatchEvent(new Event("event"));
		Assert.isTrue(caughtEvent);
		Assert.isTrue(correctPhase);
	}

	function test_dispatchEvent_nocapture() {
		var caughtEvent = false;
		var correctPhase = true;
		var dispatcher = new EventDispatcher();
		dispatcher.addEventListener("event", function(event:Event) {
			caughtEvent = true;
			if (event.eventPhase == EventPhase.CAPTURING_PHASE) {
				correctPhase = false;
			}
		}, false);
		dispatcher.dispatchEvent(new Event("event"));
		Assert.isTrue(caughtEvent);
		Assert.isTrue(correctPhase);
	}

	function test_dispatchEvent_capture() {
		var container = new Sprite();
		var child = new Sprite();
		container.addChild(child);
		
		var correctPhase = false; // fail unless we see correct event
		container.addEventListener("event", function(event:Event) {
			correctPhase = (event.eventPhase == EventPhase.CAPTURING_PHASE);
		}, true);
		child.dispatchEvent(new Event("event"));
		Assert.isTrue(correctPhase);
	}

	function test_standard_order() {
		var calls = [];
		var dispatcher = new EventDispatcher();
		dispatcher.addEventListener("event", e -> calls.push(1));
		dispatcher.addEventListener("event", e -> calls.push(2));
		dispatcher.dispatchEvent(new Event("event"));
		Assert.same([1, 2], calls);
	}

	function test_priority() {
		var calls = [];
		var dispatcher = new EventDispatcher();
		dispatcher.addEventListener("event", e -> calls.push(2), false, 10);
		dispatcher.addEventListener("event", e -> calls.push(1), false, 20);
		dispatcher.dispatchEvent(new Event("event"));
		Assert.same([1, 2], calls);
	}

	function test_bubbling_nocapture() {
		var container = new Sprite();
		var child = new Sprite();
		container.addChild(child);

		var calls = [];

		container.addEventListener("event", e -> calls.push("container"));
		child.addEventListener("event", e -> calls.push("child"));
		container.addChild(child);

		child.dispatchEvent(new Event("event"));
		Assert.same(["child"], calls);

		calls.resize(0);
		child.dispatchEvent(new Event("event", true));

		Assert.same(["child", "container"], calls);
	}

	function test_bubbling_capture() {
		var container = new Sprite();
		var child = new Sprite();
		container.addChild(child);

		var calls = [];

		container.addEventListener("event", e -> calls.push("container"), true);
		child.addEventListener("event", e -> calls.push("child"), true);
		container.addChild(child);

		child.dispatchEvent(new Event("event"));
		Assert.same(["container"], calls);

		calls.resize(0);
		child.dispatchEvent(new Event("event", true));

		Assert.same(["container"], calls);
	}

	function test_simpleNestedDispatch() {
		var numCalls = 0;
		var dispatcher = new EventDispatcher();
		dispatcher.addEventListener("event", function(e:Event) {
			numCalls++;
			if (numCalls == 1) { // avoid infinite recursion, but we still should get a second call
				dispatcher.dispatchEvent(new Event("event"));
			}
		});
		dispatcher.dispatchEvent(new Event("event"));
		Assert.equals(2, numCalls);
	}

	function test_dispatchingRemainsTrue() {
		var sequence = "";
		var dispatcher = new EventDispatcher();
		
		function test02b(e:Event) {
			sequence += "b";
		}
		
		function test02c(e:Event) {
			sequence += "c";
		}
		
		var test02aCallCount = 0;
		function test02a(e:Event) {
			sequence += "a";
			test02aCallCount++;
			if (test02aCallCount == 1) {
				sequence += "(";
				dispatcher.dispatchEvent(new Event("event"));
				sequence += ")";

				// dispatching should still be true here, so this shouldn't modify the list we're traversing over
				// ...but it does...
				dispatcher.removeEventListener("event", test02b);
				dispatcher.addEventListener("event", test02c, false, 4);
				dispatcher.addEventListener("event", test02b, false, 5);
			}
		}

		dispatcher.addEventListener("event", test02a, false, 3);
		dispatcher.addEventListener("event", test02b, false, 2);
		dispatcher.addEventListener("event", test02c, false, 1);
		dispatcher.dispatchEvent(new Event("event"));

		Assert.equals("a(abc)c", sequence);
	}
}
