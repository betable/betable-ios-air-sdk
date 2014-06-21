package com.betable.sdk.events
{
	import flash.events.Event;
	
	public class WebviewEvent extends Event
	{
		public static const CLOSE:String = "close";
		
		private var _data:Object;
		
		public function WebviewEvent(type:String, data:Object)
		{
			this._data = data;
			super(type, false, false);
		}
		
		public function get data():Object
		{
			return _data;
		}
	}
}

