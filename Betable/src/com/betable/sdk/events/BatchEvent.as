package com.betable.sdk.events
{
	import flash.events.Event;
	
	public class BatchEvent extends Event
	{
		private var _data:Object;
		public static const BATCH_COMPLETED:String = "batchCompleted";
		public static const BATCH_ERROR:String = "batchError";
		
		public function BatchEvent(type:String, data:Object)
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