//
//  ReactViewPagerManager.swift
//  react-native-pager-view
//
//  Created by Xuanping Liu on 2022/1/14.
//

import Foundation


@objc(ReactViewPagerManager)
class ReactViewPagerManager: RCTViewManager {
  
  override class func requiresMainQueueSetup() -> Bool {
    return false
  }
  
  override func view() -> (UIView) {
    return NativePageView(eventDispatcher: self.bridge.eventDispatcher() as! RCTEventDispatcher)
  }
  
  @objc func setPage(_ reactTag: NSNumber, index: NSNumber) {
    let nextIndex = Int(truncating: index)
    self.bridge.uiManager.addUIBlock { (uiManager: RCTUIManager?, viewRegistry: [NSNumber : UIView]?) in
      (viewRegistry![reactTag] as! ReactNativePageView).setPage(nextPageIndex: nextIndex)
    };
  }
}

@objc(JXSegmentedPageViewManager)
class JXSegmentedPageViewManager: RCTViewManager {
  
  override class func requiresMainQueueSetup() -> Bool {
    return false
  }
  
  override func view() -> (UIView) {
    return JXSegmentedPageView(eventDispatcher: self.bridge.eventDispatcher() as! RCTEventDispatcher)
  }
  
  @objc func setPage(_ reactTag: NSNumber, index: NSNumber) {
    let nextIndex = Int(truncating: index)
    self.bridge.uiManager.addUIBlock { (uiManager: RCTUIManager?, viewRegistry: [NSNumber : UIView]?) in
      (viewRegistry![reactTag] as! ReactNativePageView).setPage(nextPageIndex: nextIndex)
    };
  }
}
