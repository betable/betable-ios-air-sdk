package com.betable.sdk.events
{
	import flash.events.Event;
	
	public class AuthorizeEvent extends Event
	{
		
		public static const AUTHORIZATION_FINISHED:String = "authorizationFinished";
		public static const AUTHORIZATION_ERROR:String = "authorizationFailed";
		public static const AUTHORIZATION_CANCELED:String = "authorizationCanceled";
		private var _data:Object;
		
		public function AuthorizeEvent(type:String, data:Object) {
			this._data = data;
			super(type, false, false);
		}

		public function get data():Object
		{
			return _data;
		}

	}
}