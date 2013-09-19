package com.betable.sdk.events
{
	import flash.events.Event;
	
	public class UserEvent extends Event
	{
		public static const WALLET:String = "wallet";
		public static const WALLET_ERROR:String = "walletError";
		public static const ACCOUNT:String = "account";
		public static const ACCOUNT_ERROR:String = "accountError";
		
		private var _data:Object;
		
		public function UserEvent(type:String, data:Object)
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