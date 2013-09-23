//
//  BetableAirSDK.m
//  BetableAirSDK
//
//  Created by Tony hauber on 9/9/13.
//  Copyright (c) 2013 Betable. All rights reserved.
//

#import "FlashRuntimeExtensions.h"
#import <Betable/Betable.h>


Betable *betable;
NSMutableDictionary *batchRequests;
static int batchRequestCount;

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

FREObject init(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]){
    return nil;
}

FREObject authorize(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    NSString *clientID = getStringFromArgs(argv, 0);
    NSString *clientSecret = getStringFromArgs(argv, 1);
    NSString *redirectURI = getStringFromArgs(argv, 2);
    betable = [[Betable alloc] initWithClientID:clientID clientSecret:clientSecret redirectURI:redirectURI];
    UIViewController *rootVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [betable authorizeInViewController:rootVC onAuthorizationComplete:^(NSString *accessToken) {
        NSDictionary *data = @{@"access_token": accessToken};
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
        
    } onCancel:^{
        FREDispatchStatusEventAsync(ctx, (uint8_t*) "com.betable.authorize.canceled", (uint8_t*)"");
    }];
    return nil;
}

FREObject handleOpenURL(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]){
    NSString *openURL = getStringFromArgs(argv, 0);
    [betable handleAuthorizeURL:[NSURL URLWithString:openURL]];
    return nil;
}

NSDictionary *addBetNonce(NSDictionary* data, NSString *nonce) {
    if (nonce) {
        NSMutableDictionary *mutData = [data mutableCopy];
        mutData[@"nonce"] = nonce;
        data = [NSDictionary dictionaryWithDictionary:mutData];
    }
    return data;
}

FREObject bet(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]){
    
    NSString *gameID = getStringFromArgs(argv, 0);
    NSString *jsonData = getStringFromArgs(argv, 1);
    NSString *nonce = nil;
    if (argc > 2) {
        nonce = getStringFromArgs(argv, 2);
    }
    NSDictionary *data = (NSDictionary*)[jsonData objectFromJSONString];
    
    [betable betForGame:gameID withData:data onComplete:^(NSDictionary *data) {
        NSString *jsonString = [[NSString alloc] initWithData:[addBetNonce(data, nonce) JSONData]
                                                encoding:NSUTF8StringEncoding];
        FREDispatchStatusEventAsync(ctx, (uint8_t*) "com.betable.bet.created", getUTF8String(jsonString));
    } onFailure:^(NSURLResponse *response, NSString *responseBody, NSError *error) {
        NSDictionary *data = @{
            @"code": @([error code]),
            @"domain": [error domain],
            @"user_info": [error userInfo]
        };
        NSString *jsonString = [[NSString alloc] initWithData:[addBetNonce(data, nonce) JSONData]
                                                     encoding:NSUTF8StringEncoding];
        FREDispatchStatusEventAsync(ctx, (uint8_t*) "com.betable.bet.errored", getUTF8String(jsonString));
    }];
    
    return nil;
}

FREObject creditBet(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]){
    
    NSString *gameID = getStringFromArgs(argv, 0);
    NSString *creditGameID = getStringFromArgs(argv, 1);
    NSString *jsonData = getStringFromArgs(argv, 2);
    NSDictionary *data = (NSDictionary*)[jsonData objectFromJSONString];
    
    NSString *nonce = nil;
    if (argc > 3) {
        nonce = getStringFromArgs(argv, 3);
    }
    
    [betable creditBetForGame:gameID creditGame:creditGameID withData:data onComplete:^(NSDictionary *data) {
        NSString *jsonString = [[NSString alloc] initWithData:[addBetNonce(data, nonce) JSONData]
                                                     encoding:NSUTF8StringEncoding];
        FREDispatchStatusEventAsync(ctx, (uint8_t*) "com.betable.credit_bet.created", getUTF8String(jsonString));
    } onFailure:^(NSURLResponse *response, NSString *responseBody, NSError *error) {
        NSDictionary *data = @{
                               @"code": @([error code]),
                               @"domain": [error domain],
                               @"user_info": [error userInfo]
                               };
        NSString *jsonString = [[NSString alloc] initWithData:[addBetNonce(data, nonce) JSONData]
                                                     encoding:NSUTF8StringEncoding];
        FREDispatchStatusEventAsync(ctx, (uint8_t*) "com.betable.credit_bet.errored", getUTF8String(jsonString));
    }];
    
    return nil;
}

FREObject unbackedBet(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]){
    
    NSString *gameID = getStringFromArgs(argv, 0);
    NSString *jsonData = getStringFromArgs(argv, 1);
    NSDictionary *data = (NSDictionary*)[jsonData objectFromJSONString];
    
    NSString *nonce = nil;
    if (argc > 2) {
        nonce = getStringFromArgs(argv, 2);
    }
    
    [betable unbackedBetForGame:gameID withData:data onComplete:^(NSDictionary *data) {
        NSString *jsonString = [[NSString alloc] initWithData:[addBetNonce(data, nonce) JSONData]
                                                     encoding:NSUTF8StringEncoding];
        FREDispatchStatusEventAsync(ctx, (uint8_t*) "com.betable.unbacked_bet.created", getUTF8String(jsonString));
    } onFailure:^(NSURLResponse *response, NSString *responseBody, NSError *error) {
        NSDictionary *data = @{
                               @"code": @([error code]),
                               @"domain": [error domain],
                               @"user_info": [error userInfo]
                               };
        NSString *jsonString = [[NSString alloc] initWithData:[addBetNonce(data, nonce) JSONData]
                                                     encoding:NSUTF8StringEncoding];
        FREDispatchStatusEventAsync(ctx, (uint8_t*) "com.betable.bet.errored", getUTF8String(jsonString));
    }];
    
    return nil;
}

FREObject unbackedCreditBet(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]){
    
    NSString *gameID = getStringFromArgs(argv, 0);
    NSString *creditGameID = getStringFromArgs(argv, 1);
    NSString *jsonData = getStringFromArgs(argv, 2);
    NSDictionary *data = (NSDictionary*)[jsonData objectFromJSONString];
    
    NSString *nonce = nil;
    if (argc > 3) {
        nonce = getStringFromArgs(argv, 3);
    }
    
    [betable unbackedCreditBetForGame:gameID creditGame:creditGameID withData:data onComplete:^(NSDictionary *data) {
        NSString *jsonString = [[NSString alloc] initWithData:[addBetNonce(data, nonce) JSONData]
                                                     encoding:NSUTF8StringEncoding];
        FREDispatchStatusEventAsync(ctx, (uint8_t*) "com.betable.unbacked_credit_bet.created", getUTF8String(jsonString));
    } onFailure:^(NSURLResponse *response, NSString *responseBody, NSError *error) {
        NSDictionary *data = @{
                               @"code": @([error code]),
                               @"domain": [error domain],
                               @"user_info": [error userInfo]
                               };
        NSString *jsonString = [[NSString alloc] initWithData:[addBetNonce(data, nonce) JSONData]
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
    FRENewObjectFromUTF8([batchID length], getUTF8String(batchID), &object);
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

void BetableContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet){
    *numFunctionsToTest = 15;
    
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
