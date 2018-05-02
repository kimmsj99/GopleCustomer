//
//  HowViewController.swift
//  GopleCustomer
//
//  Created by 김민주 on 2018. 1. 8..
//  Copyright © 2018년 김민주. All rights reserved.
//

import UIKit
import WebKit

class HowViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var startBtn: UIButton!
    
    var contentWidth: CGFloat = 0.0
    
    var imageView = UIImageView()
    var images = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        gradationButton(startBtn)
        
        UserDefaults.standard.set("이용방법", forKey: "how")
        
        if images.count == 0 {
            for i in 0..<10 {
                images.append(UIImage(named: "how_\(String(i+1))")!)
                imageView = UIImageView(image: images[i])
                
                let xCoordinate = self.view.frame.width * CGFloat(i)
                contentWidth += view.frame.width
                
                scrollView.addSubview(imageView)
                
                if phoneHeight != iphoneX {
                    imageView.frame = CGRect(x: xCoordinate, y: 0, width: self.view.frame.width, height: self.view.frame.height)
                } else {
                    imageView.frame = CGRect(x: xCoordinate, y: 0, width: self.view.frame.width, height: 667)
                    imageView.center.y = self.view.frame.height / 2
                }
            }
            
            if phoneHeight != iphoneX {
                scrollView.contentSize = CGSize(width: contentWidth, height: self.view.frame.height)
            } else {
                scrollView.contentSize = CGSize(width: contentWidth, height: 667)
            }
        }
        
        self.view.backgroundColor = UIColor.init(hex: "f9f9f9")
    }
    
    @IBAction func startAction(_ sender: UIButton) {
        if let tabbarVC = self.presentingViewController as? TabBarController {
            tabbarVC.nextIdx = HamburgerController.selectIdx
            self.dismiss(animated: true, completion: nil)
        } else {
            if let tabbarVC = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as? TabBarController {
                self.present(tabbarVC, animated: true, completion: nil)
            }
        }
        
    }
    
}

extension HowViewController {
    func gradationButton(_ button: UIButton) {
        
        let gradientLayer = CAGradientLayer()
        
        let colorLeft = UIColor.init(hex: "1dece6").cgColor
        let colorRight = UIColor.init(hex: "1dd5ec").cgColor
        
        gradientLayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: button.frame.width, height: button.frame.height))
        gradientLayer.colors = [colorLeft, colorRight]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.locations = [0, 1]
        gradientLayer.cornerRadius = 22
        button.layer.addSublayer(gradientLayer)
    }
}
