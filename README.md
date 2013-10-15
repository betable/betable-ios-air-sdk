# Betable Air SDK
A library that allows AIR apps that are built for iPhone to hook into the native iOS SDK. It uses an Air Native Extension (ANE) to handle the inter language communication.

## Installing the ANE
You can either directly download the [Betable ANE](https://github.com/betable/betable-ios-air-sdk/raw/master/Betable/bin/build/Betable.ane) or you can download the projects and build it. Once you have the ANE you can right click on your project in FlashBuilder and go select `properties` from the menu. (1) When the dialog opens select `Flex Build Path` from the left panel. (2) In the right panel find the tab for `Native Extensions`. (3) on the right there will be 4 buttons, you should select `Add ANE`.

![ScreenShot](https://raw.github.com/betable/betable-ios-air-sdk/master/Images/buildpath.png)

Finally in the left panel you need to select uncollapse `Flex Build Packaging` and select `Apple iOS`.  (2) In the right panel find the tab for `Native Extensions`. Betable.ane should be in the list with a green checkmark next to it. (3) Make sure to check the box under Package.

![ScreenShot](https://raw.github.com/betable/betable-ios-air-sdk/master/Images/packaging.png)

##Using the API

Simply import `com.betable.sdk.Betable` into your project, and you can access the Betable object through the instance property.

    var betable:Betable = Betable.instance;

Once you have an instance of the singleton, you can set up your event listeners and issue calls against it.

###API Calls

####Authorizing

When you have an instance of the Betable object authorization is pretty simple.  You simple call `betable.authorize(<Client ID>, <Client Secret>, <Redirect URI>)`.  This will hit the iOS SDK and complete an in app authorization flow. When the authorization finishes, whether it was successful or not, the Betable instance will dispatch an Authorization Event. (See [Authorize Event](#authorize-event) for more info)

#####Storing Credentials

You can store and retrieve the access token from the secure keychain by using these two calls `betable.storeAccessToken(<Access Token>)` and `betable.getStoredAccessToken()` respectively. If there is an access token available, you can pass it into `betable.authorize` as the fourth argument. This will cause the `AuthorizationEvent.AUTHORIZATION_FINISHED` to fire immediately.

####<a id="making-bets"></a>Making Bets

There are four kinds of bets you can make: a regular bet, an unbacked bet, a credit bet, and an unbacked credit bet.  Each one takes a data object which will be encoded as JSON and sent straight to the API (See more [here](https://developers.betable.com/docs/#post-gamesgameidbet)), and Each one has a corresponding set of [BetEvent](#bet-event) types: one for success and the other for failure.

#####Bet Nonce:

To track bets throughout the entire system, since there is a disconnect between placing the bet through the API and listening for the bet complete or failure event on the `Betable` object, each bet takes an optional `Bet Nonce` string. You can use this string to uniquely identify bets through the whole system. It will be returned in the `data` object with the key `nonce` on the `BetEvent.*_CREATED` or `BetEvent.*_ERROR` events.

#####Bet API Calls:

`betable.bet(<Game ID>, <Data>[, <Bet Nonce>])`:

This will issue a real bet to the game that matches `Game ID`.

`betable.unbacked_bet(<Game ID>, <Data>[, <Bet Nonce>])`:

This will issue an unbacked bet to the game that matches `Game ID`. An unbacked bet is one that uses the correct math model but doesn't actually pay out the customer.  It can be used for simulated bets, or demo bets.

`betable.credit_bet(<Game ID>, <Credit Game ID>, <Data>[, <Bet Nonce>])`:

Often games will win you the ability to play a bonus game or a mini-game.  These are known as credits. If you have enough credits to play a game you can make a credit bet, which will issue a bet to another game, but use credits instead of money. This other game is known as the credit game.  To make a bet to a credit game use the above call with `Game ID` being the game the user is authorized to play and `Credit Game ID` being the credit game that the user is trying to play.

`betable.unbacked_credit_bet(<Game ID>, <Credit Game ID>,  <Data>[, <Bet Nonce>])`:

This call is similar to a credit bet, but like its regular bet counter part, it only uses the math model, and doesn't do any accounting.

#### Batching Bets

If you need to make a series of calls to the Betable API sometimes it makes more sense to make them as one batch instead of sending each synchronously.  You can see more info on how batching bets works [here](https://developers.betable.com/docs/#batch-requests).

To create a bet you simply call `betable.createBatchRequest()`. This will return a String with the ID of the batch. You will use this to make all of your subsequent calls.

To make bets to the batch you use the following calls:

		public function batchBet(batchID:String, gameID:String, data:Object):void;
		public function batchUnbackedBet(batchID:String, gameID:String, data:Object):void;
		public function batchCreditBet(batchID:String, gameID:String, creditGameID:String, data:Object):void;
		public function batchUnbackedCreditBet(batchID:String, gameID:String, creditGameID:String, data:Object):void;

They are identical to the calls in [Making Bets](#making-bets) except that they each pass in the batchID first.

When you are done adding bets to the batch you can execute it like so:

	betable.run_batch(<Batch ID>);

This will fire the batch request. When the batch is done running it will fire one of two BatchEvents.  Either `BatchEvent.BATCH_COMPLETED` if it was successfully completed or `BatchEvent.BATCH_ERROR` if there was an error.  See [Batch Event](#batch-event) for more info.

### Events

There are 4 events that you can listen for: Authorize Event, Batch Event, Bet Event, and User Event. **All of the events have a property called `data` that is an object that holds all of the info for the event.**

#### <a id="authorize-event"></a>Authorize Event

Authorize events are sent during the authorization process and cover user canceling, completing or failing the authorization process.

**Types:**

`AuthorizationEvent.AUTHORIZATION_FINISHED`

This is called when the user finishes the authorization flow. It has a property called data that contains `{access_token: <THE USER'S ACCESS TOKEN>}`

`AuthorizationEvent.AUTHORIZATION_ERROR`

This is called when an error occurs during the authorization flow. The data property contains `code`, `domain`, and `user_info` which will contain information about why the authorization has failed.

`AuthorizationEvent.AUTHORIZATION_CANCELED`

This is called if the user aborts the authorization flow at any point. It does not have any data associated with it.

#### <a id="bet-event"></a>Bet Event

Bet events are sent after bets are made to confirm that they have been successfully completed. When you issue a bet you should wait for the event to return before updating the UI.

Every type of bet has 2 events associated with it. `CREATED` and `ERROR` The data associated with the `CREATED` events is the JSON decoded object of what the server returns from the API calls with the addition of a key `nonce` if you passed in an optional bet nonce when you created the bet.  You can find documentation on what the API returns [here](https://developers.betable.com/docs/#post-gamesgameidbet). The data associated with the `ERROR` events is a object contain `code`, `domain`, and `user_info`, which describe what the nature of the error is.

**Types:**

`BetEvent.BET_CREATED`

`BetEvent.BET_ERROR`

`BetEvent.CREDIT_BET_CREATED`

`BetEvent.CREDIT_BET_ERROR`

`BetEvent.UNBACKED_BET_CREATED`

`BetEvent.UNBACKED_BET_ERROR`

`BetEvent.UNBACKED_CREDIT_BET_CREATED`

`BetEvent.UNBACKED_CREDIT_BET_ERROR`

#### <a id="batch-event"></a>Batch Event

Batch events are used to communicate the status of a batch request. If a Batch successfully runs it will fire a `BetEvent.BATCH_COMPLETED` with a data property that represents a JSON decoded object of server response from the batch request.  Documentation on this JSON can be found [here](https://developers.betable.com/docs/#batch-requests).  If there is an error then you will receive a `BetEvent.BATCH_ERROR` with a data object containing `code`, `domain`, and `user_info`, which describe what the nature of the error is.

**Types:**

`BetEvent.BATCH_COMPLETED`

`BetEvent.BATCH_ERROR`

### Examples

There is a flash project that has an example of all of these calls with the project [here](https://github.com/betable/betable-ios-air-sdk/tree/master/BetableTestApp).
