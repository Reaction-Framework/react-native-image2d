//
//  RCTIONImage2DContextModule.swift
//  RCTIONImage2D
//
//  Created by Marko on 14/01/16.
//  
//

import Foundation

@objc(RCTIONImage2DContextModule)
class RCTIONImage2DContextModule: NSObject {
  private static var image2DContexts = [String: RCTIONImage2DContext]()
  
  private func createImage2DContext() -> RCTIONImage2DContext {
    let context = RCTIONImage2DContext()
    RCTIONImage2DContextModule.image2DContexts[context.getContextId()] = context
    return context
  }
  
  private func getImage2DContext(contextId: String) -> RCTIONImage2DContext {
    return RCTIONImage2DContextModule.image2DContexts[contextId]!
  }
  
  private func releaseImage2DContext(contextId: String) -> Void {
    RCTIONImage2DContextModule.image2DContexts.removeValueForKey(contextId)
  }
  
  private func reject(reject: RCTPromiseRejectBlock, withError error: NSError) {
    NSLog("RCTIONImage2DContextModule error: %@", error)
    self.reject(reject, withMessage: error.localizedDescription)
  }
  
  private func reject(reject: RCTPromiseRejectBlock, withMessage message: String) {
    let error = RCTErrorWithMessage(message)
    reject(String(error.code), error.localizedDescription, error)
  }
  
  private func getParams(options: NSDictionary) -> NSDictionary {
    return options.objectForKey("params") as! NSDictionary
  }
  
  @objc func create(options: NSDictionary, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
    let maxWidth = options["maxWidth"]!.integerValue
    let maxHeight = options["maxHeight"]!.integerValue
    
    if maxWidth <= 0 || maxHeight <= 0 {
      self.reject(reject, withMessage: "Image2DContext requires maxWidth and maxHeight arguments.")
      return
    }
    
    let context = self.createImage2DContext()
    
    let fileUrl = options.objectForKey("fileUrl") as? String
    if fileUrl != nil {
      context.createFromFileUrl(fileUrl!, withMaxWidth:maxWidth, withMaxHeight:maxHeight)
      resolve(context.getContextId())
      return
    }
    
    let base64String = options.objectForKey("base64String") as? String
    if base64String != nil {
      context.createFromBase64String(base64String!, withMaxWidth:maxWidth, withMaxHeight:maxHeight)
      resolve(context.getContextId())
      return
    }
    
    self.releaseImage2DContext(context.getContextId())
    self.reject(reject, withMessage: "Image2DContext requires fileUrl or base64String arguments.")
  }
  
  @objc func save(options: NSDictionary, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
    let context = self.getImage2DContext(options.objectForKey("id") as! String)
    let params = self.getParams(options)
    resolve(context.save(params.objectForKey("fileName") as! String))
  }
  
  @objc func getAsBase64String(options: NSDictionary, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
    let context = self.getImage2DContext(options.objectForKey("id") as! String)
    resolve(context.getAsBase64String())
  }
  
  @objc func getWidth(options: NSDictionary, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
    let context = self.getImage2DContext(options.objectForKey("id") as! String)
    resolve(context.getWidth())
  }
  
  @objc func getHeight(options: NSDictionary, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
    let context = self.getImage2DContext(options.objectForKey("id") as! String)
    resolve(context.getHeight())
  }
  
  @objc func crop(options: NSDictionary, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
    let context = self.getImage2DContext(options.objectForKey("id") as! String)
    let params = self.getParams(options)
    let left = params["left"]!.integerValue
    let top = params["top"]!.integerValue
    
    context.crop(
      CGRectMake(
        CGFloat(left),
        CGFloat(top),
        CGFloat(context.getWidth() - left - params["right"]!.integerValue),
        CGFloat(context.getHeight() - top - params["bottom"]!.integerValue)
      )
    )
    
    resolve(nil)
  }
  
  @objc func drawBorder(options: NSDictionary, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
    do {
      let context = self.getImage2DContext(options.objectForKey("id") as! String)
      let params = self.getParams(options)
      
      try context.drawBorder(
        params.objectForKey("color") as! String,
        withLeftTop: CGSizeMake(CGFloat(params["left"]!.integerValue), CGFloat(params["top"]!.integerValue)),
        withRightBottom: CGSizeMake(CGFloat(params["right"]!.integerValue), CGFloat(params["bottom"]!.integerValue))
      )
      
      resolve(nil)
    } catch UIColor.ColorParseError.InvalidColorString(let message) {
      self.reject(reject, withMessage: message)
    } catch let error as NSError {
      self.reject(reject, withError: error)
    }
  }
  
  @objc func release(options: NSDictionary, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
    self.releaseImage2DContext(options.objectForKey("id") as! String)
    resolve(nil)
  }
}
