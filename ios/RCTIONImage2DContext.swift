//
//  RCTIONImage2DContext.swift
//  RCTIONImage2D
//
//  Created by Marko on 14/01/16.
//  
//

import Foundation
import ImageIO
import MobileCoreServices

class RCTIONImage2DContext: NSObject {
  private var contextId = NSUUID().UUIDString
  private var image: CGImageRef?
  
  func getContextId() -> String {
    return self.contextId;
  }
  
  func createFromFileUrl(fileUrl: String, withMaxWidth maxWidth: Int, withMaxHeight maxHeight: Int) -> Void {
    let imageData = NSData.init(contentsOfURL: NSURL.init(fileURLWithPath: fileUrl))!
    self.createFromData(imageData, withMaxWidth: maxWidth, withMaxHeight: maxHeight)
  }
  
  func createFromBase64String(base64: String, withMaxWidth maxWidth: Int, withMaxHeight maxHeight: Int) -> Void {
    let imageData = NSData.init(base64EncodedString: base64, options: NSDataBase64DecodingOptions(rawValue: 0))!
    self.createFromData(imageData, withMaxWidth: maxWidth, withMaxHeight: maxHeight)
  }
  
  private func createFromData(imageData: NSData, withMaxWidth maxWidth: Int, withMaxHeight maxHeight: Int) -> Void {
    let imageSource = CGImageSourceCreateWithData(imageData, nil)!
    let newImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)!
    self.createFromImage(newImage, withMaxWidth: maxWidth, withMaxHeight: maxHeight)
  }
  
  private func createFromImage(image: CGImageRef, withMaxWidth maxWidth: Int, withMaxHeight maxHeight: Int) -> Void {
    let orgWidth = Double(CGImageGetWidth(image))
    let orgHeight = Double(CGImageGetHeight(image))
    var calcNewWidth = Double(maxWidth)
    var calcNewHeight = Double(maxHeight)
    
    if orgWidth <= calcNewWidth && orgHeight <= calcNewHeight {
      self.image = image
      return;
    }
    
    if orgWidth / calcNewWidth < orgHeight / calcNewHeight {
      calcNewWidth = (calcNewHeight / orgHeight) * orgWidth
    } else {
      calcNewHeight = (calcNewWidth / orgWidth) * orgHeight
    }
    
    let newWidth = Int(calcNewWidth)
    let newHeight = Int(calcNewHeight)
    
    let context = CGBitmapContextCreate(
      nil,
      newWidth,
      newHeight,
      CGImageGetBitsPerComponent(image),
      32 * newWidth,
      CGImageGetColorSpace(image),
      CGImageGetAlphaInfo(image).rawValue
    )
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGFloat(newWidth), CGFloat(newHeight)), image)
    
    self.image = CGBitmapContextCreateImage(context)
  }
  
  func save(fileName: String) -> String {
    let imageData = self.getAsData()
    
    let documentsDirectory: NSString = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    let fileManager = NSFileManager.defaultManager()
    
    let imagePath = (documentsDirectory.stringByAppendingPathComponent(fileName) as NSString).stringByAppendingPathExtension("jpg")!
    fileManager.createFileAtPath(imagePath, contents: imageData, attributes: nil)
    
    return imagePath
  }
  
  func getAsBase64String() -> String {
    return self.getAsData().base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
  }
  
  private func getAsData() -> NSData {
    let imageData = CFDataCreateMutable(nil, 0)
    let type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, "image/png", kUTTypeImage)!.takeRetainedValue()
    let destination = CGImageDestinationCreateWithData(imageData, type, 1, nil)!
    CGImageDestinationAddImage(destination, self.image!, nil)
    CGImageDestinationFinalize(destination)
    
    return imageData
  }
  
  func getWidth() -> Int {
    return CGImageGetWidth(self.image);
  }
  
  func getHeight() -> Int {
    return CGImageGetHeight(self.image);
  }
  
  func crop(cropRectangle: CGRect) -> Void {
    self.image = CGImageCreateWithImageInRect(self.image, cropRectangle);
  }
  
  func drawBorder(color: String, withLeftTop leftTop: CGSize, withRightBottom rightBottom: CGSize) throws -> Void {
    let orgWidth = self.getWidth()
    let orgHeight = self.getHeight()
    let newWidth = orgWidth + Int(leftTop.width + rightBottom.width);
    let newHeight = orgHeight + Int(leftTop.height + rightBottom.height);
    
    let context = CGBitmapContextCreate(
      nil,
      newWidth,
      newHeight,
      CGImageGetBitsPerComponent(self.image),
      32 * newWidth,
      CGImageGetColorSpace(self.image),
      CGImageGetAlphaInfo(self.image).rawValue
    )
    
    CGContextBeginPath(context);
    CGContextSetFillColorWithColor(context, try UIColor.parseColor(color).CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, CGFloat(newWidth), CGFloat(newHeight)));
    CGContextDrawImage(context, CGRectMake(leftTop.width, rightBottom.height, CGFloat(orgWidth), CGFloat(orgHeight)), self.image);
    
    self.image = CGBitmapContextCreateImage(context);
  }
  
  deinit {
    self.image = nil;
  }
}
