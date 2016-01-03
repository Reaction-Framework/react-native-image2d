//
//  RCTIONImage2DContextModule.h
//  RCTIONImage2D
//
//  Created by Marko on 13/12/15.
//
//

#import "RCTBridgeModule.h"

@interface RCTIONImage2DContextModule : NSObject <RCTBridgeModule>

- (void)create:(NSDictionary *)options
      resolver:(RCTPromiseResolveBlock)resolve
      rejecter:(RCTPromiseRejectBlock)reject;

- (void)save:(NSDictionary *)options
    resolver:(RCTPromiseResolveBlock)resolve
    rejecter:(RCTPromiseRejectBlock)reject;

- (void)getAsBase64String:(NSDictionary *)options
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject;

- (void)getWidth:(NSDictionary *)options
        resolver:(RCTPromiseResolveBlock)resolve
        rejecter:(RCTPromiseRejectBlock)reject;

- (void)getHeight:(NSDictionary *)options
         resolver:(RCTPromiseResolveBlock)resolve
         rejecter:(RCTPromiseRejectBlock)reject;

- (void)crop:(NSDictionary *)options
    resolver:(RCTPromiseResolveBlock)resolve
    rejecter:(RCTPromiseRejectBlock)reject;

- (void)drawBorder:(NSDictionary *)options
          resolver:(RCTPromiseResolveBlock)resolve
          rejecter:(RCTPromiseRejectBlock)reject;

- (void)release:(NSDictionary *)options
       resolver:(RCTPromiseResolveBlock)resolve
       rejecter:(RCTPromiseRejectBlock)reject;

@end
