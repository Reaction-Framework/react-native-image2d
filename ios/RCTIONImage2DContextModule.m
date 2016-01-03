//
//  RCTIONImage2DContextModule.m
//  RCTIONImage2D
//
//  Created by Marko on 13/12/15.
//
//

#import <Foundation/Foundation.h>
#import "RCTIONImage2DContextModule.h"
#import "RCTIONImage2DContext.h"
#import "RCTUtils.h"

static NSMutableDictionary *image2DContexts;

@implementation RCTIONImage2DContextModule

+ (NSMutableDictionary *) getImage2DContexts {
    if (!image2DContexts) {
        image2DContexts = [[NSMutableDictionary alloc] init];
    }
    
    return image2DContexts;
}

- (RCTIONImage2DContext *)createImage2DContext {
    RCTIONImage2DContext *context = [[RCTIONImage2DContext alloc] init];
    [[RCTIONImage2DContextModule getImage2DContexts] setObject:context
                                  forKey:[context getContextId]];
    return context;
}

- (RCTIONImage2DContext *)getImage2DContext:(NSString *)contextId {
    return [[RCTIONImage2DContextModule getImage2DContexts]objectForKey:contextId];
}

- (void)releaseImage2DContext:(NSString *)contextId {
    [[RCTIONImage2DContextModule getImage2DContexts] removeObjectForKey:contextId];
}

- (void)reject:(RCTPromiseRejectBlock)reject withException:(NSException *)exception {
    NSLog(@"RCTIONImage2DContextModule error: %@", exception);
    [self reject:reject withMessage:exception.reason];
}

- (void)reject:(RCTPromiseRejectBlock)reject withMessage:(NSString *)message {
    reject(RCTErrorWithMessage(message));
}

- (NSDictionary *)getParams:(NSDictionary *)options {
    return [options objectForKey:@"params"];
}

RCT_EXPORT_MODULE(Image2DContextModule);

RCT_EXPORT_METHOD(create:(NSDictionary *)options
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    RCTIONImage2DContext* context = [self createImage2DContext];
    @try {
        NSInteger maxWidth = [options[@"maxWidth"] integerValue];
        NSInteger maxHeight = [options[@"maxHeight"] integerValue];
        
        if (!maxWidth || !maxHeight) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:@"Image2DContext requires maxWidth and maxHeight arguments."
                                         userInfo:nil];
        }
        
        NSString* fileUrl = [options objectForKey:@"fileUrl"];
        if (fileUrl) {
            [context createFromFileUrl:fileUrl
                          withMaxWidth:maxWidth
                         withMaxHeight:maxHeight];
            resolve([context getContextId]);
            return;
        }
        
        NSString* base64String = [options objectForKey:@"base64String"];
        if (base64String) {
            [context createFromBase64String:base64String
                               withMaxWidth:maxWidth
                              withMaxHeight:maxHeight];
            resolve([context getContextId]);
            return;
        }
        
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"Image2DContext requires fileUrl or base64String arguments."
                                     userInfo:nil];
    }
    @catch (NSException *exception) {
        [self releaseImage2DContext:[context getContextId]];
        [self reject:reject withException:exception];
    }
}

RCT_EXPORT_METHOD(save:(NSDictionary *)options
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        RCTIONImage2DContext *context = [self getImage2DContext:[options objectForKey:@"id"]];
        NSDictionary *params = [self getParams:options];
        resolve([context save:[params objectForKey:@"fileName"]]);
    }
    @catch (NSException *exception) {
        [self reject:reject withException:exception];
    }
}

RCT_EXPORT_METHOD(getAsBase64String:(NSDictionary *)options
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        RCTIONImage2DContext *context = [self getImage2DContext:[options objectForKey:@"id"]];
        resolve([context getAsBase64String]);
    }
    @catch (NSException *exception) {
        [self reject:reject withException:exception];
    }
}

RCT_EXPORT_METHOD(getWidth:(NSDictionary *)options
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        RCTIONImage2DContext *context = [self getImage2DContext:[options objectForKey:@"id"]];
        resolve([NSNumber numberWithInteger:[context getWidth]]);
    }
    @catch (NSException *exception) {
        [self reject:reject withException:exception];
    }
}

RCT_EXPORT_METHOD(getHeight:(NSDictionary *)options
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        RCTIONImage2DContext *context = [self getImage2DContext:[options objectForKey:@"id"]];
        resolve([NSNumber numberWithInteger:[context getHeight]]);
    }
    @catch (NSException *exception) {
        [self reject:reject withException:exception];
    }
}

RCT_EXPORT_METHOD(crop:(NSDictionary *)options
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        RCTIONImage2DContext *context = [self getImage2DContext:[options objectForKey:@"id"]];
        NSDictionary *params = [self getParams:options];
        NSInteger left = [params[@"left"] integerValue];
        NSInteger top = [params[@"top"] integerValue];
        [context crop:CGRectMake(left,
                                 top,
                                 [context getWidth] - left - [params[@"right"] integerValue],
                                 [context getHeight] - top - [params[@"bottom"] integerValue])];
        resolve(nil);
    }
    @catch (NSException *exception) {
        [self reject:reject withException:exception];
    }
}

RCT_EXPORT_METHOD(drawBorder:(NSDictionary *)options
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        RCTIONImage2DContext *context = [self getImage2DContext:[options objectForKey:@"id"]];
        NSDictionary *params = [self getParams:options];
        [context drawBorder:[params objectForKey:@"color"]
                withLeftTop:CGSizeMake([params[@"left"] integerValue], [params[@"top"] integerValue])
            withRightBottom:CGSizeMake([params[@"right"] integerValue], [params[@"bottom"] integerValue])];
        resolve(nil);
    }
    @catch (NSException *exception) {
        [self reject:reject withException:exception];
    }
}

RCT_EXPORT_METHOD(release:(NSDictionary *)options
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    [self releaseImage2DContext:[options objectForKey:@"id"]];
    resolve(nil);
}

@end
