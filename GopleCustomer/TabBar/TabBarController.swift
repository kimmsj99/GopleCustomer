//
//  TabBarController.swift
//  GopleCustomer
//
//  Created by 김민주 on 2017. 11. 14..
//  Copyright © 2017년 김민주. All rights reserved.
//

import UIKit
import WebKit

protocol LoginDelegate: class {
    func login(id: String, email: String)
}

protocol LogoutDelegate: class {
    func logout()
}

protocol WithdrawalDelegate: class {
    func withdraw(id: String, email: String)
}

class TabBarController: UITabBarController {
    
    static let customTabBar = UIView()
    static let ddayView = UIView()
    static let marryLabel = UILabel()
    
    let homeBtn = UIButton()
    let newsBtn = UIButton()
    let saleBtn = UIButton()
    let bookmarkBtn = UIButton()
    let mypageBtn = UIButton()
    
    var wkWebView : WKWebView!
    var config = WKWebViewConfiguration()
    
    var nextIdx = 0
    
    let tabVC = TabBarController.self
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.isHidden = true
        self.tabBar.frame = .zero
        
        wkWebView = WKWebView(frame: .zero, configuration: config)
        
        wkWebView.navigationDelegate = self
        wkWebView.uiDelegate = self
        
        tabVC.ddayView.frame = CGRect(x: 0, y: 20, width: view.frame.width, height: 59)
        tabVC.ddayView.backgroundColor = UIColor.white
        
        tabVC.marryLabel.text = "\"내 결혼식"
        tabVC.marryLabel.font = UIFont(name: "Daehan-Bold", size: 13)
        tabVC.marryLabel.textColor = UIColor.init(hex: "929292")
        tabVC.marryLabel.sizeToFit()
        tabVC.marryLabel.center.y = tabVC.ddayView.frame.height / 2
        tabVC.marryLabel.frame.origin.x = calculateConstant(22)
        tabVC.ddayView.addSubview(tabVC.marryLabel)
        
        self.view.addSubview(tabVC.ddayView)
        
        tabVC.customTabBar.frame = CGRect(x: 0, y: tabVC.ddayView.frame.maxY, width: self.view.frame.width, height: 30)
        tabVC.customTabBar.backgroundColor = UIColor.white
        let heightOfOneBtn = tabVC.customTabBar.frame.height
        
        homeBtn.frame = CGRect(x: calculateConstant(18), y: 0, width: calculateConstant(31), height: heightOfOneBtn)
        newsBtn.frame = CGRect(x: homeBtn.frame.maxX + calculateConstant(8), y: 0, width: calculateConstant(58), height: heightOfOneBtn)
        saleBtn.frame = CGRect(x: newsBtn.frame.maxX + calculateConstant(8), y: 0, width: calculateConstant(86), height: heightOfOneBtn)
        bookmarkBtn.frame = CGRect(x: saleBtn.frame.maxX + calculateConstant(6), y: 0, width: calculateConstant(58), height: heightOfOneBtn)
        mypageBtn.frame = CGRect(x: bookmarkBtn.frame.maxX + calculateConstant(3), y: 0, width: calculateConstant(78), height: heightOfOneBtn)

        homeBtn.contentEdgeInsets = UIEdgeInsetsMake(1, 0, 17, 0)
        newsBtn.contentEdgeInsets = UIEdgeInsetsMake(1, 0, 17, 0)
        saleBtn.contentEdgeInsets = UIEdgeInsetsMake(1, 0, 17, 0)
        bookmarkBtn.contentEdgeInsets = UIEdgeInsetsMake(1, 0, 17, 0)
        mypageBtn.contentEdgeInsets = UIEdgeInsetsMake(1, 0, 17, 0)
        
//        homeBtn.setImage(#imageLiteral(resourceName: "tab_1_n"), for: .normal)
        homeBtn.setImage(#imageLiteral(resourceName: "tab_1"), for: .normal)
        
        newsBtn.setImage(#imageLiteral(resourceName: "tab_2_n"), for: .normal)
//        newsBtn.setImage(#imageLiteral(resourceName: "tab_2"), for: .selected)
        
        saleBtn.setImage(#imageLiteral(resourceName: "tab_3_n"), for: .normal)
//        saleBtn.setImage(#imageLiteral(resourceName: "tab_3"), for: .selected)
        
        bookmarkBtn.setImage(#imageLiteral(resourceName: "tab_4_n"), for: .normal)
//        bookmarkBtn.setImage(#imageLiteral(resourceName: "tab_4"), for: .selected)
        
        mypageBtn.setImage(#imageLiteral(resourceName: "tab_5_n"), for: .normal)
//        mypageBtn.setImage(#imageLiteral(resourceName: "tab_5"), for: .selected)
        
        homeBtn.tag = 0
        newsBtn.tag = 1
        saleBtn.tag = 2
        bookmarkBtn.tag = 3
        mypageBtn.tag = 4
        
        setAttributeTabBarButton(homeBtn)
        setAttributeTabBarButton(newsBtn)
        setAttributeTabBarButton(saleBtn)
        setAttributeTabBarButton(bookmarkBtn)
        setAttributeTabBarButton(mypageBtn)
        
        self.view.addSubview(tabVC.customTabBar)
        
        config.processPool = MainWKProcess.shared
        wkWebView = WKWebView(frame: .zero, configuration: config)
        self.view.addSubview(wkWebView)
        
    }
    
    func calculateConstant(_ value : CGFloat ) -> CGFloat {
        let v = self.view.frame.width
        return (value / 375) * v
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.selectedIndex = nextIdx

        if nextIdx != 0 {
            tabVC.customTabBar.isHidden = true
            tabVC.ddayView.isHidden = true
        }
    }
    
    func setAttributeTabBarButton(_ btn: UIButton) {
        btn.addTarget(self, action: #selector(onBtnClick(_:)), for: .touchUpInside)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.setTitleColor(UIColor.red, for: .selected)
        tabVC.customTabBar.addSubview(btn)
    }
    
    func onBtnClick(_ sender: UIButton) {
        self.homeBtn.isSelected = true
        self.newsBtn.isSelected = false
        self.saleBtn.isSelected = false
        self.bookmarkBtn.isSelected = false
        self.mypageBtn.isSelected = false
        
        sender.isSelected = true
        
        self.selectedIndex = sender.tag
        
        if sender.tag != 0 {
            TabBarController.customTabBar.isHidden = true
            TabBarController.ddayView.isHidden = true
        } else {
            TabBarController.customTabBar.isHidden = false
            TabBarController.ddayView.isHidden = false
        }
    }

    deinit {
        print("asd")
    }
    
}

//extension TabBarController: LoginDelegate {
//    func login(id: String, email: String) {
//
//        guard let token = UserDefaults.standard.object(forKey: "token") as? String else {
//            return
//        }
//
//        UserDefaults.standard.set(id, forKey: "id")
//        UserDefaults.standard.set(email, forKey: "email")
//
//        print("id : \(id) / email : \(email)")
//
//        if #available(iOS 11.0, *) {
//            var request = URLRequest(url: URL(string: domain + loginSuccessURL)!)
//            request.httpMethod = "POST"
//            let postString = "id=\(id)&email=\(email)&token=\(token)&device=ios"
//            request.httpBody = postString.data(using: .utf8)
//            wkWebView.load(request)
//        } else {
//            loginSettingWebView(id: id, email: email, token: token)
//        }
//    }
//
//    func loginSettingWebView(id: String, email: String, token: String) {
//
//        let javascriptPOSTRedirect: String = "" +
//            "var form = document.createElement('form');" +
//            "form.method = 'POST';" +
//            "form.action = '\(domain + loginSuccessURL)';" +
//            "" +
//            "var input = document.createElement('input');" +
//            "input.type = 'text';" +
//            "input.name = 'id';" +
//            "input.value = '\(id)';" +
//            "form.appendChild(input);" +
//            "var input = document.createElement('input');" +
//            "input.type = 'text';" +
//            "input.name = 'email';" +
//            "input.value = '\(email)';" +
//            "form.appendChild(input);" +
//            "var input = document.createElement('input');" +
//            "input.type = 'text';" +
//            "input.name = 'token';" +
//            "input.value = '\(token)';" +
//            "form.appendChild(input);" +
//            "var input = document.createElement('input');" +
//            "input.type = 'text';" +
//            "input.name = 'device';" +
//            "input.value = 'ios';" +
//            "form.appendChild(input);" +
//            "" +
//        "form.submit();"
//        //        print(javascriptPOSTRedirect)
//
//        wkWebView.evaluateJavaScript(javascriptPOSTRedirect, completionHandler: nil)
//    }
//}

extension TabBarController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let otherAction = UIAlertAction(title: "확인", style: .default) {
            action in completionHandler()
        }
        alertController.addAction(otherAction)
        present(alertController, animated: true, completion: nil)
    }

    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) {
            action in completionHandler(false)
        }
        let okAction = UIAlertAction(title: "확인", style: .default) {
            action in completionHandler(true)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        
        let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        let okHandler: () -> Void = { handler in
            if let textField = alertController.textFields?.first {
                completionHandler(textField.text)
            } else {
                completionHandler("")
            }
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) {
            action in completionHandler(nil)
        }
        let okAction = UIAlertAction(title: "확인", style: .default) {
            action in okHandler()
        }
        alertController.addTextField { $0.text = defaultText }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension TabBarController: WKUIDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        // 2. 상단 status bar에도 activity indicator가 나오게 할 것이다.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
    }
    
}

