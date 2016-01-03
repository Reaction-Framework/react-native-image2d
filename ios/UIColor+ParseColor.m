//
//  UIColor+ParseColor.m
//  RCTIONImage2D
//
//  Created by Marko on 02/01/16.
//
//

#import "UIColor+ParseColor.h"

@implementation UIColor (ParseColor)

+ (CGFloat)colorComponentFrom:(NSString *)string
                        start:(NSUInteger)start
                       length:(NSUInteger)length {
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}

+ (UIColor *)parseColor:(NSString *)colorString {
    if([colorString hasPrefix:@"#"]) {
        NSString *hexString = [[colorString substringFromIndex:1] uppercaseString];
        NSUInteger length = [hexString length];
        
        // #RGB
        if (length == 3) {
            return [UIColor colorWithRed: [self colorComponentFrom: hexString start: 0 length: 1]
                                   green: [self colorComponentFrom: hexString start: 1 length: 1]
                                    blue: [self colorComponentFrom: hexString start: 2 length: 1]
                                   alpha: 1.0f];
        }
        
        // #ARGB
        if (length == 4) {
            return [UIColor colorWithRed: [self colorComponentFrom: hexString start: 1 length: 1]
                                   green: [self colorComponentFrom: hexString start: 2 length: 1]
                                    blue: [self colorComponentFrom: hexString start: 3 length: 1]
                                   alpha: [self colorComponentFrom: hexString start: 0 length: 1]];
        }
        
        // #RRGGBB
        if (length == 6) {
            return [UIColor colorWithRed: [self colorComponentFrom: hexString start: 0 length: 2]
                                   green: [self colorComponentFrom: hexString start: 2 length: 2]
                                    blue: [self colorComponentFrom: hexString start: 4 length: 2]
                                   alpha: 1.0f];
        }
        
        // #AARRGGBB
        if (length == 8) {
            return [UIColor colorWithRed: [self colorComponentFrom: hexString start: 2 length: 2]
                                   green: [self colorComponentFrom: hexString start: 4 length: 2]
                                    blue: [self colorComponentFrom: hexString start: 6 length: 2]
                                   alpha: [self colorComponentFrom: hexString start: 0 length: 2]];
        }
    } else {
        SEL selector = NSSelectorFromString([colorString stringByAppendingString:@"Color"]);
        if ([UIColor respondsToSelector:selector]) {
            return [UIColor performSelector:selector];
        }
    }
    
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:[NSString stringWithFormat:@"UIColor.parseColor colorString format is not supported: %@", colorString]
                                 userInfo:nil];
}

@end
