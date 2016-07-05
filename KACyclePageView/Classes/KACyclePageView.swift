//
//  KACyclePageView.swift
//  KACyclePageView
//
//  Created by ZhihuaZhang on 2016/06/21.
//  Copyright © 2016年 Kapps Inc. All rights reserved.
//

import UIKit

public protocol KACyclePageViewDataSource {
    
    func numberOfPages() -> Int
    func viewControllerForPageAtIndex(index: Int) -> UIViewController
    func titleForPageAtIndex(index: Int) -> String

    //TODO: setup by Config or delegate
    func colorForCurrentTitle() -> UIColor
    func colorForDefaultTitle() -> UIColor
    
}

let CountForCycle: Int = 1000

private struct UX {
    static let labelMargin: CGFloat = 8
}

public class KACyclePageView: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bottomBarView: UIView!
    @IBOutlet weak var bottomBarViewWidth: NSLayoutConstraint!
    @IBOutlet var bottomBarViewCenterH: NSLayoutConstraint!
    @IBOutlet var bottomBarViewLeft: NSLayoutConstraint!
    
    private var pageViewController: KAPageViewController!
    
    private let MinCycleCellCount = 4
    
    private var cellWidth: CGFloat {
        return view.frame.width / CGFloat(visibleCellCount)
    }
    
    private var collectionViewContentOffsetX: CGFloat = 0.0
    
    private var pageIndex: Int = 0
    private var headerIndex: Int = CountForCycle
    
    private var pageCount = 0
    
    private var shouldCycle: Bool {
        get {
            //TODO: can be false
            return true
        }
    }
    
    private var scrollPostition: UICollectionViewScrollPosition {
        get {
//            return pageCount > MinCycleCellCount ? .CenteredHorizontally : .None
            return .CenteredHorizontally
        }
    }
    
    private var visibleCellCount: Int {
        get {
            return min(MinCycleCellCount, pageCount)
        }
    }
    
    var dataSource: KACyclePageViewDataSource?
    
    //for launch
    var needUpdateBottomBarViewWidth = true
    
    //for after drag header
    var needScrollToCenter = false
    
    public class func cyclePageView(dataSource dataSource: AnyObject) -> KACyclePageView {
        let podBundle = NSBundle(forClass: self.classForCoder())
        let bundleURL = podBundle.URLForResource("KACyclePageView", withExtension: "bundle")!
        let bundle = NSBundle(URL: bundleURL)
        let storyboard = UIStoryboard(name: "KACyclePageView", bundle: bundle)
        let vc = storyboard.instantiateInitialViewController() as! KACyclePageView

        vc.dataSource = dataSource as? KACyclePageViewDataSource
        
        vc.pageCount = vc.dataSource!.numberOfPages()
        
        return vc
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        bottomBarViewLeft.active = false
        bottomBarViewCenterH.active = true
    }

    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let indexPath = NSIndexPath(forItem: headerIndex, inSection: 0)
        
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: scrollPostition, animated: false)
    }
    
    // MARK: - Navigation

    override public func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SeguePageView" {
            pageViewController = segue.destinationViewController as! KAPageViewController
            pageViewController.pageDelegate = self
            pageViewController.pageCount = pageCount
            pageViewController.pageDataSource = dataSource
        }
    }
    
    // MARK: - support
    
    private func updateIndex(index: Int) {
        if shouldCycle {
            headerIndex += (index - pageIndex)
            pageIndex = index

            let indexPath = NSIndexPath(forItem: headerIndex, inSection: 0)

            collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: false)
            collectionView.reloadData()
            
            collectionViewContentOffsetX = 0.0
        } else {
//            currentIndex = index
        }
    }

    private func scrollWithContentOffsetX(contentOffsetX: CGFloat) {
        
        if contentOffsetX == 0 {
            return
        }
        
        let currentIndexPath = NSIndexPath(forItem: headerIndex, inSection: 0)
        
        if self.collectionViewContentOffsetX == 0.0 {
            self.collectionViewContentOffsetX = self.collectionView.contentOffset.x
        }
        
        if let currentCell = self.collectionView.cellForItemAtIndexPath(currentIndexPath) as? TitleCell {
            
            let distance = currentCell.frame.width
            let scrollRate = contentOffsetX / self.view.frame.width
            let scroll = scrollRate * distance
            self.collectionView.contentOffset.x = self.collectionViewContentOffsetX + scroll
            
            let nextIndex = contentOffsetX > 0 ? headerIndex + 1 : headerIndex - 1
            let nextIndexPath = NSIndexPath(forItem: nextIndex, inSection: 0)

            guard let nextCell = collectionView.cellForItemAtIndexPath(nextIndexPath) as? TitleCell else {
                return
            }
            
            //update bar width
            bottomBarViewWidth.constant = currentCell.titleLabelWidthWithMargin + (nextCell.titleLabelWidthWithMargin - currentCell.titleLabelWidthWithMargin) * abs(scrollRate)
            
            guard let currentColor = dataSource?.colorForCurrentTitle(), defaultColor = dataSource?.colorForDefaultTitle() else {
                return
            }
            
            nextCell.titleLabel.textColor = colorForProgress(defaultColor, newColor: currentColor, progress: abs(scrollRate))
            currentCell.titleLabel.textColor = colorForProgress(currentColor, newColor: defaultColor, progress: abs(scrollRate))
        }
    }
    
    private func colorForProgress(oldColor: UIColor, newColor: UIColor, progress: CGFloat) -> UIColor {
        guard let old = oldColor.coreImageColor, new = newColor.coreImageColor else {
            return oldColor
        }
        
        let newR = (1 - progress) * old.red + progress * new.red
        let newG = (1 - progress) * old.green + progress * new.green
        let newB = (1 - progress) * old.blue + progress * new.blue
        
        return UIColor(red: newR, green: newG, blue: newB, alpha: 1.0)
    }
    
    private func needUpdateTitleColor(contentOffsetX: CGFloat) -> Bool {
        return contentOffsetX > view.frame.width / 2 || contentOffsetX < -view.frame.width / 2
    }

    private func moveBottomBar(toCell cell: TitleCell? = nil) {
        var targetCell: TitleCell? = cell
        if targetCell == nil {
            targetCell = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: headerIndex, inSection: 0)) as? TitleCell
        }
        
        if targetCell == nil {
            let cells = collectionView.visibleCells() as! [TitleCell]
            
            let c = cells.filter {
                if let indexPath = collectionView.indexPathForCell($0) {
                    return pageIndexFromHeaderIndex(indexPath.item) == pageIndex
                }
                
                return false
            }
            
            targetCell = c.first
        }
        
        guard let newCell = targetCell else {
            return
        }
        
        let rect = newCell.titleLabel.convertRect(newCell.titleLabel.bounds, toView: collectionView.superview)
    
        bottomBarViewCenterH.active = false
        bottomBarViewLeft.active = true
        
        if rect.origin.x > collectionView.frame.width {
            bottomBarViewLeft.constant = collectionView.frame.width
        } else if rect.origin.x < -cellWidth {
            bottomBarViewLeft.constant = -cellWidth
        } else {
            
            bottomBarViewLeft.constant = rect.origin.x - 8
        }
    }

    private func pageIndexFromHeaderIndex(index: Int) -> Int {
        let i = (index - CountForCycle) % pageCount
        
        if i < 0 {
            return i + pageCount
        }
        
        return i
    }
    
    
    private func scrollToPageIndex() {
        headerIndex = CountForCycle + pageIndex
        let indexPath = NSIndexPath(forItem: headerIndex, inSection: 0)
        
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: scrollPostition, animated: false)
    }
    
    // MARK: - UIScrollViewDelegate
    
    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        needScrollToCenter = true
    }
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if scrollView.dragging {
            moveBottomBar()
        }
    }
    
}

// MARK: - UICollection

extension KACyclePageView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = cellWidth
        
        return CGSizeMake(width, collectionView.frame.height)
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shouldCycle ? pageCount * CountForCycle * 2 : pageCount
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TitleCell", forIndexPath: indexPath) as! TitleCell
        
        let cycledIndex = pageIndexFromHeaderIndex(indexPath.item)
        
        let title = dataSource?.titleForPageAtIndex(cycledIndex)
        
        cell.titleLabel.text = title
        
        if needUpdateBottomBarViewWidth && cycledIndex == pageIndex {
            cell.titleLabel.sizeToFit()
            bottomBarViewWidth.constant = cell.titleLabel.frame.width + 2 * UX.labelMargin
            needUpdateBottomBarViewWidth = false
        }
        
        return cell
    }

    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let newPageIndex = pageIndexFromHeaderIndex(indexPath.item)
        
        if newPageIndex == pageIndex || pageViewController.dragging {
            return
        }
        
        let direction: UIPageViewControllerNavigationDirection = indexPath.item > headerIndex ? .Forward : .Reverse
        
        pageViewController.displayControllerWithIndex(newPageIndex, direction: direction, animated: true)

        if let visableCells = collectionView.visibleCells() as? [TitleCell] {
            let _ = visableCells.map {
                $0.titleLabel.textColor = dataSource?.colorForDefaultTitle()
            }
        }
        
        pageIndex = newPageIndex
        headerIndex = indexPath.item

        bottomBarViewLeft.active = false
        bottomBarViewCenterH.active = true
        
        let nextCell = collectionView.cellForItemAtIndexPath(indexPath) as! TitleCell
        bottomBarViewWidth.constant = nextCell.titleLabelWidthWithMargin
        
        nextCell.titleLabel.textColor = dataSource?.colorForCurrentTitle()
        
        UIView.animateWithDuration(0.3) {
            self.view.layoutIfNeeded()
        }

        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: true)
    }
    
    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let cycledIndex = pageIndexFromHeaderIndex(indexPath.item)
        
        (cell as? TitleCell)?.titleLabel.textColor = cycledIndex == pageIndex ? dataSource?.colorForCurrentTitle() : dataSource?.colorForDefaultTitle()
    }
    
}

// MARK: - KAPageViewControllerDelegate

extension KACyclePageView: KAPageViewControllerDelegate {
    
    func WillBeginDragging() {
        collectionView.scrollEnabled = false
        
        if !bottomBarViewCenterH.active {
            bottomBarViewLeft.active = false
            bottomBarViewCenterH.active = true
        }
        
        if needScrollToCenter {
            scrollToPageIndex()
            
            needScrollToCenter = false
        }
    }
    
    func didEndDragging() {
        print(#function)
        
        collectionView.scrollEnabled = true
    }
    
    func didChangeToIndex(index: Int) {
        updateIndex(index)
    }
    
    func didScrolledWithContentOffsetX(x: CGFloat) {
        if shouldCycle {
            scrollWithContentOffsetX(x)
        } else {
//            updateIndicatorView(x)
        }
    }

}

// MARK: - TitleCell

class TitleCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    
    var titleLabelWidthWithMargin: CGFloat {
        return titleLabel.frame.width + 2 * UX.labelMargin
    }
}

extension UIColor {
    
    var coreImageColor: CoreImage.CIColor? {
        return CoreImage.CIColor(color: self)
    }
    
}
