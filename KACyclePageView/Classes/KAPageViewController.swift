//
//  KAPageViewController.swift
//  KACyclePageView
//
//  Created by ZhihuaZhang on 2016/06/21.
//  Copyright © 2016年 Kapps Inc. All rights reserved.
//

import UIKit

protocol KAPageViewControllerDelegate {

    func didChangeToIndex(index: Int)
    func didScrolledWithContentOffsetX(x: CGFloat)

}

class KAPageViewController: UIPageViewController {

    var pageViewControllers = [UIViewController]()
    
    private var beforeIndex: Int = 0
    
    private var currentIndex: Int? {
        guard let viewController = viewControllers?.first else {
            return nil
        }
        return pageViewControllers.indexOf(viewController)
    }    
    
    var pageDelegate: KAPageViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self
        
        setupScrollView()
        setViewControllers([pageViewControllers[0]], direction: .Forward, animated: false, completion: nil)
        
        
    }

    private func setupScrollView() {
        let scrollView = view.subviews.flatMap { $0 as? UIScrollView }.first
        scrollView?.scrollsToTop = false
        scrollView?.delegate = self
    }
    
    // MARK: - Support
    
    private func nextViewController(current: UIViewController, isAfter: Bool) -> UIViewController? {
        if pageViewControllers.count < 2 {
            return nil
        }
        
        guard var index = pageViewControllers.indexOf(current) else {
            return nil
        }
        
        index = isAfter ? index + 1 : index - 1
        
        if index < 0 {
            index = pageViewControllers.count - 1
        } else if index == pageViewControllers.count {
            index = 0
        }
        
        if index >= 0 && index < pageViewControllers.count {
            return pageViewControllers[index]
        }
        return nil
    }
    
}

// MARK: - UIScrollViewDelegate

extension KAPageViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let scrollOffsetX = scrollView.contentOffset.x - view.frame.width
        
        pageDelegate?.didScrolledWithContentOffsetX(scrollOffsetX)
    }
    
}


// MARK: - UIPageViewController

extension KAPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentIndex = currentIndex where currentIndex < pageViewControllers.count {
            
            pageDelegate?.didChangeToIndex(currentIndex)
            
            beforeIndex = currentIndex
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        return nextViewController(viewController, isAfter: true)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        return nextViewController(viewController, isAfter: false)
    }

}
