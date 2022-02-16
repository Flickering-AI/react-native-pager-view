//
//  ReactNativePageView.swift
//  react-native-pager-view
//
//  Created by Xuanping Liu on 2022/1/14.
//

import Foundation
import JXSegmentedView

class ListContinerView: UIView {
  var reactSubView: UIView
  var reactBound: CGRect
  
  init(reactSubView: UIView, bound: CGRect) {
    self.reactSubView = reactSubView
    self.reactBound = bound
    self.reactSubView.frame = self.reactBound
    super.init(frame: bound)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    self.reactSubView.frame = self.reactBound
    addSubview(self.reactSubView)
  }
}

extension ListContinerView: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self
    }
}

class JXSegmentedPageView : UIView, JXSegmentedViewDelegate, JXSegmentedListContainerViewDataSource {
  func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
    if let titleDataSource = segmentedView!.dataSource as? JXSegmentedBaseDataSource {
        return titleDataSource.dataSource.count
    }
    return 0
  }
  
  func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
//    print("self.bounds:\(self.bounds)")
    if (self.bounds.size.width == 0 || self.bounds.size.height == 0) {
      print("incorrect size, update again")
      DispatchQueue.main.async {
        self.updateDataSource()
      }
    }
    return ListContinerView(reactSubView: self.reactSubviews()[index], bound: self.bounds)
  }
  

  func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
    segmentedView.listContainer?.didClickSelectedItem(at: index) // Fix blank screen in a hack way. Wait for JXSegmentedView update to fix.
    self.eventDispatcher?.send(RCTOnPageSelected(reactTag: self.reactTag, position: NSNumber(value: index), coalescingKey: 0))
  }
  
//  func segmentedView(_ segmentedView: JXSegmentedView, didClickSelectedItemAt index: Int) {
//    self.eventDispatcher?.send(RCTOnPageSelected(reactTag: self.reactTag, position: NSNumber(value: index), coalescingKey: 0))
//  }
//
//  func segmentedView(_ segmentedView: JXSegmentedView, didScrollSelectedItemAt index: Int) {
//    self.eventDispatcher?.send(RCTOnPageSelected(reactTag: self.reactTag, position: NSNumber(value: index), coalescingKey: 0))
//  }
  
  func segmentedView(_ segmentedView: JXSegmentedView, scrollingFrom leftIndex: Int, to rightIndex: Int, percent: CGFloat) {
    self.eventDispatcher?.send(RCTOnPageScrollEvent(reactTag: self.reactTag, position: NSNumber(value: leftIndex), offset: NSNumber(value: percent)))
  }
  
  func segmentedView(_ segmentedView: JXSegmentedView, canClickItemAt index: Int) -> Bool {
    return true
  }
  
  var segmentedDataSource: JXSegmentedTitleDataSource?
  var segmentedView: JXSegmentedView?
  lazy var listContainerView: JXSegmentedListContainerView! = {
      return JXSegmentedListContainerView(dataSource: self)
  }()
  var cachedViews = [ListContinerView]()
  var eventDispatcher: RCTEventDispatcher?
  
  @objc var color: String = "" {
    didSet {
//      self.backgroundColor = hexStringToUIColor(hexColor: color)
    }
  }
  
  @objc var initialPage: Int = 0 {
    didSet {
      
    }
  }
  @objc var onPageSelected: RCTDirectEventBlock?
  @objc var onPageScroll: RCTDirectEventBlock?
  


  func hexStringToUIColor(hexColor: String) -> UIColor {
    let stringScanner = Scanner(string: hexColor)

    if(hexColor.hasPrefix("#")) {
      stringScanner.scanLocation = 1
    }
    var color: UInt32 = 0
    stringScanner.scanHexInt32(&color)

    let r = CGFloat(Int(color >> 16) & 0x000000FF)
    let g = CGFloat(Int(color >> 8) & 0x000000FF)
    let b = CGFloat(Int(color) & 0x000000FF)

    return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1)
  }
  
  override func didMoveToWindow() {
    super.didMoveToWindow()
    if ((self.segmentedView == nil) && self.reactViewController() != nil) {
      self.setupControllers()
    }
  }
  
  override func didMoveToSuperview() {
    super.didMoveToSuperview()
    if ((self.segmentedView == nil) && self.reactViewController() != nil) {
      self.setupControllers()
    }
    
  }
  
  override func didUpdateReactSubviews() {
    if ((self.segmentedView == nil) && self.reactViewController() != nil) {
      self.setupControllers()
    } else if (self.segmentedView != nil) {
      self.updateDataSource()
    }
  }
  
  func updateDataSource() {
    let subViews = self.reactSubviews()
    if (subViews!.count == 0) {
        return;
    }
    var titles = [String]()
    for _ in subViews! {
      titles.append("test")
    }
    segmentedDataSource?.titles = titles;
    segmentedView?.defaultSelectedIndex = self.initialPage
    
    segmentedView?.reloadData()
  }
  
  func setupControllers() {
    segmentedView = JXSegmentedView()
    
    let subViews = self.reactSubviews()
    var titles = [String]()
    for subView in subViews! {
      titles.append("test")
    }
    
    //segmentedDataSource一定要通过属性强持有，不然会被释放掉
    segmentedDataSource = JXSegmentedTitleDataSource()
    //配置数据源相关配置属性
    segmentedDataSource!.titles = titles
//    segmentedDataSource!.isTitleColorGradientEnabled = true
    //配置指示器
//    let indicator = JXSegmentedIndicatorLineView()
//    indicator.indicatorWidth = 20
//    segmentedView!.indicators = [indicator]
    
    segmentedView!.defaultSelectedIndex = initialPage
    segmentedView!.dataSource = segmentedDataSource!
    
    segmentedView!.delegate = self
    
    self.addSubview(self.segmentedView!)
    segmentedView!.listContainer = listContainerView
//    segmentedView?.contentScrollView =
    self.addSubview(listContainerView)
    self.listContainerView.frame = self.bounds
    self.segmentedView!.layoutIfNeeded()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.segmentedView!.frame = CGRect(x: 0,y: 0,width: 0,height: 0)
    self.listContainerView.frame = self.bounds
  }
  
  init(eventDispatcher: RCTEventDispatcher?) {
    super.init(frame: CGRect.zero)
    self.eventDispatcher = eventDispatcher
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

extension JXSegmentedPageView: ReactNativePageView {
  func setPage(nextPageIndex: Int) {
    self.segmentedView?.selectItemAt(index: nextPageIndex);
    self.listContainerView?.didClickSelectedItem(at: nextPageIndex)
  }
}
