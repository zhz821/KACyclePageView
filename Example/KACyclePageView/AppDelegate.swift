//
//  AppDelegate.swift
//  KACyclePageView
//
//  Created by zhihuazhang on 06/21/2016.
//  Copyright © 2016年 Kapps Inc. All rights reserved.
//

import UIKit
import KACyclePageView

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let vc = KACyclePageView.cyclePageView(dataSource: DataSource())
        
        window?.rootViewController = vc
        
        return true
    }

}
