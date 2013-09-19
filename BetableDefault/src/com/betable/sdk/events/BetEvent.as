package com.betable.sdk.events
{
	import flash.events.Event;
	
	public class BetEvent extends Event
	{
		public static const BET_CREATED:String = "betCreated";
		public static const UNBACKED_BET_CREATED:String = "unbackedBetCreated";
		public static const CREDIT_BET_CREATED:String = "creditBetCreated";
		public static const UNBACKED_CREDIT_BET_CREATED:String = "unbackedCreditBetCreated";
		public static const BET_ERROR:String = "betError";
		public static const UNBACKED_BET_ERROR:String = "unbackedBetError";
		public static const CREDIT_BET_ERROR:String = "creditBetError";
		public static const UNBACKED_CREDIT_BET_ERROR:String = "unbackedCreditBetError";
		
		private var _data:Object;
		
		public function BetEvent(type:String, data:Object)
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