
package com.betable.sdk
{
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import com.betable.sdk.events.BetEvent;
	import com.betable.sdk.events.AuthorizeEvent;
	import com.betable.sdk.events.BatchEvent;
	import com.betable.sdk.events.UserEvent;
	
	public class Betable extends EventDispatcher
	{
		
		private static var _instance:Betable;
		private var extContext:ExtensionContext;

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
		}
		
		public function bet(gameID:String, data:Object):void {
		}
		
		public function unbackedBet(gameID:String, data:Object):void {
		}
		
		public function creditBet(gameID:String, creditGameID:String, data:Object):void {
		}
		
		public function unbackedCreditBet(gameID:String, creditGameID:String, data:Object):void {
		}
		
		public function wallet():void {
		}
		
		public function account():void {
		}
		
		public function createBatchRequest():String {
			return ""
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
		
		/**
		 * Cleans up the instance of the native extension. 
		 */		
		public function dispose():void { 
			extContext.dispose(); 
		}
		
		private function onStatus( event:StatusEvent ):void {
			switch(event.code) {
				case "com.betable.authorize.finished":
					dispatchEvent( new AuthorizeEvent( AuthorizeEvent.AUTHORIZATION_FINISHED, JSON.parse(event.level) as Object) );
					break;
				case "com.betable.authorize.errored":
					dispatchEvent( new AuthorizeEvent( AuthorizeEvent.AUTHORIZATION_ERROR, JSON.parse(event.level) as Object) );
					break;
				case "com.betable.authorize.canceled":
					dispatchEvent( new AuthorizeEvent( AuthorizeEvent.AUTHORIZATION_CANCELED, null ) );
					break;
				case "com.betable.bet.created":
					dispatchEvent( new BetEvent( BetEvent.BET_CREATED, JSON.parse(event.level) as Object) );
					break;
				case "com.betable.bet.errored":
					dispatchEvent( new BetEvent( BetEvent.BET_ERROR, JSON.parse(event.level) as Object) );
					break;
				case "com.betable.credit_bet.created":
					dispatchEvent( new BetEvent( BetEvent.CREDIT_BET_CREATED, JSON.parse(event.level) as Object) );
					break;
				case "com.betable.credit_bet.errored":
					dispatchEvent( new BetEvent( BetEvent.CREDIT_BET_ERROR, JSON.parse(event.level) as Object) );
					break;
				case "com.betable.unbacked_bet.created":
					dispatchEvent( new BetEvent( BetEvent.UNBACKED_BET_CREATED, JSON.parse(event.level) as Object) );
					break;
				case "com.betable.unbacked_bet.errored":
					dispatchEvent( new BetEvent( BetEvent.UNBACKED_BET_ERROR, JSON.parse(event.level) as Object) );
					break;
				case "com.betable.unbacked_credit_bet.created":
					dispatchEvent( new BetEvent( BetEvent.UNBACKED_CREDIT_BET_CREATED, JSON.parse(event.level) as Object) );
					break;
				case "com.betable.unbacked_credit_bet.errored":
					dispatchEvent( new BetEvent( BetEvent.UNBACKED_CREDIT_BET_ERROR, JSON.parse(event.level) as Object) );
					break;
				case "com.betable.user.wallet":
					dispatchEvent( new UserEvent( UserEvent.WALLET, JSON.parse(event.level) as Object) );
					break;
				case "com.betable.user.wallet.errored":
					dispatchEvent( new UserEvent( UserEvent.WALLET_ERROR, JSON.parse(event.level) as Object) );
					break;
				case "com.betable.user.account":
					dispatchEvent( new UserEvent( UserEvent.ACCOUNT, JSON.parse(event.level) as Object) );
					break;
				case "com.betable.user.account.errored":
					dispatchEvent( new UserEvent( UserEvent.ACCOUNT_ERROR, JSON.parse(event.level) as Object) );
					break;
				case "com.betable.batch.complete":
					dispatchEvent( new BatchEvent( BatchEvent.BATCH_COMPLETED, JSON.parse(event.level) as Object) );
					break;
				case "com.betable.user.batch.errored":
					dispatchEvent( new BatchEvent( BatchEvent.BATCH_ERROR, JSON.parse(event.level) as Object) );
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
			
			extContext = ExtensionContext.createExtensionContext( "com.betable.sdk", "" );
			
			if ( !extContext ) {
				throw new Error( "SDK not supported" );
			}
			
			extContext.addEventListener( StatusEvent.STATUS, onStatus );
		}
	}
}

class SingletonEnforcer {
	
}