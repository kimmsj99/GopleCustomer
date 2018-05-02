//
//  NavigationController.swift
//  GopleCustomer
//
//  Created by 김민주 on 2017. 11. 30..
//  Copyright © 2017년 김민주. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = UIColor.white
        
        var tmpView = UIView()
        
        if UIScreen.main.nativeBounds.height == 2436 {
            tmpView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 44.0 ))
            tmpView.backgroundColor = UIColor.white
            self.view.addSubview(tmpView)
        } else {
            tmpView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 20.0 ))
            tmpView.backgroundColor = UIColor.white
            self.view.addSubview(tmpView)
        }
        
        navigationBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.height, height: 59)

        // Do any additional setup after loading the view.
    }

}
