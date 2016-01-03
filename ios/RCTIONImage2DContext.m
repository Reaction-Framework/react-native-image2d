//
//  RCTIONImage2DContext.m
//  RCTIONImage2D
//
//  Created by Marko on 26/12/15.
//
//

#import "RCTIONImage2DContext.h"
#import "UIColor+ParseColor.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

@implementation RCTIONImage2DContext {
    NSString *_contextId;
    CGImageRef _image;
}

- (id)init {
    self = [super init];
    if (self != nil) {
        _contextId = [[NSUUID UUID] UUIDString];
    }
    return self;
}

- (NSString *)getContextId {
    return _contextId;
}

- (void)createFromFileUrl:(NSString *)fileUrl
             withMaxWidth:(NSInteger)maxWidth
            withMaxHeight:(NSInteger)maxHeight {
    NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:fileUrl]];
    [self createFromData:imageData
             withMaxWidth:maxWidth
            withMaxHeight:maxHeight];
}

- (void)createFromBase64String:(NSString*)base64
                  withMaxWidth:(NSInteger)maxWidth
                 withMaxHeight:(NSInteger)maxHeight {
    NSData *imageData = [[NSData alloc] initWithBase64EncodedString:base64
                                                            options:0];
    [self createFromData:imageData
            withMaxWidth:maxWidth
           withMaxHeight:maxHeight];
}

- (void)createFromData:(NSData*)imageData
          withMaxWidth:(NSInteger)maxWidth
         withMaxHeight:(NSInteger)maxHeight {
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
    CGImageRef newImage = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
    CFRelease(imageSource);
    
    [self createFromImage:newImage
            withMaxWidth:maxWidth
           withMaxHeight:maxHeight];
    
    CGImageRelease(newImage);
}

- (void)createFromImage:(CGImageRef)image
           withMaxWidth:(NSInteger)maxWidth
          withMaxHeight:(NSInteger)maxHeight {
    double orgWidth = CGImageGetWidth(image);
    double orgHeight = CGImageGetHeight(image);
    
    if (orgWidth <= maxWidth && orgHeight <= maxHeight) {
        _image = CGImageRetain(image);
        return;
    }
    
    double newWidth = maxWidth;
    double newHeight = maxHeight;
    
    if (orgWidth / maxWidth < orgHeight / maxHeight) {
        newWidth = (newHeight / orgHeight) * orgWidth;
    } else {
        newHeight = (newWidth / orgWidth) * orgHeight;
    }
    
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image);
    CGContextRef context = CGBitmapContextCreate(nil,
                                                 newWidth,
                                                 newHeight,
                                                 CGImageGetBitsPerComponent(image),
                                                 32 * newWidth,
                                                 colorSpace,
                                                 CGImageGetAlphaInfo(image));
    CGContextDrawImage(context, CGRectMake(0, 0, newWidth, newHeight), image);
    
    _image = CGBitmapContextCreateImage(context);
    
    CGContextRelease(context);
}

- (NSString *)save:(NSString *)fileName {
    NSData *imageData = [self getAsData];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *imagePath = [[documentsDirectory stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"jpg"];
    
    [fileManager createFileAtPath:imagePath contents:imageData attributes:nil];
    
    return imagePath;
}

- (NSString *)getAsBase64String {
    return [[self getAsData] base64EncodedStringWithOptions:0];
}

- (NSData *)getAsData {
    NSDictionary *properties;
    CFMutableDataRef imageData = CFDataCreateMutable(NULL, 0);
    CFStringRef type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef) @"image/png", kUTTypeImage);
    CGImageDestinationRef destination = CGImageDestinationCreateWithData(imageData, type, 1, NULL);
    CGImageDestinationAddImage(destination, _image, (__bridge CFDictionaryRef) properties);
    CGImageDestinationFinalize(destination);
    
    CFRelease(type);
    CFRelease(destination);
    
    return (__bridge_transfer NSData *)imageData;
}

- (NSInteger)getWidth {
    return CGImageGetWidth(_image);
}

- (NSInteger)getHeight {
    return CGImageGetHeight(_image);
}

- (void)crop:(CGRect)cropRectangle {
    CGImageRef newImage = CGImageCreateWithImageInRect(_image, cropRectangle);
    CGImageRelease(_image);
    _image = newImage;
}

- (void)drawBorder:(NSString*)color
       withLeftTop:(CGSize)leftTop
   withRightBottom:(CGSize)rightBottom {
    double orgWidth = [self getWidth];
    double orgHeight = [self getHeight];
    double newWidth = orgWidth + leftTop.width + rightBottom.width;
    double newHeight = orgHeight + leftTop.height + rightBottom.height;
    
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(_image);
    CGContextRef context = CGBitmapContextCreate(nil,
                                             newWidth,
                                             newHeight,
                                             CGImageGetBitsPerComponent(_image),
                                             32 * newWidth,
                                             colorSpace,
                                             CGImageGetAlphaInfo(_image));
    CGContextBeginPath(context);
    CGColorRef borderColor = CGColorRetain([UIColor parseColor:color].CGColor);
    CGContextSetFillColorWithColor(context, borderColor);
    CGContextFillRect(context, CGRectMake(0, 0, newWidth, newHeight));
    
    CGContextDrawImage(context, CGRectMake(leftTop.width, rightBottom.height, orgWidth, orgHeight), _image);
    
    CGImageRef newImage = CGBitmapContextCreateImage(context);
    
    CGImageRelease(_image);
    CGColorRelease(borderColor);
    CGContextRelease(context);
    
    _image = newImage;
}

- (void)dealloc {
    _contextId = nil;
    if (_image) {
        CGImageRelease(_image);
        _image = nil;
    }
}

@end
