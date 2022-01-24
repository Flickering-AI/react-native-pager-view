//
//  ReactViewPagerManager.swift
//  react-native-pager-view
//
//  Created by Xuanping Liu on 2022/1/14.
//

import Foundation


@objc(ReactViewPagerManager)
class ReactViewPagerManager: RCTViewManager {
  
  var viewInstance: ReactNativePageView?

  override class func requiresMainQueueSetup() -> Bool {
    return false
  }
  
  override func view() -> (UIView) {
    self.viewInstance = ReactNativePageView(eventDispatcher: self.bridge.eventDispatcher() as! RCTEventDispatcher)
    return self.viewInstance!
  }
  
  @objc func setPage(_ reactTag: NSNumber, index: NSNumber) {
      
      DispatchQueue.main.async {
        let nextIndex = Int(truncating: index)
        self.viewInstance!.segmentedView?.selectItemAt(index: nextIndex);
        self.viewInstance!.listContainerView?.didClickSelectedItem(at: nextIndex)
      }
    }
}
