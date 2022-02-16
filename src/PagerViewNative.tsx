import type { ReactElement } from 'react';
import { HostComponent, requireNativeComponent, UIManager } from 'react-native';
import type { PagerViewProps } from './types';

const VIEW_MANAGER_NAME = 'RNCViewPager';

const VIEW_MANAGER_NAME2 = 'JXSegmentedPageView';

interface PagerViewViewManagerType extends HostComponent<PagerViewProps> {
  getInnerViewNode(): ReactElement;
}

export const PagerViewViewManager = requireNativeComponent(
  VIEW_MANAGER_NAME
) as PagerViewViewManagerType;

export const JXSegmentedPageViewManager = requireNativeComponent(
  VIEW_MANAGER_NAME2
) as PagerViewViewManagerType;

export function getViewManagerConfig(viewManagerName = VIEW_MANAGER_NAME) {
  return UIManager.getViewManagerConfig(viewManagerName);
}
