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
//    func bottomBarViewWidthAtIndex(index: Int) -> CGFloat
}

let CountForCycle: Int = 1000

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
    
    dynamic private var pageIndex: Int = 0
    private var headerIndex: Int = CountForCycle
    
    private var pageCount = 0
    
    private var shouldCycle: Bool {
        get {
//            return pageCount > MinCycleCellCount
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
        
//        collectionView.scrollEnabled = pageCount > 4
    }

    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let indexPath = NSIndexPath(forItem: headerIndex, inSection: 0)
        
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: scrollPostition, animated: false)
        
//        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! TitleCell
//        bottomBarViewWidth.constant = cell.titleLabel.frame.width + 16
        
//        updateIndicatorView()
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
    
    
    private func updateIndex(index: Int) {
        if shouldCycle {
            headerIndex += (index - pageIndex)
            pageIndex = index

            let indexPath = NSIndexPath(forItem: headerIndex, inSection: 0)
            
            print(indexPath)
            collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: false)
            collectionView.reloadData()
//            if currentIndex + visibleCellCount / 2 >= (2 * pageCount - 1) {
//                currentIndex -= pageCount
//            }
//            
//            let indexPath = NSIndexPath(forItem: currentIndex, inSection: 0)
//            
//            collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: scrollPostition, animated: false)
            
            collectionViewContentOffsetX = 0.0
        } else {
//            currentIndex = index
        }
    }

    private func scrollWithContentOffsetX(contentOffsetX: CGFloat) {
        
        if contentOffsetX == 0 {
            return
        }
        
        
//        let nextIndex = self.currentIndex
//        
        let currentIndexPath = NSIndexPath(forItem: headerIndex, inSection: 0)
//        let nextIndexPath = NSIndexPath(forItem: nextIndex, inSection: 0)
//        
//        
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
            let nextCell = collectionView.cellForItemAtIndexPath(nextIndexPath) as? TitleCell

            if let nextCell = nextCell {
                bottomBarViewWidth.constant = currentCell.titleLabelWidthWidthMargin + (nextCell.titleLabelWidthWidthMargin - currentCell.titleLabelWidthWidthMargin) * abs(scrollRate)
            }
            
        }
        
        
        
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
    
    func moveBottomBar(toCell cell: TitleCell? = nil) {
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
        
//        guard let newCell = targetCell else {
//        
//            
//            let cells = collectionView.visibleCells() as! [TitleCell]
//            
//            let c = cells.filter {
//                if let indexPath = collectionView.indexPathForCell($0) {
//                return pageIndexFromHeaderIndex(indexPath.item) == pageIndex
//                }
//                
//                return false
//            }
//            
//            targetCell = c.first
//            return
//        }
        
            let rect = newCell.titleLabel.convertRect(newCell.titleLabel.bounds, toView: collectionView.superview)
            print(rect)
            
            bottomBarViewCenterH.active = false
            bottomBarViewLeft.active = true
            
            if rect.origin.x > collectionView.frame.width {
                bottomBarViewLeft.constant = collectionView.frame.width
            } else if rect.origin.x < -cellWidth {
                bottomBarViewLeft.constant = -cellWidth
            } else {
                
                bottomBarViewLeft.constant = rect.origin.x - 8
            }
            //                if bottomBarViewCenterH.active {
            //                    bottomBarViewCenterH.active = false
            //                }
            //
            //                let centerWithCell = NSLayoutConstraint(item: bottomBarView, attribute: .CenterX, relatedBy: .Equal, toItem: currentCell, attribute: .CenterX, multiplier: 1, constant: 0)
            //                centerWithCell.active = true
    }
    
//    private func indexForPage(page: Int) -> Int {
//        return CountForCycle / 2 + page
//    }
    
//    private func updateIndicatorView(offsetX: CGFloat = 0) {
//        let cells = collectionView.visibleCells() as! [TitleCell]
//        for cell in cells {
//            cell.bottomView.hidden = !showBottomView(cell, offsetX: offsetX)
//        }
//    }
    
//    private func showBottomView(cell: TitleCell, offsetX: CGFloat = 0) -> Bool {
//        if shouldCycle {
//            let minX = collectionView.bounds.origin.x + cell.frame.width
//            let maxX = collectionView.bounds.origin.x + 2*cell.frame.width
//            
//            if cell.frame.origin.x > minX && cell.frame.origin.x < maxX {
//                return true
//            }
//            
//            return false
//        }
//        
//        var showIndex = currentIndex
//        
//        if offsetX > view.frame.width / 2 {
//            showIndex += 1
//        }
//        
//        if offsetX < 0 && offsetX < -view.frame.width / 2 {
//            showIndex -= 1
//        }
//        if showIndex >= pageCount {
//            showIndex = 0
//        }
//        
//        if showIndex < 0 {
//            showIndex = pageCount - 1
//        }
//        
//        return collectionView.indexPathForCell(cell)?.item == showIndex
//    }
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
        print(indexPath)
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TitleCell", forIndexPath: indexPath) as! TitleCell
        
        let cycledIndex = pageIndexFromHeaderIndex(indexPath.item)
        
        let title = dataSource?.titleForPageAtIndex(cycledIndex)
        
        cell.titleLabel.text = title
        
//        cell.bottomView.hidden = !showBottomView(cell)
        
        if needUpdateBottomBarViewWidth && cycledIndex == pageIndex {
            cell.titleLabel.sizeToFit()
            bottomBarViewWidth.constant = cell.titleLabel.frame.width + 16
            needUpdateBottomBarViewWidth = false
        }
        
        return cell
    }
    
    func pageIndexFromHeaderIndex(index: Int) -> Int {
        let i = (index - CountForCycle) % pageCount
        
        if i < 0 {
            return i + pageCount
        }
        
        return i
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        bottomBarViewCenterH.active = true
        bottomBarViewLeft.active = false
        let nextCell = collectionView.cellForItemAtIndexPath(indexPath) as! TitleCell
        bottomBarViewWidth.constant = nextCell.titleLabelWidthWidthMargin
        
        UIView.animateWithDuration(0.3) {
            self.view.layoutIfNeeded()
        }

        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: true)
        
        let newPageIndex = pageIndexFromHeaderIndex(indexPath.item)
        
        if newPageIndex == pageIndex || pageViewController.dragging {
            return
        }
        
        let direction: UIPageViewControllerNavigationDirection = indexPath.item > headerIndex ? .Forward : .Reverse
        
        pageViewController.displayControllerWithIndex(newPageIndex, direction: direction, animated: true)
        
        pageIndex = newPageIndex
        headerIndex = indexPath.item
    }
    
    func scrollToPageIndex() {
        headerIndex = CountForCycle + pageIndex
        let indexPath = NSIndexPath(forItem: headerIndex, inSection: 0)
        
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: scrollPostition, animated: false)
    }
}

// MARK: - KAPageViewControllerDelegate

extension KACyclePageView: KAPageViewControllerDelegate {
    
    func WillBeginDragging() {
        print(#function)
        
        if needScrollToCenter {
            bottomBarViewCenterH.active = true
            bottomBarViewLeft.active = false
            
            scrollToPageIndex()
            
            needScrollToCenter = false
        }

    }
    
    func didChangeToIndex(index: Int) {
        updateIndex(index)
    }
    
    func didScrolledWithContentOffsetX(x: CGFloat) {
        print(#function)
    
        if shouldCycle {
            scrollWithContentOffsetX(x)
        } else {
//            updateIndicatorView(x)
        }
    }
    
//    func updateBottomBarViewWidth(x: CGFloat) {
//        
//        if x > 0 {
//            let nextIndexPath = NSIndexPath(forItem: headerIndex + 1, inSection: 0)
//            let nextCell = collectionView.cellForItemAtIndexPath(nextIndexPath) as! TitleCell
//            print("next: " + nextCell.titleLabel.text!)
//            
//            
//        }
//    }
}

class TitleCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
 
    private struct UX {
        static let labelMargin: CGFloat = 16
    }
    
    var titleLabelWidthWidthMargin: CGFloat {
        return titleLabel.frame.width + UX.labelMargin
    }
}

