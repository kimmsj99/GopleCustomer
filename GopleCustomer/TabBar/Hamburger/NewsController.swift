//
//  gopleNoticeController.swift
//  GopleCustomer
//
//  Created by 김민주 on 2017. 11. 15..
//  Copyright © 2017년 김민주. All rights reserved.
//

import UIKit
import WebKit

class NewsController: UIViewController, UIScrollViewDelegate  {
    
    var wkWebView = WKWebView()
    
    var viewNavBar = UIView()
    var tmpView = UIView()
    let nTitle = UILabel()
    
    var lat = ""
    var lon = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config = WKWebViewConfiguration()
        config.userContentController.add(self, name: "setTab")
        config.userContentController.add(self, name: "setGPSRedirect")
        config.userContentController.add(self, name: "setGPSDataRedirect")
        
        wkWebView = WKWebView(frame: self.view.frame, configuration: config)
        
        wkWebView.scrollView.delegate = self
        wkWebView.scrollView.isScrollEnabled = false
        wkWebView.scrollView.bounces = true
        wkWebView.uiDelegate = self
        wkWebView.navigationDelegate = self
        
        (self.view.subviews.last as? UIScrollView)?.scrollsToTop = false
        wkWebView.scrollView.scrollsToTop = true
//        (wkWebView.subviews.last as? UIScrollView)?.scrollsToTop = true
        
        if UserDefaults.standard.object(forKey: "lat") != nil, UserDefaults.standard.object(forKey: "lon") != nil {
            lat = UserDefaults.standard.object(forKey: "lat") as! String
            lon = UserDefaults.standard.object(forKey: "lon") as! String
        }
        
        let url = URL(string: domain + newsURL)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        let postString = "lat=\(lat)&lon=\(lon)"
        request.httpBody = postString.data(using: .utf8)
        wkWebView.load(request)
        self.view.addSubview(wkWebView)
        
        wkWebView.translatesAutoresizingMaskIntoConstraints = false
        wkWebView.topAnchor.constraint(equalTo: self.view.topAnchor, constant : 14).isActive = true
        wkWebView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        wkWebView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        wkWebView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        wkWebView.reload()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }

}

extension NewsController {
    func createNavigationBar(backColor: UIColor, title: String, titleColor: UIColor, align: NSTextAlignment, btn1: UIButton, btn2: UIButton, back: UIButton) {
        viewNavBar = UIView(frame: CGRect(
            origin: CGPoint(x: 0, y: 0),
            size: CGSize(width: self.view.frame.size.width, height: 58)))
        viewNavBar.backgroundColor = backColor
        
        back.addTarget(self, action: #selector(doneBtn(_:)), for: .touchUpInside)
        viewNavBar.addSubview(back)
        
        nTitle.text = title
        nTitle.font = UIFont(name: "DaeHan-Bold", size: 20)
        nTitle.textColor = titleColor
        nTitle.textAlignment = align
        viewNavBar.addSubview(nTitle)
        
        btn2.center.y = viewNavBar.frame.height / 2
        btn1.center.y = viewNavBar.frame.height / 2
        
        viewNavBar.addSubview(btn2)
        viewNavBar.addSubview(btn1)
        
        if UIScreen.main.nativeBounds.height == 2436 {
            tmpView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 44.0 ))
            
        } else {
            tmpView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 20.0 ))
            
        }
        
        tmpView.backgroundColor = backColor
        self.navigationController?.view.addSubview(tmpView)
        
        self.navigationController?.navigationBar.addSubview(viewNavBar)
    }
    
    func goSearch(_ sender: UIButton){
        
        let url = URL(string: domain + searchSaleURL)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        let postString = "lat=\(lat)&lon=\(lon)"
        request.httpBody = postString.data(using: .utf8)
        wkWebView.load(request)
        
    }
    
    func goMap(_ sender: UIButton){
        
        let url = URL(string: domain + mapURL)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        let postString = "lat=\(lat)&lon=\(lon)"
        request.httpBody = postString.data(using: .utf8)
        wkWebView.load(request)
        
    }
    
    func goReview(_ sender: UIButton) {
        wkWebView.evaluateJavaScript("gRun.goReviewWrite()", completionHandler: nil)
    }
    
    func showMenu(_ sender: UIButton) {
        if let hamburgerVC = self.storyboard?.instantiateViewController(withIdentifier: "HamburgerController") as? HamburgerController {
            self.present(hamburgerVC, animated: true, completion: nil)
            HamburgerController.selectIdx = 1
        }
    }
    
    func doneBtn(_ sender: UIButton) {
        
        if wkWebView.url != URL(string: domain + newsURL) {
            wkWebView.evaluateJavaScript("back();", completionHandler: { (result, error) in
                if let error = error {
                    print(error)
                } else {
                    self.wkWebView.reload()
                    
                }
            })
        } else {
            self.tabBarController?.selectedIndex = 0
            TabBarController.customTabBar.isHidden = false
        }
    }
}

extension NewsController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "setTab" {
            print("\(message.name) : \(message.body)")
            
            var color: UIColor!
            var title: String!
            var titleColor: UIColor!
            var align: NSTextAlignment!
            let btn1 = UIButton()
            let btn2 = UIButton()
            let back = UIButton()
            back.frame = CGRect(x: 9, y: 14, width: 42, height: 31)
            back.addTarget(self, action: #selector(doneBtn(_:)), for: .touchUpInside)
            
            if let scriptMessage = message.body as? [AnyObject] {
                if let scriptColor = scriptMessage[0] as? Int {
                    if scriptColor == 0 {
                        //흰색
                        UIApplication.shared.statusBarStyle = .default
                        color = UIColor.white
                        titleColor = textColor
                        back.setImage(#imageLiteral(resourceName: "back_black"), for: .normal)
                    } else if scriptColor == 1 {
                        //파란색
                        UIApplication.shared.statusBarStyle = .lightContent
                        color = mainColor
                        titleColor = UIColor.white
                        back.setImage(#imageLiteral(resourceName: "back_white"), for: .normal)
                    } else if scriptColor == 2 {
                        //회색
                        UIApplication.shared.statusBarStyle = .default
                        color = UIColor.init(hex: "f5f5f5")
                        titleColor = textColor
                    }
                }
                
                if let scriptTitle = scriptMessage[1] as? String {
                    //                    setTabTitle = title
                    title = scriptTitle
                    
                    if scriptTitle == "검색" {
                        back.setImage(#imageLiteral(resourceName: "search_delete"), for: .normal)
                        back.frame = CGRect(origin: CGPoint(x: 0, y: 7), size: CGSize(width: 47, height: 46))
                        back.frame.origin.x = self.view.frame.width - (3 + back.frame.width)
                    }
                    
                }
                
                if let scriptAlign = scriptMessage[2] as? Int {
                    if scriptAlign == 0 {
                        //center
                        
                        align = NSTextAlignment.center
                        nTitle.frame = CGRect(x: 0, y: 20, width: self.view.frame.width, height: 20)
                        nTitle.center.x = self.view.frame.width / 2
                    } else if scriptAlign == 1 {
                        //left
                        
                        align = NSTextAlignment.left
                        nTitle.frame = CGRect(x: back.frame.maxX + 1, y: 20, width: self.view.frame.width, height: 20)
                    } else if scriptAlign == 2 {
                        //right
                        
                        align = NSTextAlignment.right
                    }
                }
                
                if let scriptBtn2 = scriptMessage[4] as? String {
                    if scriptBtn2 == "search" {
                        btn2.setImage(#imageLiteral(resourceName: "search_black"), for: .normal)
                        btn2.frame.size = CGSize(width: 35, height: 44)
                        btn2.frame.origin.x = self.view.frame.width - (btn2.frame.width + 12)
                        btn2.addTarget(self, action: #selector(goSearch(_:)), for: .touchUpInside)
                        
                    } else if scriptBtn2 == "map" {
                        
                        btn2.setImage(#imageLiteral(resourceName: "map"), for: .normal)
                        btn2.frame.size = CGSize(width: 28, height: 44)
                        btn2.frame.origin.x = self.view.frame.width - (btn2.frame.width + 15)
                        btn2.addTarget(self, action: #selector(goMap(_:)), for: .touchUpInside)
                        
                    } else if scriptBtn2 == "back" {
                        
                    } else if scriptBtn2 == "review" {
                        
                        btn2.setImage(#imageLiteral(resourceName: "review"), for: .normal)
                        btn2.frame.size = CGSize(width: 81, height: 55)
                        btn2.frame.origin.x = self.view.frame.width - (btn2.frame.width + 27)
                        btn2.addTarget(self, action: #selector(goReview(_:)), for: .touchUpInside)
                        
                    } else if scriptBtn2 == "menu" {
                        btn2.setImage(#imageLiteral(resourceName: "black_4041"), for: .normal)
                        btn2.frame.size = CGSize(width: 40, height: 41)
                        btn2.frame.origin.x = self.view.frame.width - (btn2.frame.width + 5)
                        btn2.addTarget(self, action: #selector(showMenu(_:)), for: .touchUpInside)
                    }
                }
                
                if let scriptBtn1 = scriptMessage[3] as? String {
                    if scriptBtn1 == "search" {
                        
                        btn1.setImage(#imageLiteral(resourceName: "search_white"), for: .normal)
                        btn1.frame.size = CGSize(width: 35, height: 44)
                        btn1.frame.origin.x = btn2.frame.minX - (3 + btn1.frame.width)
                        btn1.addTarget(self, action: #selector(goSearch(_:)), for: .touchUpInside)
                        
                    } else if scriptBtn1 == "map" {
                        
                    } else if scriptBtn1 == "back" {
                        
                    } else if scriptBtn1 == "review" {
                        
                    } else if scriptBtn1 == "menu" {
                        
                    }
                }
                
                createNavigationBar(backColor: color, title: title, titleColor: titleColor, align: align, btn1: btn1, btn2: btn2, back: back)
            }
        }
        
        if message.name == "setGPSRedirect" {
            print("\(message.name) : \(message.body)")
            
            if let scriptMessage = message.body as? [AnyObject] {
                if let url = scriptMessage[0] as? String {
                    UserDefaults.standard.set(url, forKey: "newWebUrl")
                }
                
                HomeController.type = 1
                HamburgerController.selectIdx = 1
                if let newWebVC = self.storyboard?.instantiateViewController(withIdentifier: "NewWebViewController") as? NavigationController {
                    
                    UserDefaults.standard.removeObject(forKey: "home_url")
                    UserDefaults.standard.removeObject(forKey: "share_idx")
                    UserDefaults.standard.removeObject(forKey: "push_url")
                    UserDefaults.standard.removeObject(forKey: "companyWeb")
                    self.present(newWebVC, animated: true, completion: nil)
                    
                }
            }
            
        }
        
        if message.name == "setGPSDataRedirect" {
            print("\(message.name) : \(message.body)")
            
        }
    }
}

extension NewsController: WKNavigationDelegate {
    
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

extension NewsController: WKUIDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        wkWebView.isUserInteractionEnabled = false
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        wkWebView.isUserInteractionEnabled = true
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
    }
    
}
