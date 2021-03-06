// StarlingEx - https://github.com/BladePoint/StarlingEx
// Copyright Doublehead Games, LLC. All rights reserved.
// This code is open source under the MIT License - https://github.com/BladePoint/StarlingEx/blob/master/docs/LICENSE
// Use in conjunction with Starling - https://gamua.com/starling/

package starlingEx.animation {

	import starling.animation.Tween;
	import starlingEx.animation.TweenObject;
	import starlingEx.utils.PoolEx;

	/* A Tween extension that allows pooling and easy tweening of numbers without having to create an object. */
	public class TweenEx extends Tween {
		static private const instancePool:Vector.<TweenEx> = new <TweenEx>[];
		static public function getInstance(target:Object,time:Number,transition:Object="linear"):TweenEx {
			if (instancePool.length == 0) return new TweenEx(target,time,transition);
			else {
				var tween:TweenEx = instancePool.pop();
				tween.reset(target,time,transition);
				return tween;
			}
		}
		static public function putInstance(tween:TweenEx):void {
			if (tween) {
				PoolEx.putArray(tween.onStartArgs);
				PoolEx.putArray(tween.onUpdateArgs);
				PoolEx.putArray(tween.onRepeatArgs);
				PoolEx.putArray(tween.onCompleteArgs);
				tween.reset(null,0);
				instancePool[instancePool.length] = tween;
			}
		}
		
		private var tweenObject:TweenObject;
		public function TweenEx(target:Object,time:Number,transition:Object="linear") {
			var superTarget:Object;
			if (target is Number) superTarget = tweenObject = TweenObject.getInstance(target as Number);
			else superTarget = target;
			super(superTarget,time,transition);
		}
		public function animateEx(endValue:Number):void {
			if (tweenObject) animate("t",endValue);
			else throw new Error("TweenObject does not exist.");
		}
		public function get t():Number{
			if (tweenObject) return tweenObject.t;
			else return NaN;
		}
		public function set t(value:Number):void {
			if (tweenObject) tweenObject.t = t;
		}
		override public function reset(target:Object,time:Number,transition:Object="linear"):Tween {
			if (target is Number) {
				if (tweenObject) tweenObject.t = target as Number;
				else tweenObject = TweenObject.getInstance(target as Number);
				super.reset(tweenObject,time,transition);
			} else if (target is TweenObject) {
				if (tweenObject != target) disposeTweenObject();
				super.reset(target,time,transition);
			} else {
				disposeTweenObject();
				super.reset(target,time,transition);
			}
			removeEventListeners();
			return this;
		}
		private function disposeTweenObject():void {
			if (tweenObject) {
				TweenObject.putInstance(tweenObject);
				tweenObject = null;
			}
		}
		public function dispose():void {
			reset(null,0);
		}
	}

}
