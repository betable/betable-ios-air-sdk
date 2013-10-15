
package com.betable.sdk
{
	import com.betable.sdk.error.SDKError;
	import com.betable.sdk.events.AuthorizeEvent;
	import com.betable.sdk.events.BatchEvent;
	import com.betable.sdk.events.BetEvent;
	import com.betable.sdk.events.UserEvent;
	
	import flash.events.EventDispatcher;
	
	public class Betable extends EventDispatcher
	{
		
		private static var _instance:Betable;

		public static function get instance():Betable {
			if ( !_instance ) {
				_instance = new Betable( new SingletonEnforcer() );
				_instance.init();
			}
			
			return _instance;
		}
		
		//---------------------------------------
		// API Calls
		//---------------------------------------
		
		private function init():void {
		}
		
		public function authorize(clientID:String, clientSecret:String, redirectURI:String):void {
//			throw new SDKError("You can not authorize with ClientID and Secret on the web as it exposes the secret to the client", 500);
		}
		
		public function authroize(accessToken:String, swfID:String):void {
//			ExternalInterface.call("BetableAir.authorize", accessToken, swfID);
		}
		
		public function bet(gameID:String, data:Object):void {
//			ExternalInterface.call("BetableAir.instance.bet", gameID, data);
		}
		
		public function unbackedBet(gameID:String, data:Object):void {
//			ExternalInterface.call("BetableAir.instance.unbackedBet", gameID, data);
		}
		
		public function creditBet(gameID:String, creditGameID:String, data:Object):void {
//			ExternalInterface.call("BetableAir.instance.creditBet", gameID, creditGameID, data);
		}
		
		public function unbackedCreditBet(gameID:String, creditGameID:String, data:Object):void {
//			throw new SDKError("unbacked credit bets not supported yet");
		}
		
		public function wallet():void {
//			ExternalInterface.call("BetableAir.instance.wallet");
		}
		
		public function account():void {
//			ExternalInterface.call("BetableAir.instance.account");
		}
		
		public function createBatchRequest():String {
//			throw new SDKError("Batch Requests not supported yet");
			return "";
		}
		
		public function batchBet(batchID:String, gameID:String, data:Object):void {
//			ExternalInterface.call("BetableAir.instance.bet", gameID, data);
		}
		
		public function batchUnbackedBet(batchID:String, gameID:String, data:Object):void {
//			ExternalInterface.call("BetableAir.instance.bet", gameID, data);
		}
		
		public function batchCreditBet(batchID:String, gameID:String, creditGameID:String, data:Object):void {
//			ExternalInterface.call("BetableAir.instance.bet", gameID, data);
		}
		
		public function batchUnbackedCreditBet(batchID:String, gameID:String, creditGameID:String, data:Object):void {
//			ExternalInterface.call("BetableAir.instance.bet", gameID, data);
		}
		
		public function runBatch(batchID:String):void {
		}
		
		/**
		 * Cleans up the instance of the native extension. 
		 */		
		public function dispose():void { 
				
		}
		
		private function betableAirStatusUpdate( eventName:String, data:Object ):void {
			switch(eventName) {
				case "com.betable.authorize.finished":
					dispatchEvent( new AuthorizeEvent( AuthorizeEvent.AUTHORIZATION_FINISHED, data ) );
					break;
				case "com.betable.authorize.errored":
					dispatchEvent( new AuthorizeEvent( AuthorizeEvent.AUTHORIZATION_ERROR, data ) );
					break;
				case "com.betable.authorize.canceled":
					dispatchEvent( new AuthorizeEvent( AuthorizeEvent.AUTHORIZATION_CANCELED, null ) );
					break;
				case "com.betable.bet.created":
					dispatchEvent( new BetEvent( BetEvent.BET_CREATED, data ) );
					break;
				case "com.betable.bet.errored":
					dispatchEvent( new BetEvent( BetEvent.BET_ERROR, data ) );
					break;
				case "com.betable.credit_bet.created":
					dispatchEvent( new BetEvent( BetEvent.CREDIT_BET_CREATED, data ) );
					break;
				case "com.betable.credit_bet.errored":
					dispatchEvent( new BetEvent( BetEvent.CREDIT_BET_ERROR, data ) );
					break;
				case "com.betable.unbacked_bet.created":
					dispatchEvent( new BetEvent( BetEvent.UNBACKED_BET_CREATED, data ) );
					break;
				case "com.betable.unbacked_bet.errored":
					dispatchEvent( new BetEvent( BetEvent.UNBACKED_BET_ERROR, data ) );
					break;
				case "com.betable.unbacked_credit_bet.created":
					dispatchEvent( new BetEvent( BetEvent.UNBACKED_CREDIT_BET_CREATED, data ) );
					break;
				case "com.betable.unbacked_credit_bet.errored":
					dispatchEvent( new BetEvent( BetEvent.UNBACKED_CREDIT_BET_ERROR, data ) );
					break;
				case "com.betable.user.wallet":
					dispatchEvent( new UserEvent( UserEvent.WALLET, data ) );
					break;
				case "com.betable.user.wallet.errored":
					dispatchEvent( new UserEvent( UserEvent.WALLET_ERROR, data ) );
					break;
				case "com.betable.user.account":
					dispatchEvent( new UserEvent( UserEvent.ACCOUNT, data ) );
					break;
				case "com.betable.user.account.errored":
					dispatchEvent( new UserEvent( UserEvent.ACCOUNT_ERROR, data ) );
					break;
				case "com.betable.batch.complete":
					dispatchEvent( new BatchEvent( BatchEvent.BATCH_COMPLETED, data ) );
					break;
				case "com.betable.user.batch.errored":
					dispatchEvent( new BatchEvent( BatchEvent.BATCH_ERROR, data ) );
					break;
				default:
					break;
			}
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
			
			//ExternalInterface.addCallback("betableAirStatusUpdate", this.betableAirStatusUpdate);
		}
	}
}

class SingletonEnforcer {
	
}