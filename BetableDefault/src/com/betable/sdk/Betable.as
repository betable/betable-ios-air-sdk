
package com.betable.sdk
{
	
	import flash.events.EventDispatcher;
	
	public class Betable extends EventDispatcher
	{
		
		private static var _instance:Betable;

		public static function get instance():Betable {
			return null;
		}
		
		//---------------------------------------
		// API Calls
		//---------------------------------------
		
		private function init():void {
			
		}
		
		public function authorize(clientID:String, clientSecret:String, redirectURI:String, accessToken:String = null):void {
		}
		
		public function isWeb():Boolean {
			return true;
		}
		
		public function authorizeWithAccessToken(accessToken:String, swfID:String):void {
		}
		
		public function bet(gameID:String, data:Object, nonce:String=null):void {
		}
		
		public function unbackedBet(gameID:String, data:Object, nonce:String=null):void {
		}
		
		public function creditBet(gameID:String, creditGameID:String, data:Object, nonce:String=null):void {
		}
		
		public function unbackedCreditBet(gameID:String, creditGameID:String, data:Object, nonce:String=null):void {
		}
		
		public function wallet():void {
		}
		
		public function account():void {
		}
		
		public function createBatchRequest():String {
			return "";
		}
		
		public function batchBet(batchID:String, gameID:String, data:Object):void {
		}
		
		public function batchUnbackedBet(batchID:String, gameID:String, data:Object):void {
		}
		
		public function batchCreditBet(batchID:String, gameID:String, creditGameID:String, data:Object):void {
		}
		
		public function batchUnbackedCreditBet(batchID:String, gameID:String, creditGameID:String, data:Object):void {
		}
		
		public function runBatch(batchID:String):void {
		}		
		public function storeAccessToken(accessToken:String, accessTokenKey:String=null):void {
		}
		
		public function getStoredAccessToken(accessTokenKey:String = null):String {
			return "";
		}
		
		public function logout():void {
		}
		
		/**
		 * Cleans up the instance of the native extension. 
		 */		
		public function dispose():void { 
		}
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		
		/**
		 * Constructor. 
		 */		
		public function Betable( enforcer:SingletonEnforcer ) {
			super();
		}
	}
}

class SingletonEnforcer {
	
}