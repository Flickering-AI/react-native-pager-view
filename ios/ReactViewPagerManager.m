#import <React/RCTViewManager.h>

@interface RCT_EXTERN_REMAP_MODULE(RNCViewPager, ReactViewPagerManager, RCTViewManager)

RCT_EXPORT_VIEW_PROPERTY(color, NSString)

RCT_EXPORT_VIEW_PROPERTY(initialPage, NSInteger)
//RCT_EXPORT_VIEW_PROPERTY(pageMargin, NSInteger)

//RCT_EXPORT_VIEW_PROPERTY(transitionStyle, UIPageViewControllerTransitionStyle)
//RCT_EXPORT_VIEW_PROPERTY(orientation, UIPageViewControllerNavigationOrientation)
RCT_EXPORT_VIEW_PROPERTY(onPageSelected, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onPageScroll, RCTDirectEventBlock)
//RCT_EXPORT_VIEW_PROPERTY(onPageScrollStateChanged, RCTDirectEventBlock)
//RCT_EXPORT_VIEW_PROPERTY(overdrag, BOOL)
//RCT_EXPORT_VIEW_PROPERTY(layoutDirection, NSString)

RCT_EXTERN_METHOD(setPage:(nonnull NSNumber *)reactTag index: (nonnull NSNumber *)index)

@end
