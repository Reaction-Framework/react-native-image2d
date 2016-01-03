//
//  RCTIONImage2DContext.h
//  RCTIONImage2D
//
//  Created by Marko on 26/12/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface RCTIONImage2DContext : NSObject

- (NSString *)getContextId;
- (void)createFromFileUrl:(NSString *)fileUrl
             withMaxWidth:(NSInteger)maxWidth
            withMaxHeight:(NSInteger)maxHeight;
- (void)createFromBase64String:(NSString *)base64
                  withMaxWidth:(NSInteger)maxWidth
                 withMaxHeight:(NSInteger)maxHeight;
- (NSString *)save:(NSString *)fileName;
- (NSString *)getAsBase64String;
- (NSInteger)getWidth;
- (NSInteger)getHeight;
- (void)crop:(CGRect)cropRectangle;
- (void)drawBorder:(NSString *)color
       withLeftTop:(CGSize)leftTop
   withRightBottom:(CGSize)rightBottom;

@end
