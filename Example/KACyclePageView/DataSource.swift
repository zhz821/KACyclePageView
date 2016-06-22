//
//  DataSource.swift
//  KACyclePageView
//
//  Created by 張志華 on 2016/06/22.
//  Copyright © 2016年 CocoaPods. All rights reserved.
//

import UIKit
import KACyclePageView

let titles = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

class DataSource: NSObject {

}

extension DataSource: KACyclePageViewDataSource {
    
    func numberOfPages() -> Int {
        return titles.count
    }
    
    func viewControllerForPageAtIndex(index: Int) -> UIViewController {
        let vc = ViewController()
        vc.view.backgroundColor = UIColor.randomColor()
        return vc
    }
    
    func titleForPageAtIndex(index: Int) -> String {
        return titles[index]
    }
    
}

extension UIColor {
    
    class func randomColor() -> UIColor {
        let randomRed:CGFloat = CGFloat(drand48())
        
        let randomGreen:CGFloat = CGFloat(drand48())
        
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
}