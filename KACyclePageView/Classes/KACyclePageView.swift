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
    
}

public class KACyclePageView: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var pageViewController: KAPageViewController!
    
    private let MinCycleCellCount = 4
    
    private var cellWidth: CGFloat {
        return view.frame.width / CGFloat(visibleCellCount)
    }
    
    private var collectionViewContentOffsetX: CGFloat = 0.0
    
    private var currentIndex: Int = 0

    private var pageCount = 0
    
    private var shouldCycle: Bool {
        get {
            return pageCount > MinCycleCellCount
        }
    }
    
    private var scrollPostition: UICollectionViewScrollPosition {
        get {
            return pageCount > MinCycleCellCount ? .CenteredHorizontally : .None
        }
    }
    
    private var visibleCellCount: Int {
        get {
            return min(MinCycleCellCount, pageCount)
        }
    }
    
    var dataSource: KACyclePageViewDataSource?
    
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

        currentIndex = shouldCycle ? pageCount : 0
    }

    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let indexPath = NSIndexPath(forItem: currentIndex, inSection: 0)
        
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: scrollPostition, animated: false)
        
        updateIndicatorView()
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
    
    
    private func updateCurrentIndex(index: Int) {
        if shouldCycle {
            currentIndex = index + pageCount
            
            if currentIndex + visibleCellCount / 2 >= (2 * pageCount - 1) {
                currentIndex -= pageCount
            }
            
            let indexPath = NSIndexPath(forItem: currentIndex, inSection: 0)
            
            collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: scrollPostition, animated: false)
            
            collectionViewContentOffsetX = 0.0
        } else {
            currentIndex = index
        }
    }

    private func scrollWithContentOffsetX(contentOffsetX: CGFloat) {
        let nextIndex = self.currentIndex
        
        let currentIndexPath = NSIndexPath(forItem: self.currentIndex, inSection: 0)
        let nextIndexPath = NSIndexPath(forItem: nextIndex, inSection: 0)
        
        
        if self.collectionViewContentOffsetX == 0.0 {
            self.collectionViewContentOffsetX = self.collectionView.contentOffset.x
        }
        
        if let currentCell = self.collectionView.cellForItemAtIndexPath(currentIndexPath) as? TitleCell, nextCell = self.collectionView.cellForItemAtIndexPath(nextIndexPath) as? TitleCell {
            
            let distance = (currentCell.frame.width / 2.0) + (nextCell.frame.width / 2.0)
            let scrollRate = contentOffsetX / self.view.frame.width
            let scroll = scrollRate * distance
            self.collectionView.contentOffset.x = self.collectionViewContentOffsetX + scroll
        }
    }
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        updateIndicatorView()
    }
    
    private func updateIndicatorView(offsetX: CGFloat = 0) {
        let cells = collectionView.visibleCells() as! [TitleCell]
        for cell in cells {
            cell.bottomView.hidden = !showBottomView(cell, offsetX: offsetX)
        }
    }
    
    private func showBottomView(cell: TitleCell, offsetX: CGFloat = 0) -> Bool {
        if shouldCycle {
            let minX = collectionView.bounds.origin.x + cell.frame.width
            let maxX = collectionView.bounds.origin.x + 2*cell.frame.width
            
            if cell.frame.origin.x > minX && cell.frame.origin.x < maxX {
                return true
            }
            
            return false
        }
        
        var showIndex = currentIndex
        
        if offsetX > view.frame.width / 2 {
            showIndex += 1
        }
        
        if offsetX < 0 && offsetX < -view.frame.width / 2 {
            showIndex -= 1
        }
        if showIndex >= pageCount {
            showIndex = 0
        }
        
        if showIndex < 0 {
            showIndex = pageCount - 1
        }
        
        return collectionView.indexPathForCell(cell)?.item == showIndex
    }
}

extension KACyclePageView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = cellWidth
        
        return CGSizeMake(width, collectionView.frame.height)
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shouldCycle ? pageCount * 2 : pageCount
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TitleCell", forIndexPath: indexPath) as! TitleCell
        
        let cycledIndex = indexPath.item % pageCount
        
        let title = dataSource?.titleForPageAtIndex(cycledIndex)
        
        cell.titleLabel.text = title
        
        cell.bottomView.hidden = !showBottomView(cell)
        
        return cell
    }    
}

extension KACyclePageView: KAPageViewControllerDelegate {
    
    func didChangeToIndex(index: Int) {
        updateCurrentIndex(index)
    }
    
    func didScrolledWithContentOffsetX(x: CGFloat) {
        if shouldCycle {
            scrollWithContentOffsetX(x)
        } else {
            updateIndicatorView(x)
        }
    }
}

class TitleCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    
}

