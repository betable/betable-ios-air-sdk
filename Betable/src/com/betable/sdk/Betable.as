
package com.betable.sdk
{
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.events.InvokeEvent;
	import flash.external.ExtensionContext;
	import flash.utils.Dictionary;
	import com.betable.sdk.events.BetEvent;
	import com.betable.sdk.events.AuthorizeEvent;
	import com.betable.sdk.events.BatchEvent;
	import com.betable.sdk.events.UserEvent;
	import flash.desktop.NativeApplication;
	
	public class Betable extends EventDispatcher
	{
		
		private static var _instance:Betable;
		private var redirectURI:String;
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
			extContext.call( "init" );
		}
		
		public function authorize(clientID:String, clientSecret:String, redirectURI:String):void {
			var app:NativeApplication = NativeApplication.nativeApplication;
			app.addEventListener(InvokeEvent.INVOKE, onHandleURL);
			this.redirectURI = redirectURI;
			extContext.call( "authorize", clientID, clientSecret, redirectURI );
		}
		
		public function onHandleURL(invokeEvent:InvokeEvent):void {
			trace("Invoked:", invokeEvent.arguments);
			var stringArgument:String = null;
			if (invokeEvent.arguments.length && invokeEvent.arguments[0] is String) {
				trace("...Casting!");
				stringArgument = invokeEvent.arguments[0] as String;
			}
			if (stringArgument && !stringArgument.indexOf(redirectURI.toLowerCase())) {
				trace("...Opening!");
				extContext.call( "handleOpenURL",  stringArgument );
			}
		}
		
		public function bet(gameID:String, data:Object, nonce:String=null):void {
			trace(JSON.stringify(data));
			extContext.call( "bet", gameID, JSON.stringify(data), nonce);
		}
		
		public function unbackedBet(gameID:String, data:Object, nonce:String=null):void {
			extContext.call( "unbackedBet", gameID, JSON.stringify(data), nonce);
		}
		
		public function creditBet(gameID:String, creditGameID:String, data:Object, nonce:String=null):void {
			extContext.call( "creditBet", gameID, creditGameID, JSON.stringify(data), nonce);
		}
		
		public function unbackedCreditBet(gameID:String, creditGameID:String, data:Object, nonce:String=null):void {
			extContext.call( "unbackedCreditBet", gameID, creditGameID, JSON.stringify(data), nonce);
		}
		
		public function wallet():void {
			extContext.call( "userWallet" );
		}
		
		public function account():void {
			extContext.call( "userAccount" );
		}
		
		public function createBatchRequest():String {
			return extContext.call( "createBatchRequest" ) as String;
		}
		
		public function batchBet(batchID:String, gameID:String, data:Object):void {
			extContext.call( "batchBet", batchID, gameID, JSON.stringify(data) );
		}
		
		public function batchUnbackedBet(batchID:String, gameID:String, data:Object):void {
			extContext.call( "batchUnbackedBet", batchID, gameID, JSON.stringify(data) );
		}
		
		public function batchCreditBet(batchID:String, gameID:String, creditGameID:String, data:Object):void {
			extContext.call( "batchCreditBet", gameID, batchID, creditGameID, JSON.stringify(data) );
		}
		
		public function batchUnbackedCreditBet(batchID:String, gameID:String, creditGameID:String, data:Object):void {
			extContext.call( "batchUnbackedCreditBet", batchID, gameID, creditGameID, JSON.stringify(data) );
		}
		
		public function runBatch(batchID:String):void {
			extContext.call( "runBatch", batchID );
		}
		
		//---------------------------------------
		// Internal calls
		//---------------------------------------
		
		public function dispose():void { 
			extContext.dispose(); 
		}
		
		//---------------------------------------
		// Events sent into air app
		//---------------------------------------
		
		private function onStatus( event:StatusEvent ):void {
			trace("BetableEvent: [" + event.code + "]", event.level);
			switch(event.code) {
				case "com.betable.authorize.finished":
					dispatchEvent( new AuthorizeEvent( AuthorizeEvent.AUTHORIZATION_FINISHED, JSON.parse(event.level) as Dictionary) );
					break;
				case "com.betable.authorize.errored":
					dispatchEvent( new AuthorizeEvent( AuthorizeEvent.AUTHORIZATION_ERROR, JSON.parse(event.level) as Dictionary) );
					break;
				case "com.betable.authorize.canceled":
					dispatchEvent( new AuthorizeEvent( AuthorizeEvent.AUTHORIZATION_CANCELED, null) );
					break;
				case "com.betable.bet.created":
					dispatchEvent( new BetEvent( BetEvent.BET_CREATED, JSON.parse(event.level)) );
					break;
				case "com.betable.bet.errored":
					dispatchEvent( new BetEvent( BetEvent.BET_ERROR, JSON.parse(event.level)) );
					break;
				case "com.betable.credit_bet.created":
					dispatchEvent( new BetEvent( BetEvent.CREDIT_BET_CREATED, JSON.parse(event.level)) );
					break;
				case "com.betable.credit_bet.errored":
					dispatchEvent( new BetEvent( BetEvent.CREDIT_BET_ERROR, JSON.parse(event.level)) );
					break;
				case "com.betable.unbacked_bet.created":
					dispatchEvent( new BetEvent( BetEvent.UNBACKED_BET_CREATED, JSON.parse(event.level)) );
					break;
				case "com.betable.unbacked_bet.errored":
					dispatchEvent( new BetEvent( BetEvent.UNBACKED_BET_ERROR, JSON.parse(event.level)) );
					break;
				case "com.betable.unbacked_credit_bet.created":
					dispatchEvent( new BetEvent( BetEvent.UNBACKED_CREDIT_BET_CREATED, JSON.parse(event.level)) );
					break;
				case "com.betable.unbacked_credit_bet.errored":
					dispatchEvent( new BetEvent( BetEvent.UNBACKED_CREDIT_BET_ERROR, JSON.parse(event.level)) );
					break;
				case "com.betable.user.wallet":
					dispatchEvent( new UserEvent( UserEvent.WALLET, JSON.parse(event.level)) );
					break;
				case "com.betable.user.wallet.errored":
					dispatchEvent( new UserEvent( UserEvent.WALLET_ERROR, JSON.parse(event.level)) );
					break;
				case "com.betable.user.account":
					dispatchEvent( new UserEvent( UserEvent.ACCOUNT, JSON.parse(event.level)) );
					break;
				case "com.betable.user.account.errored":
					dispatchEvent( new UserEvent( UserEvent.ACCOUNT_ERROR, JSON.parse(event.level)) );
					break;
				case "com.betable.batch.complete":
					dispatchEvent( new BatchEvent( BatchEvent.BATCH_COMPLETED, JSON.parse(event.level)) );
					break;
				case "com.betable.user.batch.errored":
					dispatchEvent( new BatchEvent( BatchEvent.BATCH_ERROR, JSON.parse(event.level)) );
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