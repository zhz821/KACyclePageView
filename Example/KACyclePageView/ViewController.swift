//
//  ViewController.swift
//  KACyclePageView
//
//  Created by zhihuazhang on 06/21/2016.
//  Copyright © 2016年 Kapps Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var contentLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit{
        print(#function)
    }
}

