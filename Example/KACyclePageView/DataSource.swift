//
//  DataSource.swift
//  KACyclePageView
//
//  Created by 張志華 on 2016/06/22.
//  Copyright © 2016年 CocoaPods. All rights reserved.
//

import UIKit
import KACyclePageView

//let titles = ["M", "Tu", "Wed", "Thur", "Frida", "Saturday", "Sunday"]
//let titles = ["M", "Tu", "Wed", "Thur", "Frida"]
let titles = ["トップ", "遊び", "学び", "ファッション"]
//let titles = ["M", "Tu", "Wed"]
//let titles = ["M", "Tu"]
//let titles = ["M"]

class DataSource: NSObject {

}

extension DataSource: KACyclePageViewDataSource {
    
    func numberOfPages() -> Int {
        return titles.count
    }
    
    func viewControllerForPageAtIndex(index: Int) -> UIViewController {
        let vc = createViewControllerWithIdentifier(nil, storyboardName: "Main") as! ViewController
        vc.view.backgroundColor = UIColor.randomColor()
        vc.contentLabel.text = titles[index]
        return vc
    }
    
    func titleForPageAtIndex(index: Int) -> String {
        return titles[index]
    }
    
}

func createViewControllerWithIdentifier(id: String?, storyboardName: String) -> UIViewController {
    let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
    if let id = id {
        return storyboard.instantiateViewControllerWithIdentifier(id)
    }
    
    return storyboard.instantiateInitialViewController()!
}

extension UIColor {
    
    class func randomColor() -> UIColor {
        let randomRed:CGFloat = CGFloat(drand48())
        
        let randomGreen:CGFloat = CGFloat(drand48())
        
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
}