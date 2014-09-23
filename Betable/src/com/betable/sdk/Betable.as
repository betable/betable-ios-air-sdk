
package com.betable.sdk
{
	import com.betable.sdk.error.SDKError;
	import com.betable.sdk.events.AuthorizeEvent;
	import com.betable.sdk.events.BatchEvent;
	import com.betable.sdk.events.BetEvent;
	import com.betable.sdk.events.UserEvent;
	import com.betable.sdk.events.WebviewEvent;
	
	import flash.desktop.NativeApplication;
	import flash.events.EventDispatcher;
	import flash.events.InvokeEvent;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	
	public class Betable extends EventDispatcher
	{
		
		private static var _instance:Betable;
		private var redirectURI:String;
		private var extContext:ExtensionContext;
		public static function setup(clientID:String, clientSecret:String, redirectURI:String):Betable {
			_instance = new Betable( new SingletonEnforcer() );
			_instance.init(clientID, clientSecret, redirectURI);
			return _instance;
		}
		public static function get instance():Betable {
			if ( !_instance ) {
				throw "You must call setup before you can reference the betable instance";
			}
			return _instance;
		}
		
		//---------------------------------------
		// API Calls
		//---------------------------------------
		
		private function init(clientID:String, clientSecret:String, redirectURI:String):void {
			this.redirectURI = redirectURI;
			extContext.call( "init" , clientID, clientSecret, redirectURI);
			var app:NativeApplication = NativeApplication.nativeApplication;
			app.addEventListener(InvokeEvent.INVOKE, onHandleURL);
		}
		
		public function authorize():void {
			extContext.call( "authorize" );
		}
		
		public function authorizeLogin():void {
			extContext.call( "authorizeLogin" );
		}
		
		public function unbackedAuthorize(clientUserID:String):void {
			extContext.call( "unbackedAuthorize" );
		}

		public function authorizeWithAccessToken(accessToken:String, swfID:String):void {
			throw new SDKError("You can not authorize with this method, It is only supported for the web.", 500);
		}
		
		public function isWeb():Boolean {
			return false;
		}
		
		public function onHandleURL(invokeEvent:InvokeEvent):void {
			var stringArgument:String = null;
			if (invokeEvent.arguments.length && invokeEvent.arguments[0] is String) {
				stringArgument = invokeEvent.arguments[0] as String;
			}
			if (stringArgument && !stringArgument.indexOf(redirectURI.toLowerCase())) {
				extContext.call( "handleOpenURL",  stringArgument );
			}
		}
		
		public function bet(gameID:String, data:Object, nonce:String=null):void {
			if (nonce) {
				extContext.call( "bet", gameID, JSON.stringify(data), nonce);
			} else {
				extContext.call( "bet", gameID, JSON.stringify(data));
			}
		}
		
		public function unbackedBet(gameID:String, data:Object, nonce:String=null):void {
			if (nonce) {
				extContext.call( "unbackedBet", gameID, JSON.stringify(data), nonce);
			} else {
				extContext.call( "unbackedBet", gameID, JSON.stringify(data));
			}
		}
		
		public function creditBet(gameID:String, creditGameID:String, data:Object, nonce:String=null):void {
			if (nonce) {
				extContext.call( "creditBet", gameID, creditGameID, JSON.stringify(data), nonce);
			} else {
				extContext.call( "creditBet", gameID, creditGameID, JSON.stringify(data));
			}
		}
		
		public function unbackedCreditBet(gameID:String, creditGameID:String, data:Object, nonce:String=null):void {
			if (nonce) {
				extContext.call( "unbackedCreditBet", gameID, creditGameID, JSON.stringify(data), nonce);
			} else {
				extContext.call( "unbackedCreditBet", gameID, creditGameID, JSON.stringify(data));
				
			}
		}
		
		public function showWallet(nonce:String=null):void {
			if (nonce) {
				extContext.call( "showWallet", nonce);
			} else {
				extContext.call( "showWallet");
			}
		}
		
		public function showDeposit(nonce:String=null):void {
			if (nonce) {
				extContext.call( "showDeposit", nonce);
			} else {
				extContext.call( "showDeposit");
			}
		}
		
		public function showWithdraw(nonce:String=null):void {
			if (nonce) {
				extContext.call( "showWithdraw", nonce);
			} else {
				extContext.call( "showWithdraw");
			}
		}
		
		public function showRedeem(url:String, nonce:String=null):void {
			if (nonce) {
				extContext.call( "showRedeem", url, nonce);
			} else {
				extContext.call( "showRedeem", url);
			}
		}
		
		public function showBetablePage(path:String, params:Object=null, nonce:String=null):void {
			if (!params) {
				params = {};
			}
			if (nonce) {
				extContext.call( "showBetablePage", path, JSON.stringify(params), nonce);
			} else {
				extContext.call( "showBetablePage", path, JSON.stringify(params));
		    }
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
		
		public function storeAccessToken(accessToken:String):void {
			extContext.call("storeAccessToken", accessToken);
		}
		
		public function getStoredAccessToken():String {
			return extContext.call("getStoredAccessToken") as String;
		}
		
		public function logout():void {
			extContext.call("logout");
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
					dispatchEvent( new AuthorizeEvent( AuthorizeEvent.AUTHORIZATION_FINISHED, JSON.parse(event.level)) );
					break;
				case "com.betable.authorize.errored":
					dispatchEvent( new AuthorizeEvent( AuthorizeEvent.AUTHORIZATION_ERROR, JSON.parse(event.level)) );
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
				case "com.betable.webview.closed":
					var level:String = event.level
					if (!level || !level.length) {
						level = "{}";
					}
					dispatchEvent( new WebviewEvent( WebviewEvent.CLOSE, JSON.parse(level)) );
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