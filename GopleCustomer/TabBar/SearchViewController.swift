//
//  SearchViewController.swift
//  GopleCustomer
//
//  Created by 김민주 on 2017. 12. 11..
//  Copyright © 2017년 김민주. All rights reserved.
//

import UIKit
import WebKit

class SearchViewController: UIViewController, UIScrollViewDelegate {
    
    var wkWebView = WKWebView()
    
    var viewNavBar = UIView()
    var tmpView = UIView()
    let nTitle = UILabel()
    
    static var route = ""
    
    let lat = UserDefaults.standard.object(forKey: "lat") as! String
    let lon = UserDefaults.standard.object(forKey: "lon") as! String

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config = WKWebViewConfiguration()
        config.userContentController.add(self, name: "setTab")
        config.userContentController.add(self, name: "setGPSRedirect")
        config.userContentController.add(self, name: "setGPSDataRedirect")
        config.userContentController.add(self, name: "onBack")
        
        wkWebView = WKWebView(frame: self.view.frame, configuration: config)
        
        wkWebView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        wkWebView.scrollView.delegate = self
        wkWebView.scrollView.isScrollEnabled = false
        wkWebView.scrollView.bounces = true
        wkWebView.uiDelegate = self
        wkWebView.navigationDelegate = self
        var url: URL!
        
//        if SearchViewController.route == "defalut" {
//            url = URL(string: domain + searchURL)
//        } else if SearchViewController.route == "wedding" {
//            url = URL(string: domain + searchWeddingURL)
//        } else if SearchViewController.route == "sale" {
            url = URL(string: domain + searchSaleURL)
//        }
        
        let request = URLRequest(url: url!)
        wkWebView.load(request)
        self.view.addSubview(wkWebView)
        
        wkWebView.translatesAutoresizingMaskIntoConstraints = false
        wkWebView.topAnchor.constraint(equalTo: self.view.topAnchor, constant : 14).isActive = true
        wkWebView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        wkWebView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        wkWebView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        UIApplication.shared.statusBarStyle = .default
    }

}

extension SearchViewController {
    func createNavigationBar(backColor: UIColor, title: String, titleColor: UIColor, align: NSTextAlignment, btn1: UIButton, btn2: UIButton, back: UIButton) {
        viewNavBar = UIView(frame: CGRect(
            origin: CGPoint(x: 0, y: 0),
            size: CGSize(width: self.view.frame.size.width, height: 58)))
        viewNavBar.backgroundColor = backColor
        
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
    
    func goSearch(_ sender: UIButton) {
        
        if #available(iOS 11.0, *) {
            let url = URL(string: domain + searchWeddingURL)
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            let postString = "lat=\(lat)&lon=\(lon)"
            request.httpBody = postString.data(using: .utf8)
            wkWebView.load(request)
        } else {
            locationSettingWebView(url: domain + searchWeddingURL, lat: lat, lon: lon, wkWebView: wkWebView)
        }
        
    }
    
    func goMap(_ sender: UIButton) {
        
        if #available(iOS 11.0, *) {
            let url = URL(string: domain + mapURL)
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            let postString = "lat=\(lat)&lon=\(lon)"
            request.httpBody = postString.data(using: .utf8)
            wkWebView.load(request)
        } else {
            locationSettingWebView(url: domain + mapURL, lat: lat, lon: lon, wkWebView: wkWebView)
        }
        wkWebView.evaluateJavaScript("gRun.setFilterBack()", completionHandler: nil)
        
    }
    
    func goReview(_ sender: UIButton) {
        wkWebView.evaluateJavaScript("gRun.goReviewWrite()", completionHandler: nil)
    }
    
    func filterBack(_ sender: UIButton) {
        wkWebView.evaluateJavaScript("gRun.setFilterBack()", completionHandler: nil)
    }
    
    func goHome(_ sender: UIButton) {
        if let tabbarVC = self.presentingViewController as? TabBarController {
            tabbarVC.nextIdx = 0
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func showMenu(_ sender: UIButton) {
        if let hamburgerVC = self.storyboard?.instantiateViewController(withIdentifier: "HamburgerController") as? HamburgerController {
            self.present(hamburgerVC, animated: true, completion: nil)
        }
    }
    
    func goSchedule(_ sender: UIButton) {
        wkWebView.evaluateJavaScript("gRun.goScheduleWrite()", completionHandler: { result, error in
            if let error = error {
                print(error)
            } else {
                print(result)
            }
        })
    }
    
    func doneBtn(_ sender: UIButton) {
        if let tabbarVC = self.presentingViewController as? TabBarController {
            tabbarVC.nextIdx = 2
        }
        self.dismiss(animated: true, completion: nil)
    }
}

extension SearchViewController: WKScriptMessageHandler {
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
                        btn1.setImage(#imageLiteral(resourceName: "search_black"), for: .normal)
                        btn2.setImage(#imageLiteral(resourceName: "hamburger_black"), for: .normal)
                    } else if scriptColor == 1 {
                        //파란색
                        UIApplication.shared.statusBarStyle = .lightContent
                        color = mainColor
                        titleColor = UIColor.white
                        back.setImage(#imageLiteral(resourceName: "back_white"), for: .normal)
                        btn1.setImage(#imageLiteral(resourceName: "search_white"), for: .normal)
                        btn2.setImage(#imageLiteral(resourceName: "hamburger_white"), for: .normal)
                    } else if scriptColor == 2 {
                        //회색
                        UIApplication.shared.statusBarStyle = .default
                        color = UIColor.init(hex: "f5f5f5")
                        titleColor = textColor
                    }
                }
                
                if let scriptTitle = scriptMessage[1] as? String {
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
                        
//                        btn2.setImage(#imageLiteral(resourceName: "black_4041"), for: .normal)
                        btn2.frame.size = CGSize(width: 40, height: 41)
                        btn2.frame.origin.x = self.view.frame.width - (btn2.frame.width + 5)
                        btn2.addTarget(self, action: #selector(showMenu(_:)), for: .touchUpInside)
                        
                    } else if scriptBtn2 == "select" {
                        
                        btn2.setImage(UIImage(), for: .normal)
                        btn2.setTitle("선택", for: .normal)
                        btn2.setTitleColor(mainColor, for: .normal)
                        btn2.titleLabel?.font = UIFont(name: "Daehan-Bold", size: 17)
                        btn2.titleColor(for: .normal)
                        btn2.titleLabel?.textAlignment = .right
                        btn2.frame.size = CGSize(width: 40, height: 41)
                        btn2.frame.origin.x = self.view.frame.width - (btn2.frame.width + 9)
                        btn2.addTarget(self, action: #selector(goSchedule(_:)), for: .touchUpInside)
                        
                    }
                }
                
                if let scriptBtn1 = scriptMessage[3] as? String {
                    if scriptBtn1 == "search" {
                        
                        btn1.frame.size = CGSize(width: 35, height: 44)
                        btn1.frame.origin.x = btn2.frame.minX - (3 + btn1.frame.width)
                        btn1.addTarget(self, action: #selector(goSearch(_:)), for: .touchUpInside)
                        
                    } else if scriptBtn1 == "map" {
                        btn1.setImage(UIImage(), for: .normal)
                        
                    } else if scriptBtn1 == "back" {
                        btn1.setImage(UIImage(), for: .normal)
                        
                    } else if scriptBtn1 == "review" {
                        btn1.setImage(UIImage(), for: .normal)
                        
                    } else if scriptBtn1 == "menu" {
                        btn1.setImage(UIImage(), for: .normal)
                        
                    } else if scriptBtn1 == "calc" {
                        btn1.setImage(#imageLiteral(resourceName: "home"), for: .normal)
                        btn1.frame.size = CGSize(width: 34, height: 30)
                        btn1.frame.origin.x = btn2.frame.minX - btn1.frame.width
                        btn1.addTarget(self, action: #selector(goHome(_:)), for: .touchUpInside)
                    }
                }
                
                createNavigationBar(backColor: color, title: title, titleColor: titleColor, align: align, btn1: btn1, btn2: btn2, back: back)
            }
        }
        
        if message.name == "setGPSRedirect" {
            print("\(message.name) : \(message.body)")
            if let scripteMessage = message.body as? [AnyObject] {
                
                if let url = scripteMessage[0] as? String {
                    
                    UserDefaults.standard.set(url, forKey: "companyDetail")
                    
                    if let newWebVC = self.storyboard?.instantiateViewController(withIdentifier: "NewWebViewController") as? NavigationController {
                        self.present(newWebVC, animated: true, completion: nil)
                    }

                }
            }
        }
        
        if message.name == "setGPSDataRedirect" {
            print("\(message.name) : \(message.body)")
            
            if let scripteMessage = message.body as? [AnyObject] {
                
                var url = ""
                var attr = ""
                var value = ""
                
                if let scriptUrl = scripteMessage[0] as? String {
                    url = domain + scriptUrl
                    print(url)
                }
                
                if let scriptAttr = scripteMessage[1] as? String {
                    attr = scriptAttr
                    print(attr)
                }
                
                if let scriptValue = scripteMessage[2] as? String {
                    value = scriptValue
                    print(value)
                }
                
                if #available(iOS 11.0, *) {
                    let rurl = URL(string: url)
                    var request = URLRequest(url: rurl!)
                    request.httpMethod = "POST"
                    let postString = "\(attr)=\(value)&lat=\(lat)&lon=\(lon)"
                    request.httpBody = postString.data(using: .utf8)
                    wkWebView.load(request)
                } else {
                    searchSettingWebView(url: url, attr: attr, value: value, lat: lat, lon: lon)
                }
                
            }
        }
        
        if message.name == "onBack" {
            print("\(message.name) : \(message.body)")
            if let tabbarVC = self.presentingViewController as? TabBarController {
                tabbarVC.nextIdx = 2
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
}

extension SearchViewController: WKNavigationDelegate {
    
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

extension SearchViewController: WKUIDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
    }
    
}

extension SearchViewController {
    func searchSettingWebView(url: String, attr: String, value: String, lat: String, lon: String) {
        
        let javascriptPOSTRedirect: String = "" +
            "var form = document.createElement('form');" +
            "form.method = 'POST';" +
            "form.action = '\(url)';" +
            "" +
            "var input = document.createElement('input');" +
            "input.type = 'text';" +
            "input.name = '\(attr)';" +
            "input.value = '\(value)';" +
            "form.appendChild(input);" +
            "var input = document.createElement('input');" +
            "input.type = 'text';" +
            "input.name = 'lat';" +
            "input.value = '\(lat)';" +
            "form.appendChild(input);" +
            "var input = document.createElement('input');" +
            "input.type = 'text';" +
            "input.name = 'lon';" +
            "input.value = '\(lon)';" +
            "form.appendChild(input);" +
            "" +
        "form.submit();"
        //        print(javascriptPOSTRedirect)
        
        wkWebView.evaluateJavaScript(javascriptPOSTRedirect, completionHandler: nil)
    }

}

