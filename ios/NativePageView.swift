class NativePageView : UIView {
  var pageViewController: UIPageViewController?;
  var eventDispatcher: RCTEventDispatcher?;
  var coalescingKey: UInt16 = 0
  var willTransitionIndexs: [String: Int] = ["from": 0, "to": 0];
  var lastContentOffsetX: CGFloat = -1;
  @objc var initialPage: Int = 0;
  @objc var loop: Bool = false;
  @objc var onPageSelected: RCTDirectEventBlock?
  @objc var onPageScroll: RCTDirectEventBlock?
  @objc var onPageScrollStateChanged: RCTDirectEventBlock?
  
  override func didMoveToWindow() {
    super.didMoveToWindow()
    if ((self.pageViewController == nil) && self.reactViewController() != nil) {
      self.setupControllers()
    }
  }
  
  override func didMoveToSuperview() {
    super.didMoveToSuperview()
    if ((self.pageViewController == nil) && self.reactViewController() != nil) {
      self.setupControllers()
    }
    
  }
  
  override func didUpdateReactSubviews() {
    if ((self.pageViewController == nil) && self.reactViewController() != nil) {
      self.setupControllers()
    } else if (self.pageViewController != nil) {
      self.updateDataSource()
    }
  }
  
  var sortedCachedViewControllers: [PageViewItemViewController] = [];
  func updateDataSource() {
    let subViews = self.reactSubviews()
    if (subViews!.count == 0) {
        return;
    }
  }
  
  func setupControllers() {
    self.pageViewController = UIPageViewController(transitionStyle: UIPageViewController.TransitionStyle.scroll, navigationOrientation: UIPageViewController.NavigationOrientation.horizontal)
    
    for (index, subView) in self.reactSubviews().enumerated() {
      let viewController = PageViewItemViewController()
      viewController.view = subView
      viewController.index = index
      if (index != 0) {
        viewController.before = sortedCachedViewControllers[index-1]
      }
      sortedCachedViewControllers.append(viewController)
    }
    linkControllers()
    
    for subview in pageViewController!.view.subviews {
      let maybeScrollView = subview as? UIScrollView
        if(maybeScrollView != nil){
          maybeScrollView!.delegate = self;
//          maybeScrollView!.keyboardDismissMode = _dismissKeyboard;
          maybeScrollView!.delaysContentTouches = false;
        }
    }
    
    self.pageViewController!.delegate = self
    self.pageViewController!.dataSource = self
    
    self.addSubview(self.pageViewController!.view)
    self.pageViewController!.view.layoutIfNeeded()
    self.pageViewController?.setViewControllers([sortedCachedViewControllers[initialPage]], direction: UIPageViewController.NavigationDirection.forward, animated: false, completion: { isFinished in
      
    })
  }
  
  func linkControllers() {
    for (index, _) in sortedCachedViewControllers.enumerated() {
      if (index != sortedCachedViewControllers.count - 1) {
        sortedCachedViewControllers[index].after = sortedCachedViewControllers[index+1];
      }
    }
    if (loop) {
      sortedCachedViewControllers[sortedCachedViewControllers.count - 1].after = sortedCachedViewControllers[0];
      sortedCachedViewControllers[0].before = sortedCachedViewControllers[sortedCachedViewControllers.count - 1];
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.pageViewController?.view.frame = self.bounds
  }
  
  init(eventDispatcher: RCTEventDispatcher?) {
    super.init(frame: CGRect.zero)
    self.eventDispatcher = eventDispatcher
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension NativePageView: UIPageViewControllerDelegate {
  func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
    let currentIndex = (pageViewController.viewControllers![0] as! PageViewItemViewController).index!
    let nextIndex = (pendingViewControllers[0] as! PageViewItemViewController).index!
    willTransitionIndexs["from"] = currentIndex
    willTransitionIndexs["to"] = nextIndex
//#if DEBUG
//    print("willTransitionTo: \((pendingViewControllers[0] as! PageViewItemViewController).index!), count: \(pendingViewControllers.count)")
//#endif
    
//    for subview in pageViewController.view.subviews {
//      let maybeScrollView = subview as? UIScrollView
//        if(maybeScrollView != nil){
//          maybeScrollView?.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
//        }
//    }
    
  }
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
//#if DEBUG
//    print("transitionCompleted finished: \(finished)")
//#endif
    if (finished) {
      let currentIndex = (pageViewController.viewControllers![0] as! PageViewItemViewController).index!
      willTransitionIndexs["from"] = currentIndex
      self.eventDispatcher!.send(RCTOnPageSelected(reactTag: self.reactTag, position: NSNumber(value: currentIndex), coalescingKey: coalescingKey))
      coalescingKey += 1
    }
  }
}

extension NativePageView: UIPageViewControllerDataSource {
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
//    #if DEBUG
//    print("viewControllerBefore: \((viewController as! PageViewItemViewController).index)")
//    #endif
    return (viewController as! PageViewItemViewController).before
  }
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
//    #if DEBUG
//    print("viewControllerAfter: \((viewController as! PageViewItemViewController).index)")
//    #endif
    return (viewController as! PageViewItemViewController).after
  }
}

extension NativePageView: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if (lastContentOffsetX == -1) {
      lastContentOffsetX = scrollView.contentOffset.x
      return
    }
    let currentViewControllers = self.pageViewController!.viewControllers!
    let currentIndex = Int((currentViewControllers.count - 1) / 2)
    let currenController = currentViewControllers[currentIndex] as! PageViewItemViewController
    let position = currenController.index!
    let offsetPercent = (scrollView.contentOffset.x / scrollView.frame.width).truncatingRemainder(dividingBy: 1)
    let from = willTransitionIndexs["from"]!
    let to = willTransitionIndexs["to"]!
    var leftIndex = from > to ? to : from
    if (loop) {
      if (from == 0 && to == sortedCachedViewControllers.count - 1) {
        leftIndex = sortedCachedViewControllers.count - 1
      }
      if (from == sortedCachedViewControllers.count - 1 && to == 0) {
        leftIndex = sortedCachedViewControllers.count - 1
      }
    }
//    #if DEBUG
//    print("contentOffset.x: \(scrollView.contentOffset.x), frame.width: \(scrollView.frame.width), offsetPercent: \(offsetPercent), position: \(position), leftIndex: \(leftIndex)")
//    #endif
    self.eventDispatcher!.send(RCTOnPageScrollEvent(reactTag: self.reactTag, position: NSNumber(value: leftIndex), offset: NSNumber(value: offsetPercent.truncatingRemainder(dividingBy: 1))));
  }
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    lastContentOffsetX = -1
    self.eventDispatcher!.send(RCTOnPageScrollStateChanged(reactTag: self.reactTag, state: "dragging", coalescingKey: coalescingKey));
    coalescingKey += 1
  }
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    self.eventDispatcher!.send(RCTOnPageScrollStateChanged(reactTag: self.reactTag, state: "settling", coalescingKey: coalescingKey));
    coalescingKey += 1
  }
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    self.eventDispatcher!.send(RCTOnPageScrollStateChanged(reactTag: self.reactTag, state: "idle", coalescingKey: coalescingKey))
    coalescingKey += 1
  }
}

extension NativePageView: ReactNativePageView {
  func setPage(nextPageIndex: Int) {
    if (self.pageViewController == nil) {
      return;
    }
    if (nextPageIndex < 0 || self.sortedCachedViewControllers.count <= nextPageIndex) {
      return
    }
    let currentViewControllers = self.pageViewController!.viewControllers!
    let currentViewController = self.pageViewController!.viewControllers![Int((currentViewControllers.count - 1) / 2)] as! PageViewItemViewController
    let currentViewControllerIndex = currentViewController.index!
    // flush
//    let newPageViewItemViewController = PageViewItemViewController()
//    sortedCachedViewControllers[nextPageIndex].view.removeFromSuperview()
//    sortedCachedViewControllers[nextPageIndex].view = nil
//    newPageViewItemViewController.view = self.reactSubviews()[nextPageIndex]
//    newPageViewItemViewController.index = nextPageIndex
//    sortedCachedViewControllers[nextPageIndex] = newPageViewItemViewController
//    linkControllers()
    
    var navigationDirection = currentViewControllerIndex > nextPageIndex ? UIPageViewController.NavigationDirection.reverse : UIPageViewController.NavigationDirection.forward
    if (loop) {
      if (currentViewControllerIndex == sortedCachedViewControllers.count - 1 && nextPageIndex == 0) {
        navigationDirection = UIPageViewController.NavigationDirection.forward
      } else if (currentViewControllerIndex == 0 && nextPageIndex == sortedCachedViewControllers.count - 1) {
        navigationDirection = UIPageViewController.NavigationDirection.reverse
      }
    }
    willTransitionIndexs["from"] = currentViewControllerIndex
    willTransitionIndexs["to"] = nextPageIndex
    pageViewController?.setViewControllers([sortedCachedViewControllers[nextPageIndex]], direction: navigationDirection, animated: true, completion: { finished in
//#if DEBUG
//      print("setPage finished: \(finished)")
//#endif
      if (finished) {
        let currentIndex = (self.pageViewController!.viewControllers![0] as! PageViewItemViewController).index!
        self.willTransitionIndexs["from"] = currentIndex
        self.eventDispatcher!.send(RCTOnPageSelected(reactTag: self.reactTag, position: NSNumber(value: currentIndex), coalescingKey: self.coalescingKey))
        self.coalescingKey += 1
      }
    })
  }
}

class PageViewItemViewController: UIViewController {
  public var after: PageViewItemViewController?;
  public var before: PageViewItemViewController?;
  public var index: Int?;
}
