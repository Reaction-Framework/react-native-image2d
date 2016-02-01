//
//  UIColorParseColor.swift
//  RCTIONImage2D
//
//  Created by Marko on 14/01/16.
//
//

import Foundation

extension UIColor {
  private static func colorComponentFrom(string: String, fromIndex start: Int, withLength length: Int) -> Float {
    let substring = string[string.startIndex.advancedBy(start)..<string.startIndex.advancedBy(start + length)]
    let fullHex = length == 2 ? substring : String(format: "%@%@", substring, substring)
    
    var hexComponent:CUnsignedInt = 0
    NSScanner(string: fullHex).scanHexInt(&hexComponent)
    return Float(hexComponent) / 255.0
  }
  
  static func parseColor(colorString: String) throws -> UIColor {
    if colorString.hasPrefix("#") {
      let hexString = colorString.substringFromIndex(colorString.startIndex.advancedBy(1)).uppercaseString
      
      switch hexString.characters.count {
      case 3:
        // #RGB
        return UIColor(
          colorLiteralRed: colorComponentFrom(hexString, fromIndex: 0, withLength: 1),
          green: colorComponentFrom(hexString, fromIndex: 1, withLength: 1),
          blue: colorComponentFrom(hexString, fromIndex: 2, withLength: 1),
          alpha: 1.0
        )
      case 4:
        // #ARGB
        return UIColor(
          colorLiteralRed: colorComponentFrom(hexString, fromIndex: 1, withLength: 1),
          green: colorComponentFrom(hexString, fromIndex: 2, withLength: 1),
          blue: colorComponentFrom(hexString, fromIndex: 3, withLength: 1),
          alpha: colorComponentFrom(hexString, fromIndex: 0, withLength: 1)
        )
      case 6:
        // #RRGGBB
        return UIColor(
          colorLiteralRed: colorComponentFrom(hexString, fromIndex: 0, withLength: 2),
          green: colorComponentFrom(hexString, fromIndex: 2, withLength: 2),
          blue: colorComponentFrom(hexString, fromIndex: 4, withLength: 2),
          alpha: 1.0
        )
      case 8:
        // #AARRGGBB
        return UIColor(
          colorLiteralRed: colorComponentFrom(hexString, fromIndex: 2, withLength: 2),
          green: colorComponentFrom(hexString, fromIndex: 4, withLength: 2),
          blue: colorComponentFrom(hexString, fromIndex: 6, withLength: 2),
          alpha: colorComponentFrom(hexString, fromIndex: 0, withLength: 2)
        )
      default:
        break
      }
    } else {
      let selector = Selector(colorString.stringByAppendingString("Color"));
      if (UIColor.respondsToSelector(selector)) {
        return UIColor.performSelector(selector).takeUnretainedValue() as! UIColor
      }
    }
    
    throw ColorParseError.InvalidColorString("Could not parse color from string: " + colorString + ".")
  }
  
  enum ColorParseError: ErrorType {
    case InvalidColorString(String)
  }
}
