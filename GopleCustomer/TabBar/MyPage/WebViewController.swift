//
//  TextController.swift
//  GopleCustomer
//
//  Created by 김민주 on 2017. 11. 29..
//  Copyright © 2017년 김민주. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, UIScrollViewDelegate {
    
    var wkWebView = WKWebView()
    
    var viewNavBar = UIView()
    var tmpView = UIView()
    let nTitle = UILabel()
    
    var url = ""
    
    var lat = ""
    var lon = ""
    
    let datePicker = UIDatePicker()
    let pickerParentView = UIView()
    
    var yearDate: Int = 0
    var monthDate: Int = 0
    
    var webViewBottom: NSLayoutConstraint!
    
    static var calenderType = ""
    
    static var calenderFunc = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        let config = WKWebViewConfiguration()
        config.userContentController.add(self, name: "setTab")
        config.userContentController.add(self, name: "setGPSRedirect")
        config.userContentController.add(self, name: "setGPSDataRedirect")
        config.userContentController.add(self, name: "onLoadDate")
        config.userContentController.add(self, name: "onWebView")
        config.userContentController.add(self, name: "runBackView")
        
        wkWebView = WKWebView(frame: self.view.frame, configuration: config)
        
        wkWebView.uiDelegate = self
        wkWebView.navigationDelegate = self
        wkWebView.scrollView.delegate = self
        wkWebView.scrollView.isScrollEnabled = true
        wkWebView.scrollView.bounces = false
        
        if UserDefaults.standard.object(forKey: "lat") != nil, UserDefaults.standard.object(forKey: "lon") != nil {
            lat = UserDefaults.standard.object(forKey: "lat") as! String
            lon = UserDefaults.standard.object(forKey: "lon") as! String
        }
        
        if let webView = UserDefaults.standard.object(forKey: "webView") as? String {
            print(webView)
            if webView == "schedule" {
//                createNavigationBar(naviTitle: "캘린더")
                url = domain + scheduleURL
            } else if webView == "suggest" {
//                createNavigationBar(naviTitle: "추천인")
                url = domain + suggestURL
            } else if webView == "notice"{
//                createNavigationBar(naviTitle: "공지사항")
                url = domain + noticeURL
            } else if webView == "service2" {
//                createNavigationBar(naviTitle: "서비스 이용약관")
                url = domain + serviceURL
            } else if webView == "privacy" {
//                createNavigationBar(naviTitle: "개인정보 처리 방침")
                url = domain + privacyURL
            } else if webView == "location" {
//                createNavigationBar(naviTitle: "위치기반 서비스 동의서")
                url = domain + locationURL
            } else if webView == "how" {
                url = domain + locationURL
            }
        }
        
        let request = URLRequest(url: URL(string : url)!)
        wkWebView.load(request)
        
        self.view.addSubview(wkWebView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(noti:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        wkWebView.translatesAutoresizingMaskIntoConstraints = false
        wkWebView.topAnchor.constraint(equalTo: self.view.topAnchor, constant : 14).isActive = true
        wkWebView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        wkWebView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        if #available(iOS 11.0, *) {
            webViewBottom = wkWebView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        } else {
            webViewBottom = wkWebView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant : 49)
        }
        
        webViewBottom.isActive = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if wkWebView.url != URL(string : domain + scheduleURL) {
            wkWebView.reload()
        }
        
        UIApplication.shared.statusBarStyle = .default
        
    }
    
    func keyboardWillShow(noti: Notification) {
        
        var userInfo = noti.userInfo
        let keyboardSize: CGSize = ((userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size)!
        
        let webViewBottomConstant = keyboardSize.height
        
        UIView.animate(withDuration: 0.5) {
            self.webViewBottom.constant = -webViewBottomConstant
            self.view.layoutIfNeeded()
        }
        
        print("keyboard show = \(webViewBottom.constant)")
        
    }
    
    func keyboardWillHide(noti: Notification) {
        
        UIView.animate(withDuration: 0.5) {
            self.webViewBottom.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
    
}

extension WebViewController {
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
        
        let url = URL(string: domain + searchWeddingURL)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        let postString = "lat=\(lat)&lon=\(lon)"
        request.httpBody = postString.data(using: .utf8)
        wkWebView.load(request)
        
    }
    
    func goMap(_ sender: UIButton) {
        
        let url = URL(string: domain + mapURL)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        let postString = "lat=\(lat)&lon=\(lon)"
        request.httpBody = postString.data(using: .utf8)
        wkWebView.load(request)
        wkWebView.evaluateJavaScript("gRun.setFilterBack()", completionHandler: nil)
        
    }
    
    func goReview(_ sender: UIButton) {
        wkWebView.evaluateJavaScript("gRun.goReviewWrite()", completionHandler: nil)
    }
    
    func showMenu(_ sender: UIButton) {
        HamburgerController.selectIdx = 4
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
        if wkWebView.canGoBack {
            
            if wkWebView.url != URL(string: domain + noticeURL + "#") {
                
                wkWebView.evaluateJavaScript("window.history.go(-1);", completionHandler: { (result, error) in
                    if let error = error {
                        print(error)
                    } else {
                        self.wkWebView.reload()
                        print(result)
                    }
                })
                
            } else {
                self.navigationController?.popViewController(animated: true)
                viewNavBar.removeFromSuperview()
            }
            
        } else {
            if ((self.presentingViewController as? JoinController) != nil) {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.navigationController?.popViewController(animated: true)
                viewNavBar.removeFromSuperview()
            }
        }
//        guard let home_url = UserDefaults.standard.object(forKey: "home_url") as? String else {
//            return
//        }
//
//        if wkWebView.url != URL(string: domain + home_url) {
//            wkWebView.evaluateJavaScript("window.history.go(-1);", completionHandler: { (result, error) in
//                if let error = error {
//                    print(error)
//                } else {
//                    self.wkWebView.reload()
//                    print(result)
//                }
//            })
//        } else {
//            self.dismiss(animated: true, completion: nil)
//        }
    }
}

extension WebViewController: WKScriptMessageHandler {
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
                        btn2.setImage(#imageLiteral(resourceName: "black_4041"), for: .normal)
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
                        
                    }
                }
                
                createNavigationBar(backColor: color, title: title, titleColor: titleColor, align: align, btn1: btn1, btn2: btn2, back: back)
            }
        }
        
        if message.name == "setGPSRedirect" {
            print("\(message.name) : \(message.body)")
            
            if let scripteMessage = message.body as? [AnyObject] {
                //                [/index/data/detail/82, 0]
                
                if let type = scripteMessage[1] as? Int {
                    if type == 4 {
                        if let funcName = scripteMessage[0] as? String {
                            WebViewController.calenderFunc = funcName
                            if let tabbarVC = self.presentingViewController as? TabBarController {
                                if WebViewController.calenderType == "web" {
                                    tabbarVC.nextIdx = 4
                                    
                                } else if WebViewController.calenderType == "newweb" {
                                    tabbarVC.nextIdx = 3
                                    
                                }
                                
                            }
                            
                            UIApplication.shared.statusBarStyle = .default
                            self.dismiss(animated: true, completion: nil)
                            
                        }
                    } else {
                        if let url = scripteMessage[0] as? String {
                            
                            //캘린더 -> 개인
                            let Weburl = URL(string: "http://gople.ghsoft.kr/index/bookmark/schedule/person")
                            
                            if wkWebView.url == Weburl {
                                UserDefaults.standard.set(url, forKey: "newWebUrl_n")
                                
                                if let newWebVC = self.storyboard?.instantiateViewController(withIdentifier: "CalenderViewController") as? NavigationController {
                                    self.present(newWebVC, animated: true, completion: nil)
                                }
                                
                            } else {
                                UserDefaults.standard.set(url, forKey: "companyDetail")
                                HomeController.type = 4
                                HamburgerController.selectIdx = 4
                                if let newWebVC = self.storyboard?.instantiateViewController(withIdentifier: "NewWebViewController") as? NavigationController {
                                    self.present(newWebVC, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                }
                
                if wkWebView.url == URL(string: domain + suggestURL) {
                    var strUrl = ""
                    var strIdx: Int!
                    
                    if let scriptUrl = scripteMessage[0] as? String {
                        strUrl = scriptUrl
                    }
                    
                    if let scriptIdx = scripteMessage[0] as? Int {
                        strIdx = scriptIdx
                    }
                    
                    let request = URLRequest(url: URL(string : domain + strUrl + "/\(strIdx)")!)
                    wkWebView.load(request)
                    
                }
            }
        }
        
        if message.name == "setGPSDataRedirect" {
            print("\(message.name) : \(message.body)")
            
        }
        
        if message.name == "onLoadDate" {
            print("\(message.name) : \(message.body)")
            
            let date = message.body as! String
            let index = date.index(date.startIndex, offsetBy: 4)
            
            let year = date.substring(to: index)
            
            let start = date.index(date.startIndex, offsetBy: 5)
            let end = date.index(date.endIndex, offsetBy: 0)
            let length = start..<end
            
            let month = date.substring(with: length)
            
            print(year)
            print(month)
            
            self.yearDate = Int(year)!
            self.monthDate = Int(month)!
            
            let monthYearPicker = MonthYearPickerView()
            monthYearPicker.onDateSelected = { (month: Int, year: Int) in
                let string = String(format: "%02d/%d", month, year)
                print(string)
                print("year: \(year)")
                print("month: \(month)")
                
                self.yearDate = year
                self.monthDate = month
            }
            
            let pickerParentOriginY = self.view.frame.height
            let pickerParentY = self.view.frame.height - 300 + 44
            
            monthYearPicker.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 256)
            monthYearPicker.backgroundColor = UIColor.white
            
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            
            let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(monthDonePressed(_:)))
            toolbar.setItems([flexBarButton, doneButton], animated: false)
            
            pickerParentView.frame = CGRect(x: 0, y: pickerParentOriginY, width: self.view.frame.width, height: 300)
            pickerParentView.addSubview(monthYearPicker)
            pickerParentView.addSubview(toolbar)
            
            wkWebView.addSubview(pickerParentView)
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.pickerParentView.frame.origin.y = pickerParentY
                
            }, completion: { (success) in
                if success {
                    print("애니메이션 완료")
                }
            })
        }
        
        if message.name == "onWebView" {
            print("\(message.name) : \(message.body)")
            
            
        }
        
        if message.name == "runBackView" {
            print("\(message.name) : \(message.body)")
            
            if let scriptMessage = message.body as? [AnyObject] {
                if let type = scriptMessage[1] as? Int {
                    if type == 3 {
                        if let jsFunc = scriptMessage[0] as? String {
                            HomeDetailViewController.filterFunc = jsFunc
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
            
            wkWebView.evaluateJavaScript("\(WebViewController.calenderFunc)()", completionHandler: { (result, error) in
                if let error = error {
                    print(error)
                } else {
                    print(result)
                }
            })
        }
    }
    
    func monthDonePressed(_ sender: Any) {
        
        wkWebView.evaluateJavaScript("gRun.setCalendarData('\(yearDate)', '\(monthDate)')", completionHandler: { (result, error) in
            if let error = error {
                print(error)
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    
                    self.pickerParentView.frame.origin.y = self.view.frame.height
                    
                }, completion: { (success) in
                    if success {
                        self.pickerParentView.removeFromSuperview()
                        print("애니메이션 완료")
                    }
                })
            }
        })
    }
}

extension WebViewController: WKNavigationDelegate {
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

extension WebViewController: WKUIDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        // 2. 상단 status bar에도 activity indicator가 나오게 할 것이다.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        print("webview URL: \(webView.url!)")
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
    }
}
