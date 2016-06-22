//
//  KACyclePageView.swift
//  KACyclePageView
//
//  Created by ZhihuaZhang on 2016/06/21.
//  Copyright © 2016年 Kapps Inc. All rights reserved.
//

import UIKit

public class KACyclePageView: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    private var pageViewControllers = [UIViewController]()
    private var titles = [String]()
    
    private var pageViewController: KAPageViewController!
    
    private struct UX {
        static let CellCount = 4
    }
    
    private var cellWidth: CGFloat {
        return view.frame.width / CGFloat(visibleCellCount)
    }
    
    private var collectionViewContentOffsetX: CGFloat = 0.0
    
    private var currentIndex: Int = 0

    //TODO: change this
    private var shouldCycle: Bool {
        get {
            return titles.count > 4
        }
    }
    
    private var scrollPostition: UICollectionViewScrollPosition {
        get {
            return titles.count > 4 ? .CenteredHorizontally : .None
        }
    }
    
    private var visibleCellCount: Int {
        get {
            return min(UX.CellCount, titles.count)
        }
    }
    
    public class func cyclePageView(viewControllers: [UIViewController], titles: [String]) -> KACyclePageView {
        let podBundle = NSBundle(forClass: self.classForCoder())
        let bundleURL = podBundle.URLForResource("KACyclePageView", withExtension: "bundle")!
        let bundle = NSBundle(URL: bundleURL)
        let storyboard = UIStoryboard(name: "KACyclePageView", bundle: bundle)
        let vc = storyboard.instantiateInitialViewController() as! KACyclePageView
        vc.pageViewControllers = viewControllers
        vc.titles = titles
        
        return vc
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        currentIndex = shouldCycle ? titles.count : 0
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
            pageViewController.pageViewControllers = pageViewControllers
        }
    }
    
    
    private func updateCurrentIndex(index: Int) {
        if shouldCycle {
            currentIndex = index + titles.count
            
            if currentIndex + visibleCellCount / 2 >= (2 * titles.count - 1) {
                currentIndex -= titles.count
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
        if showIndex >= titles.count {
            showIndex = 0
        }
        
        if showIndex < 0 {
            showIndex = titles.count - 1
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
        return shouldCycle ? titles.count * 2 : titles.count
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TitleCell", forIndexPath: indexPath) as! TitleCell
        
        let cycledIndex = indexPath.item % titles.count
        
        let title = titles[cycledIndex]
        
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

