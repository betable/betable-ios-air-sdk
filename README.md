# Betable Air SDK
A library that allows AIR apps that are built for iPhone to hook into the native iOS SDK. It uses an Air Native Extension (ANE) to handle the inter language communication.

## Installing the ANE
You can either directly download the ANE or you can download the projects and build it. Once you have the ANE you can right click on your project in FlashBuilder and go select `properties` from the menu. (1) When the dialog opens select `Flex Build Path` from the left panel. (2) In the right panel find the tab for `Native Extensions`. (3) on the right there will be 4 buttons, you should select `Add ANE`.

![ScreenShot]()

Finally in the left panel you need to select uncollapse `Flex Build Packaging` and select `Apple iOS`.  (2) In the right panel find the tab for `Native Extensions`. Betable.ane should be in the list with a green checkmark next to it. (3) Make sure to check the box under Package.

![ScreenShot]()

##Using the API
Simply import `com.betable.sdk.Betable` into your project, and you can access the Betable object through the instance property.

    var betable:Betable = Betable.instance;

Once you have an instance of the singleton, you can set up your event listeners and issue calls against it.

### Events
There are 4 events that you can listen for: Authorize Event, Batch Event, Bet Event, and User Event. **All of the events have a property called `data` that is an object that holds all of the info for the event.**

#### Authorize Event
Authorize events are sent during the authorization process and cover user canceling, completing or failing the authorization process.

**Types:**

`AuthorizationEvent.AUTHORIZATION_FINISHED`

This is called when the user finishes the authorization flow. It has a property called data that contains `{access_token: <THE USER'S ACCESS TOKEN>}`

`AuthorizationEvent.AUTHORIZATION_ERROR`

This is called when an error occurs during the authorization flow. The data property contains `code`, `domain`, and `user_info` which will contain information about why the authorization has failed.

`AuthorizationEvent.AUTHORIZATION_CANCELED`

This is called if the user aborts the authorization flow at any point. It does not have any data associated with it.

#### Bet Event
Bet events are sent after bets are made to confirm that they have been successfully completed. When you issue a bet you should wait for the event to return before updating the UI.

Every type of bet has 2 events associated with it. `CREATED` and `ERROR` The data associated with the `CREATED` events is the JSON decoded object of what the server returns from the API calls.  You can find documentation on that [here](https://developers.betable.com/docs/#post-gamesgameidbet). The data associated with the `ERROR` events is a object contain `code`, `domain`, and `user_info`, which describe what the nature of the error is.

**Types:**

`BetEvent.BET_CREATED`

`BetEvent.BET_ERROR`

`BetEvent.CREDIT_BET_CREATED`

`BetEvent.CREDIT_BET_ERROR`

`BetEvent.UNBACKED_BET_CREATED`

`BetEvent.UNBACKED_BET_ERROR`

`BetEvent.UNBACKED_CREDIT_BET_CREATED`

`BetEvent.UNBACKED_CREDIT_BET_ERROR`

#### Batch Event

Batch events are used to communicate the status of a batch request. If a Batch successfully runs it will fire a `BetEvent.BATCH_COMPLETED` with a data property that represents a JSON decoded object of server response from the batch request.  Documentation on this JSON can be found [here](https://developers.betable.com/docs/#batch-requests).  If there is an error then you will receive a `BetEvent.BATCH_ERROR` with a data object containing `code`, `domain`, and `user_info`, which describe what the nature of the error is.

**Types:**

`BetEvent.BATCH_COMPLETED`

`BetEvent.BATCH_ERROR`
