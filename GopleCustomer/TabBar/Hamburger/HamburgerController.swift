//
//  HamburgerController.swift
//  GopleCustomer
//
//  Created by 김민주 on 2017. 12. 18..
//  Copyright © 2017년 김민주. All rights reserved.
//

import UIKit

class HamburgerController: UIViewController {
    
    static var selectIdx: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = mainColor

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    @IBAction func showHome(_ sender: UIButton) {
        
        if let tabbarVC = self.presentingViewController as? TabBarController {
            tabbarVC.nextIdx = 0
            
        } else {
            NewWebViewController.isDismiss = true
            HamburgerController.selectIdx = 0
        }
        UIApplication.shared.statusBarStyle = .default
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func showNews(_ sender: UIButton) {
        
        if let tabbarVC = self.presentingViewController as? TabBarController {
            tabbarVC.nextIdx = 1

        } else {
            NewWebViewController.isDismiss = true
            HamburgerController.selectIdx = 1
        }
        UIApplication.shared.statusBarStyle = .default
        self.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func showSale(_ sender: UIButton) {
        
        if let tabbarVC = self.presentingViewController as? TabBarController {
            tabbarVC.nextIdx = 2
            
        } else {
            NewWebViewController.isDismiss = true
            HamburgerController.selectIdx = 2
        }
        UIApplication.shared.statusBarStyle = .default
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showBookmark(_ sender: UIButton) {

        if let tabbarVC = self.presentingViewController as? TabBarController {
            tabbarVC.nextIdx = 3
            
        } else {
            NewWebViewController.isDismiss = true
            HamburgerController.selectIdx = 3
        }
        UIApplication.shared.statusBarStyle = .default
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showMypage(_ sender: UIButton) {
        
        if let tabbarVC = self.presentingViewController as? TabBarController {
            tabbarVC.nextIdx = 4
            
        }  else {
            NewWebViewController.isDismiss = true
            HamburgerController.selectIdx = 4
        }
        UIApplication.shared.statusBarStyle = .default
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneBtn(_ sender: UIButton) {
        if let tabbarVC = self.presentingViewController as? TabBarController {
            tabbarVC.nextIdx = HamburgerController.selectIdx
        }
        UIApplication.shared.statusBarStyle = .default
        self.dismiss(animated: true, completion: nil)
    }
    
}
