//
//  BookmarkController.swift
//  GopleCustomer
//
//  Created by 김민주 on 2017. 11. 29..
//  Copyright © 2017년 김민주. All rights reserved.
//

import UIKit
import WebKit
import PopupDialog

class BookmarkController: UIViewController, UIScrollViewDelegate {
    
    var wkWebView = WKWebView()
    
    var viewNavBar = UIView()
    var tmpView = UIView()
    let nTitle = UILabel()
    
    weak var logoutDelegate: LogoutDelegate?
    
    var contractBridge = ""
    static var javascriptFunc = ""
    
    var lat = ""
    var lon = ""
    
    static var reloadExecution = false
    static var scheduleSave = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config = WKWebViewConfiguration()
        
        config.processPool = MainWKProcess.shared
        
        config.userContentController.add(self, name: "setTab")
        config.userContentController.add(self, name: "setGPSRedirect")
        config.userContentController.add(self, name: "setGPSDataRedirect")
        config.userContentController.add(self, name: "onNoticeAlert")
        config.userContentController.add(self, name: "onChoiceAlert")
        config.userContentController.add(self, name: "reload")
        
        wkWebView = WKWebView(frame: self.view.frame, configuration: config)
        
        wkWebView.scrollView.delegate = self
        wkWebView.scrollView.isScrollEnabled = false
        wkWebView.scrollView.scrollsToTop = true
        wkWebView.scrollView.bounces = true
        wkWebView.uiDelegate = self
        wkWebView.navigationDelegate = self
        
        if UserDefaults.standard.object(forKey: "lat") != nil, UserDefaults.standard.object(forKey: "lon") != nil {
            lat = UserDefaults.standard.object(forKey: "lat") as! String
            lon = UserDefaults.standard.object(forKey: "lon") as! String
        }
        
//        if #available(iOS 11.0, *) {
//            let url = URL(string: domain + bookmarkURL)
//            var request = URLRequest(url: url!)
//            request.httpMethod = "POST"
//            let postString = "lat=\(lat)&lon=\(lon)"
//            request.httpBody = postString.data(using: .utf8)
//            wkWebView.load(request)
//        } else {
//            locationSettingWebView(url: domain + bookmarkURL, lat: lat, lon: lon, wkWebView: wkWebView)
//        }
        
        self.view.addSubview(wkWebView)
        
        wkWebView.translatesAutoresizingMaskIntoConstraints = false
        wkWebView.topAnchor.constraint(equalTo: self.view.topAnchor, constant : 14).isActive = true
        wkWebView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        wkWebView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        wkWebView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let id = UserDefaults.standard.object(forKey: "id") as? String{
            if id == "guest" {
                print("guest")
                loginPopupDialog(title: "", message: "회원가입 후 이용해 주시기 바랍니다.")
            } else {
                
                if BookmarkController.reloadExecution == true {
                    self.wkWebView.evaluateJavaScript("reload()", completionHandler: { (result, error) in
                        if let error = error {
                            print(error)
                        } else {
                            BookmarkController.reloadExecution = false
                            print(result)
                        }
                    })
                }
                
                if wkWebView.url != URL(string: domain + bookmarkURL) {
                    
                    if #available(iOS 11.0, *) {
                        let url = URL(string: domain + bookmarkURL)
                        var request = URLRequest(url: url!)
                        request.httpMethod = "POST"
                        let postString = "lat=\(lat)&lon=\(lon)"
                        request.httpBody = postString.data(using: .utf8)
                        wkWebView.load(request)
                    } else {
                        locationSettingWebView(url: domain + bookmarkURL, lat: lat, lon: lon, wkWebView: wkWebView)
                    }
                }
                
                UIApplication.shared.statusBarStyle = .default
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if wkWebView.url == URL(string: domain + bookmarkURL) {
            if BookmarkController.scheduleSave == true {
                if BookmarkController.javascriptFunc != "" {
                    self.wkWebView.evaluateJavaScript("\(BookmarkController.javascriptFunc)()", completionHandler: { (result, error) in
                        if let error = error {
                            print(error)
                        } else {
                            BookmarkController.scheduleSave = false
                            BookmarkController.javascriptFunc = ""
                            print(result)
                        }
                    })
                }
            }
        }
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }

}

extension BookmarkController {
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
        
        if #available(iOS 11.0, *) {
            let url = URL(string: domain + searchSaleURL)
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            let postString = "lat=\(lat)&lon=\(lon)"
            request.httpBody = postString.data(using: .utf8)
            wkWebView.load(request)
        } else {
            locationSettingWebView(url: domain + searchSaleURL, lat: lat, lon: lon, wkWebView: wkWebView)
        }
        
    }
    
    func goMap(_ sender: UIButton){
        
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
        
    }
    
    func goReview(_ sender: UIButton) {
        wkWebView.evaluateJavaScript("gRun.goReviewWrite()", completionHandler: nil)
    }
    
    func showMenu(_ sender: UIButton) {
        if let hamburgerVC = self.storyboard?.instantiateViewController(withIdentifier: "HamburgerController") as? HamburgerController {
            self.present(hamburgerVC, animated: true, completion: nil)
            HamburgerController.selectIdx = 3
        }
    }
    
    //MARK: - 뒤로가기
    func doneBtn(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = 0
        TabBarController.customTabBar.isHidden = false
        BookmarkController.reloadExecution = false
    }
}

extension BookmarkController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "setTab" {
            print("\(message.name) : \(message.body)")
            print("setTab : \(message.body)")
            
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
                    } else if scriptColor == 1 {
                        //파란색
                        UIApplication.shared.statusBarStyle = .lightContent
                        color = mainColor
                        titleColor = UIColor.white
                        back.setImage(#imageLiteral(resourceName: "back_white"), for: .normal)
                        btn1.setImage(#imageLiteral(resourceName: "search_white"), for: .normal)
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
                    
                    if scriptMessage[1] as? Int == 4 {
                        let uurl = scriptMessage[0] as! String
                        
                        if uurl == wishURL {
                            BookmarkController.reloadExecution = true
                        }
                        
                        if #available(iOS 11.0, *) {
                            let url = URL(string: domain + uurl)
                            var request = URLRequest(url: url!)
                            request.httpMethod = "POST"
                            let postString = "lat=\(lat)&lon=\(lon)"
                            request.httpBody = postString.data(using: .utf8)
                            wkWebView.load(request)
                        } else {
                            locationSettingWebView(url: domain + uurl, lat: lat, lon: lon, wkWebView: wkWebView)
                        }
                        return
                    }
                    
                    HomeController.type = 3
                    HamburgerController.selectIdx = 3
                    
                    if let newWebVC = self.storyboard?.instantiateViewController(withIdentifier: "NewWebViewController") as? NavigationController {
                        WebViewController.calenderType = "newweb"
                        BookmarkController.reloadExecution = true
                        UserDefaults.standard.removeObject(forKey: "home_url")
                        UserDefaults.standard.removeObject(forKey: "share_idx")
                        UserDefaults.standard.removeObject(forKey: "push_url")
                        UserDefaults.standard.removeObject(forKey: "companyWeb")
                        UserDefaults.standard.removeObject(forKey: "companyDetail")
                        self.present(newWebVC, animated: true, completion: nil)
                        
                    }
                }
                
            }
        }
        
        if message.name == "setGPSDataRedirect" {
            print("\(message.name) : \(message.body)")
        }
        
        if message.name == "onNoticeAlert" {
            print("\(message.name) : \(message.body)")
            
            let changeScheduleVC = ChangeScheduleController(nibName: "ChangeScheduleController", bundle: nil)
            let popup = PopupDialog(viewController: changeScheduleVC, buttonAlignment: .horizontal, transitionStyle: .bounceDown, gestureDismissal: true, completion: nil)
            
            self.present(popup, animated: true, completion: nil)
        }
        
        if message.name == "onChoiceAlert" {
            print("\(message.name) : \(message.body)")
            
            contractBridge = message.body as! String
            choiceAlert(title: "", message: "해당업체를 선택하시겠습니까?")
        }
        
        if message.name == "reload" {
            print("\(message.name) : \(message.body)")
        }
    }
    
    func choiceAlert(title: String, message: String){
        let popup = PopupDialog(title: title, message: message)
        popup.transitionStyle = .bounceDown
        
        let okButton = DefaultButton(title: "확인", height: 49, dismissOnTap: true, action: {
            self.wkWebView.evaluateJavaScript("\(self.contractBridge)()", completionHandler: { (result, error) in
                if let error = error {
                    print(error)
                } else {
                    print(result)
                }
            })
        })
        let cancelButton = CancelButton(title: "취소", height: 49, dismissOnTap: true, action: nil)
        
        popup.addButtons([cancelButton, okButton])
        popup.buttonAlignment = .horizontal
        
        let pv = PopupDialogDefaultView.appearance()
        pv.titleFont = UIFont(name: "Daehan-Bold", size: 14)!
        pv.titleColor = textColor
        pv.titleTextAlignment = .center
        pv.messageFont = UIFont(name: "Daehan-Bold", size: 14)!
        pv.messageColor = textColor
        pv.messageTextAlignment = .center
        
        let pcv = PopupDialogContainerView.appearance()
        pcv.frame.size = CGSize(width: 246, height: 138)
        pcv.backgroundColor = UIColor.white
        pcv.shadowEnabled = false
        pcv.cornerRadius = 0
        
        let db = DefaultButton.appearance()
        db.titleFont = UIFont(name: "Daehan-Bold", size: 15)!
        db.titleColor = mainColor2
        db.buttonColor = UIColor.white
        
        let cb = CancelButton.appearance()
        cb.titleFont = UIFont(name: "Daehan-Bold", size: 15)!
        cb.titleColor = UIColor.init(hex: "979797")
        cb.buttonColor = UIColor.white
        
        self.present(popup, animated: true, completion: nil)
    }
}

extension BookmarkController: WKNavigationDelegate {
    
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

extension BookmarkController: WKUIDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
    }
    
}

extension BookmarkController {
    func loginPopupDialog(title: String, message: String){
        
        let popup = PopupDialog(title: title, message: message)
        popup.transitionStyle = .bounceDown
        
        let okButton = DefaultButton(title: "확인", height: 48, dismissOnTap: true, action: {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                let rootVC = appDelegate.window?.rootViewController
                
                //로그인VC -> HomeVC 일때
                if let loginVC = rootVC as? LoginController {
                    if let tabbarVC = loginVC.presentedViewController as? TabBarController {
                        if let naviVC = tabbarVC.childViewControllers[0] as? NavigationController {
                            if let homeVC = naviVC.viewControllers.first as? HomeController {
                                self.logoutDelegate = homeVC
                                self.logoutDelegate?.logout()
                            }
                        }
                    }
                } else {
                    if let naviVC = rootVC?.childViewControllers[0] as? NavigationController {
                        if let homeVC = naviVC.viewControllers.first as? HomeController {
                            
                            self.logoutDelegate = homeVC
                            self.logoutDelegate?.logout()
                            
                        }
                    }
                }
            }
        })
        
        let cancelButton = CancelButton(title: "취소", height: 48, dismissOnTap: true, action: {
            self.tabBarController?.selectedIndex = 0
        })
        
        popup.addButtons([cancelButton, okButton])
        popup.buttonAlignment = .horizontal
        
        let pv = PopupDialogDefaultView.appearance()
        pv.titleFont = UIFont(name: "Daehan-Bold", size: 15)!
        pv.titleColor = textColor
        pv.titleTextAlignment = .center
        pv.messageFont = UIFont(name: "Daehan-Bold", size: 14)!
        pv.messageColor = textColor
        pv.messageTextAlignment = .center
        
        let pcv = PopupDialogContainerView.appearance()
        pcv.frame.size = CGSize(width: 246, height: 138)
        pcv.backgroundColor = UIColor.white
        pcv.shadowEnabled = false
        pcv.cornerRadius = 0
        
        let db = DefaultButton.appearance()
        db.titleFont = UIFont(name: "Daehan-Bold", size: 15)!
        db.titleColor = mainColor2
        db.buttonColor = UIColor.white
        
        let cb = CancelButton.appearance()
        cb.titleFont = UIFont(name: "Daehan-Bold", size: 15)!
        cb.titleColor = UIColor.init(hex: "979797")
        cb.buttonColor = UIColor.white
        
        self.present(popup, animated: true, completion: nil)
    }
    
}



