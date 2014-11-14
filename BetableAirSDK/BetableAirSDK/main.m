//
//  BetableAirSDK.m
//  BetableAirSDK
//
//  Created by Tony hauber on 9/9/13.
//  Copyright (c) 2013 Betable. All rights reserved.
//

#import "FlashRuntimeExtensions.h"
#import <Betable/Betable.h>
#import "NSDictionary+BetableAir.h"
#import "NSString+BetableAir.h"

#define SERVICE_KEY @"com.betable.SDK"
#define USERNAME_KEY @"com.betable.AccessToken"

Betable *betable;
NSMutableDictionary *batchRequests;
static int batchRequestCount;

#pragma mark - Utils

NSString *getStringFromArgs(FREObject argv[], NSInteger index) {
    uint32_t stringLength;
    const uint8_t *stringValue;
    FREGetObjectAsUTF8(argv[index], &stringLength, &stringValue);
    NSString *stringObj = [NSString stringWithUTF8String:(char*)stringValue];
    return stringObj;
}

const uint8_t* getUTF8String(NSString* string) {
    return (uint8_t*)[string UTF8String];
}

NSDictionary *betDataWithNonce(NSDictionary* data, NSString* nonce) {
    if (nonce) {
        NSMutableDictionary *mutData = [data mutableCopy];
        [mutData setValue:nonce forKey:@"nonce"];
        return [NSDictionary dictionaryWithDictionary:mutData];
    }
    return data;
}

void* authorizeWithLoginOption(BOOL loginOption, FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    UIViewController *rootVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    BetableAccessTokenHandler onFinish = ^(NSString *accessToken) {
        NSDictionary *data = @{@"access_token": accessToken};
        NSString *jsonString = [[NSString alloc] initWithData:[data JSONData]
                                                     encoding:NSUTF8StringEncoding];
        FREDispatchStatusEventAsync(ctx, (uint8_t*) "com.betable.authorize.finished", getUTF8String(jsonString));
    };
    BetableFailureHandler onFaiure = ^(NSURLResponse *response, NSString *responseBody, NSError *error) {
        NSDictionary *data = @{
                               @"code": @([error code]),
                               @"domain": [error domain],
                               @"user_info": [error userInfo]
                               };
        NSString *jsonString = [[NSString alloc] initWithData:[data JSONData]
                                                     encoding:NSUTF8StringEncoding];
        FREDispatchStatusEventAsync(ctx, (uint8_t*) "com.betable.authorize.errored", getUTF8String(jsonString));
        
    };
    BetableCancelHandler onCancel = ^{
        FREDispatchStatusEventAsync(ctx, (uint8_t*) "com.betable.authorize.canceled", (uint8_t*)"");
    };
    
    if (loginOption) {
        [betable authorizeLoginInViewController:rootVC onAuthorizationComplete:onFinish onFailure:onFaiure onCancel:onCancel];
    } else {
        [betable authorizeInViewController:rootVC onAuthorizationComplete:onFinish onFailure:onFaiure onCancel:onCancel];
    }
    return nil;
}

#pragma mark - Extension Calls

FREObject init(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]){
    NSString *clientID = getStringFromArgs(argv, 0);
    NSString *clientSecret = getStringFromArgs(argv, 1);
    NSString *redirectURI = getStringFromArgs(argv, 2);
    
    betable = [[Betable alloc] initWithClientID:clientID clientSecret:clientSecret redirectURI:redirectURI];
    [betable launchWithOptions:@{}];
    return nil;
}

FREObject authorize(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    authorizeWithLoginOption(NO, ctx, funcData, argc, argv);
    return nil;
}

FREObject authorizeLogin(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    authorizeWithLoginOption(YES, ctx, funcData, argc, argv);
    return nil;
}

FREObject unbackedAuthorize(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    NSString *userClientID = getStringFromArgs(argv, 0);
    [betable unbackedToken:userClientID onComplete:^(NSString *accessToken) {
        NSDictionary *data = @{@"access_token": accessToken, @"unbacked": [NSNumber numberWithBool:YES]};
        NSString *jsonString = [[NSString alloc] initWithData:[data JSONData]
                                                     encoding:NSUTF8StringEncoding];
        FREDispatchStatusEventAsync(ctx, (uint8_t*) "com.betable.authorize.finished", getUTF8String(jsonString));
    } onFailure:^(NSURLResponse *response, NSString *responseBody, NSError *error) {
        NSDictionary *data = @{
                               @"code": @([error code]),
                               @"domain": [error domain],
                               @"user_info": [error userInfo]
                               };
        NSString *jsonString = [[NSString alloc] initWithData:[data JSONData]
                                                     encoding:NSUTF8StringEncoding];
        FREDispatchStatusEventAsync(ctx, (uint8_t*) "com.betable.authorize.errored", getUTF8String(jsonString));
    }];
    return nil;
}

FREObject handleOpenURL(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]){
    NSString *openURL = getStringFromArgs(argv, 0);
    [betable handleAuthorizeURL:[NSURL URLWithString:openURL]];
    return nil;
}

FREObject bet(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]){
    
    NSString *gameID = getStringFromArgs(argv, 0);
    NSString *jsonData = getStringFromArgs(argv, 1);
    NSString *nonce = argc > 2 ? getStringFromArgs(argv, 2) : nil;
    NSDictionary *data = (NSDictionary*)[jsonData objectFromJSONString];
    
    [betable betForGame:gameID withData:data onComplete:^(NSDictionary *data) {
        NSString *jsonString = [[NSString alloc] initWithData:[betDataWithNonce(data,nonce) JSONData]
                                                     encoding:NSUTF8StringEncoding];
        FREDispatchStatusEventAsync(ctx, (uint8_t*) "com.betable.bet.created", getUTF8String(jsonString));
    } onFailure:^(NSURLResponse *response, NSString *responseBody, NSError *error) {
        NSDictionary *data = @{
                               @"code": @([error code]),
                               @"domain": [error domain],
                               @"user_info": [error userInfo]
                               };
        NSString *jsonString = [[NSString alloc] initWithData:[betDataWithNonce(data,nonce) JSONData]
                                                     encoding:NSUTF8StringEncoding];
        FREDispatchStatusEventAsync(ctx, (uint8_t*) "com.betable.bet.errored", getUTF8String(jsonString));
    }];
    
    return nil;
}

FREObject creditBet(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]){
    
    NSString *gameID = getStringFromArgs(argv, 0);
    NSString *creditGameID = getStringFromArgs(argv, 1);
    NSString *jsonData = getStringFromArgs(argv, 2);
    NSString *nonce = argc > 3 ? getStringFromArgs(argv, 3) : nil;
    NSDictionary *data = (NSDictionary*)[jsonData objectFromJSONString];
    
    [betable creditBetForGame:gameID creditGame:creditGameID withData:data onComplete:^(NSDictionary *data) {
        NSString *jsonString = [[NSString alloc] initWithData:[betDataWithNonce(data,nonce) JSONData]
                                                     encoding:NSUTF8StringEncoding];
        FREDispatchStatusEventAsync(ctx, (uint8_t*) "com.betable.credit_bet.created", getUTF8String(jsonString));
    } onFailure:^(NSURLResponse *response, NSString *responseBody, NSError *error) {
        NSDictionary *data = @{
                               @"code": @([error code]),
                               @"domain": [error domain],
                               @"user_info": [error userInfo]
                               };
        NSString *jsonString = [[NSString alloc] initWithData:[betDataWithNonce(data,nonce) JSONData]
                                                     encoding:NSUTF8StringEncoding];
        FREDispatchStatusEventAsync(ctx, (uint8_t*) "com.betable.credit_bet.errored", getUTF8String(jsonString));
    }];
    
    return nil;
}

FREObject unbackedBet(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]){
    
    NSString *gameID = getStringFromArgs(argv, 0);
    NSString *jsonData = getStringFromArgs(argv, 1);
    NSString *nonce = argc > 2 ? getStringFromArgs(argv, 2) : nil;
    NSDictionary *data = (NSDictionary*)[jsonData objectFromJSONString];
    
    [betable unbackedBetForGame:gameID withData:data onComplete:^(NSDictionary *data) {
        NSString *jsonString = [[NSString alloc] initWithData:[betDataWithNonce(data,nonce) JSONData]
                                                     encoding:NSUTF8StringEncoding];
        FREDispatchStatusEventAsync(ctx, (uint8_t*) "com.betable.unbacked_bet.created", getUTF8String(jsonString));
    } onFailure:^(NSURLResponse *response, NSString *responseBody, NSError *error) {
        NSDictionary *data = @{
                               @"code": @([error code]),
                               @"domain": [error domain],
                               @"user_info": [error userInfo]
                               };
        NSString *jsonString = [[NSString alloc] initWithData:[betDataWithNonce(data,nonce) JSONData]
                                                     encoding:NSUTF8StringEncoding];
        FREDispatchStatusEventAsync(ctx, (uint8_t*) "com.betable.bet.errored", getUTF8String(jsonString));
    }];
    
    return nil;
}

FREObject unbackedCreditBet(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]){
    
    NSString *gameID = getStringFromArgs(argv, 0);
    NSString *creditGameID = getStringFromArgs(argv, 1);
    NSString *jsonData = getStringFromArgs(argv, 2);
    NSString *nonce = argc > 3 ? getStringFromArgs(argv, 3) : nil;
    NSDictionary *data = (NSDictionary*)[jsonData objectFromJSONString];
    
    [betable unbackedCreditBetForGame:gameID creditGame:creditGameID withData:data onComplete:^(NSDictionary *data) {
        NSString *jsonString = [[NSString alloc] initWithData:[betDataWithNonce(data,nonce) JSONData]
                                                     encoding:NSUTF8StringEncoding];
        FREDispatchStatusEventAsync(ctx, (uint8_t*) "com.betable.unbacked_credit_bet.created", getUTF8String(jsonString));
    } onFailure:^(NSURLResponse *response, NSString *responseBody, NSError *error) {
        NSDictionary *data = @{
                               @"code": @([error code]),
                               @"domain": [error domain],
                               @"user_info": [error userInfo]
                               };
        NSString *jsonString = [[NSString alloc] initWithData:[betDataWithNonce(data,nonce) JSONData]
                                                     encoding:NSUTF8StringEncoding];
        FREDispatchStatusEventAsync(ctx, (uint8_t*) "com.betable.bet.errored", getUTF8String(jsonString));
    }];
    
    return nil;
}

FREObject userWallet(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]){
    [betable userWalletOnComplete:^(NSDictionary *data) {
        NSString *jsonString = [[NSString alloc] initWithData:[data JSONData]
                                                     encoding:NSUTF8StringEncoding];
        FREDispatchStatusEventAsync(ctx, getUTF8String(@"com.betable.user.wallet"), getUTF8String(jsonString));
    } onFailure:^(NSURLResponse *response, NSString *responseBody, NSError *error) {
        NSDictionary *data = @{
                               @"code": @([error code]),
                               @"domain": [error domain],
                               @"user_info": [error userInfo]
                               };
        NSString *jsonString = [[NSString alloc] initWithData:[data JSONData]
                                                     encoding:NSUTF8StringEncoding];
        FREDispatchStatusEventAsync(ctx, (uint8_t*) "com.betable.user.wallet.errored", getUTF8String(jsonString));
    }];
    
    return nil;
}

FREObject userAccount(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]){
    [betable userAccountOnComplete:^(NSDictionary *data) {
        NSString *jsonString = [[NSString alloc] initWithData:[data JSONData]
                                                     encoding:NSUTF8StringEncoding];
        FREDispatchStatusEventAsync(ctx, (uint8_t*) "com.betable.user.account", getUTF8String(jsonString));
    } onFailure:^(NSURLResponse *response, NSString *responseBody, NSError *error) {
        NSDictionary *data = @{
                               @"code": @([error code]),
                               @"domain": [error domain],
                               @"user_info": [error userInfo]
                               };
        NSString *jsonString = [[NSString alloc] initWithData:[data JSONData]
                                                     encoding:NSUTF8StringEncoding];
        FREDispatchStatusEventAsync(ctx, (uint8_t*) "com.betable.user.account.errored", getUTF8String(jsonString));
    }];
    
    return nil;
}

FREObject createBatchRequest(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]){
    static dispatch_once_t once;
    dispatch_once(&once, ^ {
        batchRequests = [NSMutableDictionary dictionary];
        batchRequestCount = 0;
    });
    NSString *batchID = [NSString stringWithFormat:@"%d", batchRequestCount];
    batchRequests[batchID] = [[BetableBatchRequest alloc] initWithBetable:betable];
    FREObject object;
    FRENewObjectFromUTF8([[NSNumber numberWithInteger:[batchID length]] intValue], getUTF8String(batchID), &object);
    return object;
}

FREObject batchBet(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]){
    NSString *batchID = getStringFromArgs(argv, 0);
    NSString *gameID = getStringFromArgs(argv, 1);
    NSString *jsonString = getStringFromArgs(argv, 2);
    NSDictionary *data = (NSDictionary*)[jsonString objectFromJSONString];
    NSString *name = nil;
    if (argc > 3) {
        name = getStringFromArgs(argv, 3);
    }
    BetableBatchRequest *batchRequest = batchRequests[batchID];
    
    [batchRequest betForGame:gameID withData:data withName:nil];
    
    return nil;
}

FREObject batchCreditBet(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]){
    NSString *batchID = getStringFromArgs(argv, 0);
    NSString *gameID = getStringFromArgs(argv, 1);
    NSString *creditGameID = getStringFromArgs(argv, 2);
    NSString *jsonString = getStringFromArgs(argv, 3);
    NSDictionary *data = (NSDictionary*)[jsonString objectFromJSONString];
    NSString *name = nil;
    if (argc > 4) {
        name = getStringFromArgs(argv, 3);
    }
    BetableBatchRequest *batchRequest = batchRequests[batchID];
    
    [batchRequest creditBetForGame:gameID creditGame:creditGameID withData:data withName:nil];
    
    return nil;
}

FREObject batchUnbackedBet(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]){
    NSString *batchID = getStringFromArgs(argv, 0);
    NSString *gameID = getStringFromArgs(argv, 1);
    NSString *jsonString = getStringFromArgs(argv, 2);
    NSDictionary *data = (NSDictionary*)[jsonString objectFromJSONString];
    NSString *name = nil;
    if (argc > 3) {
        name = getStringFromArgs(argv, 3);
    }
    BetableBatchRequest *batchRequest = batchRequests[batchID];
    
    [batchRequest unbackedBetForGame:gameID withData:data withName:nil];
    
    return nil;
}

FREObject batchUnbackedCreditBet(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]){
    NSString *batchID = getStringFromArgs(argv, 0);
    NSString *gameID = getStringFromArgs(argv, 1);
    NSString *creditGameID = getStringFromArgs(argv, 2);
    NSString *jsonString = getStringFromArgs(argv, 3);
    NSDictionary *data = (NSDictionary*)[jsonString objectFromJSONString];
    NSString *name = nil;
    if (argc > 4) {
        name = getStringFromArgs(argv, 3);
    }
    BetableBatchRequest *batchRequest = batchRequests[batchID];
    
    [batchRequest unbackedCreditBetForGame:gameID creditGame:creditGameID withData:data withName:nil];
    
    return nil;
}

FREObject runBatch(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]){
    NSString *batchID = getStringFromArgs(argv, 0);
    BetableBatchRequest *batchRequest = batchRequests[batchID];
    [batchRequest runBatchOnComplete:^(NSDictionary *data) {
        NSMutableDictionary *mutData = [data mutableCopy];
        mutData[@"batch_id"] = batchID;
        NSString *jsonString = [[NSString alloc] initWithData:[mutData JSONData]
                                                     encoding:NSUTF8StringEncoding];
        FREDispatchStatusEventAsync(ctx, (uint8_t*) "com.betable.batch.complete", getUTF8String(jsonString));
    } onFailure:^(NSURLResponse *response, NSString *responseBody, NSError *error) {
        NSDictionary *data = @{
                               @"code": @([error code]),
                               @"domain": [error domain],
                               @"user_info": [error userInfo],
                               @"batch_id": batchID
                               };
        NSString *jsonString = [[NSString alloc] initWithData:[data JSONData]
                                                     encoding:NSUTF8StringEncoding];
        FREDispatchStatusEventAsync(ctx, (uint8_t*) "com.betable.user.batch.errored", getUTF8String(jsonString));
    }];
    return nil;
}

FREObject logout(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]){
    [betable logout];
    return nil;
}

FREObject storeAccessToken(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]){
    [betable storeAccessToken];
    return nil;
}

FREObject getStoredAccessToken(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]){
    if ([betable loadStoredAccessToken]) {
        FREObject object;
        FRENewObjectFromUTF8([[NSNumber numberWithInteger:betable.accessToken.length] intValue], getUTF8String(betable.accessToken), &object);
        return object;
    }
    return nil;
}

FREObject showWallet(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]){
    NSString *jsonString = @"";
    if (argc > 0) {
        jsonString = [[NSString alloc] initWithData:[@{@"nonce":getStringFromArgs(argv, 0)} JSONData]
                                                     encoding:NSUTF8StringEncoding];
    }
    UIViewController *rootVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [betable walletInViewController:rootVC onClose:^{
        FREDispatchStatusEventAsync(ctx, (uint8_t*) "com.betable.webview.closed", getUTF8String(jsonString));
    }];
    return nil;
}

FREObject showDeposit(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]){
    NSString *jsonString = @"";
    if (argc > 0) {
        jsonString = [[NSString alloc] initWithData:[@{@"nonce":getStringFromArgs(argv, 0)} JSONData]
                                           encoding:NSUTF8StringEncoding];
    }
    UIViewController *rootVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [betable depositInViewController:rootVC onClose:^{
        FREDispatchStatusEventAsync(ctx, (uint8_t*) "com.betable.webview.closed", getUTF8String(jsonString));
    }];
    return nil;
}

FREObject showWithdraw(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]){
    NSString *jsonString = @"";
    if (argc > 0) {
        jsonString = [[NSString alloc] initWithData:[@{@"nonce":getStringFromArgs(argv, 0)} JSONData]
                                           encoding:NSUTF8StringEncoding];
    }
    UIViewController *rootVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [betable withdrawInViewController:rootVC onClose:^{
        FREDispatchStatusEventAsync(ctx, (uint8_t*) "com.betable.webview.closed", getUTF8String(jsonString));
    }];
    return nil;
}

FREObject showSupport(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]){
    NSString *jsonString = @"";
    if (argc > 0) {
        jsonString = [[NSString alloc] initWithData:[@{@"nonce":getStringFromArgs(argv, 0)} JSONData]
                                           encoding:NSUTF8StringEncoding];
    }
    UIViewController *rootVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [betable supportInViewController:rootVC onClose:^{
        FREDispatchStatusEventAsync(ctx, (uint8_t*) "com.betable.webview.closed", getUTF8String(jsonString));
    }];
    return nil;
}

FREObject showRedeem(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]){
    NSString *promotion = getStringFromArgs(argv, 0);
    NSString *jsonString = @"";
    if (argc > 1) {
        jsonString = [[NSString alloc] initWithData:[@{@"nonce":getStringFromArgs(argv, 1)} JSONData]
                                           encoding:NSUTF8StringEncoding];
    }
    UIViewController *rootVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [betable redeemPromotion:promotion inViewController:rootVC onClose:^{
        FREDispatchStatusEventAsync(ctx, (uint8_t*) "com.betable.webview.closed", getUTF8String(jsonString));
    }];
    return nil;
}

FREObject showBetablePage(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]){
    NSString *path = getStringFromArgs(argv, 0);
    NSDictionary *data = nil;
    if (argc > 1) {
        NSString *jsonData = getStringFromArgs(argv, 1);
        data = (NSDictionary*)[jsonData objectFromJSONString];
    }
    NSString *jsonString = @"";
    if (argc > 2) {
        jsonString = [[NSString alloc] initWithData:[@{@"nonce":getStringFromArgs(argv, 2)} JSONData]
                                           encoding:NSUTF8StringEncoding];
    }
    UIViewController *rootVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [betable loadBetablePath:path inViewController:rootVC withParams:data onClose:^{
        FREDispatchStatusEventAsync(ctx, (uint8_t*) "com.betable.webview.closed", getUTF8String(jsonString));
    }];
    return nil;
}

void BetableContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet){
    *numFunctionsToTest = 26;
    
    FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * *numFunctionsToTest);
    
    *functionsToSet = func;
    
    func[0].name = (const uint8_t*) "init";
    func[0].functionData = NULL;
    func[0].function = &init;
    
    func[1].name = (const uint8_t*) "authorize";
    func[1].functionData = NULL;
    func[1].function = &authorize;
    
    func[2].name = (const uint8_t*) "bet";
    func[2].functionData = NULL;
    func[2].function = &bet;
    
    func[3].name = (const uint8_t*) "creditBet";
    func[3].functionData = NULL;
    func[3].function = &creditBet;
    
    func[4].name = (const uint8_t*) "unbackedBet";
    func[4].functionData = NULL;
    func[4].function = &unbackedBet;
    
    func[5].name = (const uint8_t*) "unbackedCreditBet";
    func[5].functionData = NULL;
    func[5].function = &unbackedCreditBet;
    
    func[6].name = (const uint8_t*) "userWallet";
    func[6].functionData = NULL;
    func[6].function = &userWallet;
    
    func[7].name = (const uint8_t*) "userAccount";
    func[7].functionData = NULL;
    func[7].function = &userAccount;
    
    func[8].name = (const uint8_t*) "createBatchRequest";
    func[8].functionData = NULL;
    func[8].function = &createBatchRequest;
    
    func[9].name = (const uint8_t*) "batchBet";
    func[9].functionData = NULL;
    func[9].function = &batchBet;
    
    func[10].name = (const uint8_t*) "batchCreditBet";
    func[10].functionData = NULL;
    func[10].function = &batchCreditBet;
    
    func[11].name = (const uint8_t*) "batchUnbackedBet";
    func[11].functionData = NULL;
    func[11].function = &batchUnbackedBet;
    
    func[12].name = (const uint8_t*) "batchUnbackedCreditBet";
    func[12].functionData = NULL;
    func[12].function = &batchUnbackedCreditBet;
    
    func[13].name = (const uint8_t*) "runBatch";
    func[13].functionData = NULL;
    func[13].function = &runBatch;
    
    func[14].name = (const uint8_t*) "handleOpenURL";
    func[14].functionData = NULL;
    func[14].function = &handleOpenURL;
    
    func[15].name = (const uint8_t*) "logout";
    func[15].functionData = NULL;
    func[15].function = &logout;
    
    func[16].name = (const uint8_t*) "storeAccessToken";
    func[16].functionData = NULL;
    func[16].function = &storeAccessToken;
    
    func[17].name = (const uint8_t*) "getStoredAccessToken";
    func[17].functionData = NULL;
    func[17].function = &getStoredAccessToken;
    
    func[18].name = (const uint8_t*) "showWallet";
    func[18].functionData = NULL;
    func[18].function = &showWallet;
    
    func[19].name = (const uint8_t*) "showDeposit";
    func[19].functionData = NULL;
    func[19].function = &showDeposit;
    
    func[20].name = (const uint8_t*) "showWithdraw";
    func[20].functionData = NULL;
    func[20].function = &showWithdraw;
    
    func[21].name = (const uint8_t*) "showSupport";
    func[21].functionData = NULL;
    func[21].function = &showSupport;
    
    func[22].name = (const uint8_t*) "showRedeem";
    func[22].functionData = NULL;
    func[22].function = &showRedeem;
    
    func[23].name = (const uint8_t*) "showBetablePage";
    func[23].functionData = NULL;
    func[23].function = &showBetablePage;
    
    func[24].name = (const uint8_t*) "authorizeLogin";
    func[24].functionData = NULL;
    func[24].function = &authorizeLogin;
    
    func[25].name = (const uint8_t*) "unbackedAuthorize";
    func[25].functionData = NULL;
    func[25].function = &unbackedAuthorize;
}

void BetableContextFinalizer(FREContext ctx)
{
    return;
}

void BetableExtensionInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet){
    *extDataToSet = NULL;
    *ctxInitializerToSet = &BetableContextInitializer;
    *ctxFinalizerToSet = &BetableContextFinalizer;
}

void BetableExtensionFinalizer(void* extData)
{
    return;
}
