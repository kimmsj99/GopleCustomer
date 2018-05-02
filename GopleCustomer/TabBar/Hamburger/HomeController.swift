//
//  HomeController.swift
//  GopleCustomer
//
//  Created by 김민주 on 2017. 11. 14..
//  Copyright © 2017년 김민주. All rights reserved.
//

import UIKit
import WebKit
import MapKit
import Alamofire
import PopupDialog

class MainWKProcess {
    static let shared = WKProcessPool()
}

class HomeController: UIViewController, UIScrollViewDelegate {
    
    static var type: Int!
    static var completeAlert = false
    
    var wkWebView = WKWebView()
    
    var viewNavBar = UIView()
    var tmpView = UIView()
    let nTitle = UILabel()
    
    let locationManager = CLLocationManager()
    
    var contractBridge = ""
    
    weak var logoutDelegate: LogoutDelegate?
    
    var id = ""
    var email = ""
    
    var webViewBottom: NSLayoutConstraint!
    
    let tabVC = TabBarController.self
    
    let dday = UILabel()
    let col = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let controller = WKUserContentController()
        controller.add(self, name: "getMemberInfo")
        controller.add(self, name: "setTab")
        controller.add(self, name: "setGPSRedirect")
        controller.add(self, name: "setGPSDataRedirect")
        controller.add(self, name: "onContractAlert")
        controller.add(self, name: "onWebView")
        controller.add(self, name: "offView")
        controller.add(self, name: "setDDay")
        controller.add(self, name: "goLogin")
        
        let configuration = WKWebViewConfiguration()
        configuration.processPool = MainWKProcess.shared
        configuration.userContentController = controller
        
        wkWebView = WKWebView(frame: self.view.frame, configuration: configuration)
        
        wkWebView.scrollView.delegate = self
        wkWebView.scrollView.isScrollEnabled = true
        wkWebView.scrollView.bounces = false
        wkWebView.scrollView.scrollsToTop = true
        wkWebView.uiDelegate = self
        wkWebView.navigationDelegate = self
        
        if (UserDefaults.standard.string(forKey: "id") != nil), (UserDefaults.standard.string(forKey: "email") != nil) {
            id = UserDefaults.standard.string(forKey: "id")!
            email = UserDefaults.standard.string(forKey: "email")!
        }
        
        login(id: id, email: email)
        
        self.view.addSubview(wkWebView)
        
        wkWebView.translatesAutoresizingMaskIntoConstraints = false
        wkWebView.topAnchor.constraint(equalTo: self.view.topAnchor, constant : 44).isActive = true
//        wkWebView.topAnchor.constraint(equalTo: tabVC.customTabBar.bottomAnchor).isActive = true
        wkWebView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        wkWebView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        if #available(iOS 11.0, *) {
            webViewBottom = wkWebView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        } else {
            webViewBottom = wkWebView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 49)
        }
        
        webViewBottom.isActive = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        tabVC.customTabBar.isHidden = false
        tabVC.ddayView.isHidden = false

        UIApplication.shared.statusBarStyle = .default
        UIApplication.shared.isStatusBarHidden = false
        
        requestUserInfo()
        wkWebView.reload()
//        createNavigationBar(backColor: UIColor.white, title: "", titleColor: UIColor.clear, align: .center, btn1: UIButton(), btn2: UIButton(), back: UIButton())
        
        if UserDefaults.standard.object(forKey: "completeAlert") == nil {
            if HomeController.completeAlert == true {
                
                HomeController.completeAlert = false
            }
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest   //정확도를 최고로
        locationManager.requestWhenInUseAuthorization()             //위치데이터를 위해 사용자에게 승인을 요청
        locationManager.startUpdatingLocation()                     //위치업데이트
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
    
    @IBAction func goMap(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mapController = storyboard.instantiateViewController(withIdentifier: "MapController")
        self.navigationController?.pushViewController(mapController, animated: true)
    }
    
    func calculateConstant(_ value : CGFloat) -> CGFloat {
        let v = self.view.frame.width
        return (value / 375) * v
    }
    
}

extension HomeController {
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
        
        guard let lat = UserDefaults.standard.string(forKey: "lat"), let lon = UserDefaults.standard.string(forKey: "lon") else {
            return
        }
        
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
    
//    func goMap(_ sender: UIButton) {
//
//        guard let lat = UserDefaults.standard.string(forKey: "lat"), let lon = UserDefaults.standard.string(forKey: "lon") else {
//            return
//        }
//        let url = URL(string: domain + mapURL)
//        var request = URLRequest(url: url!)
//        request.httpMethod = "POST"
//        let postString = "lat=\(lat)&lon=\(lon)"
//        request.httpBody = postString.data(using: .utf8)
//        wkWebView.load(request)
//        wkWebView.evaluateJavaScript("gRun.setFilterBack()", completionHandler: nil)
//
//    }
    
    func goReview(_ sender: UIButton) {
        wkWebView.evaluateJavaScript("gRun.goReviewWrite()", completionHandler: nil)
    }
    
    func doneBtn(_ sender: UIButton) {
        
        if wkWebView.url != URL(string: domain + homeURL) {
            wkWebView.evaluateJavaScript("back();", completionHandler: { (result, error) in
                if let error = error {
                    print(error)
                } else {
                    self.wkWebView.reload()
                    self.viewNavBar.removeFromSuperview()
                }
            })
        } else {
            self.dismiss(animated: true, completion: nil)
        }
        
    }
}

extension HomeController {
    func popupDialog(title: String, message: String){
        let popup = PopupDialog(title: title, message: message)
        popup.transitionStyle = .bounceDown
        
        let okButton = DefaultButton(title: "확인", height: 48, dismissOnTap: true, action: {
            self.wkWebView.evaluateJavaScript("\(self.contractBridge)()", completionHandler: { (result, error) in
                if let error = error {
                    print("error : \(error)")
                } else {
                    print("result: \(result)")
                }
            })
        })
        let cancelButton = CancelButton(title: "취소", height: 48, dismissOnTap: true, action: nil)
        
        popup.addButtons([cancelButton, okButton])
        popup.buttonAlignment = .horizontal
        
        let pv = PopupDialogDefaultView.appearance()
        pv.titleFont = UIFont(name: "Daehan-Bold", size: 15)!
        pv.titleColor = textColor
        pv.titleTextAlignment = .center
        pv.messageFont = UIFont(name: "Daehan", size: 14)!
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

extension HomeController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)->Void in
            
            if (error != nil) {
                print("Error: \(error)")
                return
            }
            
            if placemarks!.count > 0 {
                let pm = placemarks![0]
                self.displayLocationInfo(placemark: pm)
            } else {
                print("Error with the data.")
            }
        })
        
    }
    
    func displayLocationInfo(placemark: CLPlacemark) {
        
        self.locationManager.stopUpdatingLocation()
        
        print("위도 : \(String(describing: placemark.location?.coordinate.latitude)) / 경도 : \(String(describing: placemark.location?.coordinate.longitude))")
        
        let lat = String(describing: placemark.location!.coordinate.latitude)
        let lon = String(describing: placemark.location!.coordinate.longitude)
        
        UserDefaults.standard.set(lat, forKey: "lat")
        UserDefaults.standard.set(lon, forKey: "lon")
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

extension HomeController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if message.name == "getMemberInfo" {
            print("getMemberInfo : \(message.body)")
            guard let scriptMessage = message.body as? String else {
                self.backLoginView()
                
                return
            }
            
            guard let id = UserDefaults.standard.string(forKey: "id"), let email = UserDefaults.standard.string(forKey: "email") else {
                return
            }
            
            self.convertToDictionary(text: scriptMessage)
            UserDefaults.standard.set("getMemberInfo", forKey: "getMemberInfo")
            requestUserInfo()
        }
        
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
                        btn2.center.y = self.viewNavBar.frame.height / 2
                        btn2.addTarget(self, action: #selector(goSearch(_:)), for: .touchUpInside)
                        
                    } else if scriptBtn2 == "map" {
                        
                        btn2.setImage(#imageLiteral(resourceName: "map"), for: .normal)
                        btn2.frame.size = CGSize(width: 28, height: 44)
                        btn2.frame.origin.x = self.view.frame.width - (btn2.frame.width + 15)
//                        btn2.addTarget(self, action: #selector(goMap(_:)), for: .touchUpInside)
                        
                    } else if scriptBtn2 == "back" {
                        
                    } else if scriptBtn2 == "review" {
                        
                        btn2.setImage(#imageLiteral(resourceName: "review"), for: .normal)
                        btn2.frame.size = CGSize(width: 81, height: 55)
                        btn2.frame.origin.x = self.view.frame.width - (btn2.frame.width + 27)
                        btn2.addTarget(self, action: #selector(goReview(_:)), for: .touchUpInside)
                        
                    } else if scriptBtn2 == "menu" {
                        
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
                
                if let scriptBack = scriptMessage[5] as? Int {
                    if wkWebView.url == URL(string: domain + homeURL) {
                        back.setImage(nil, for: .normal)
                        self.view.layoutIfNeeded()
                    } else {
                        self.view.layoutIfNeeded()
                    }
                }
                
                guard wkWebView.url == URL(string: domain + logout2URL) || wkWebView.url == URL(string: domain + withdrawal2URL) else {
                    return createNavigationBar(backColor: color, title: title, titleColor: titleColor, align: align, btn1: btn1, btn2: btn2, back: back)
                }
            }
        }
            
        if message.name == "setGPSRedirect" {
            print("\(message.name) : \(message.body)")
            
            if let scriptMessage = message.body as? [AnyObject] {
                if let url = scriptMessage[0] as? String {
                    UserDefaults.standard.set(url, forKey: "newWebUrl")
                }
                
                HomeController.type = 0
                HamburgerController.selectIdx = 0
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
            
            if let scriptMessage = message.body as? [AnyObject] {
                if scriptMessage[3] as? Int == 1 {
                    if let url = scriptMessage[0] as? String {
                        print("url : \(url)")
                        UserDefaults.standard.set(url, forKey: "home_url")
                    }
                    
                    if let attr = scriptMessage[1] as? String {
                        print("attr: \(attr)")
                        UserDefaults.standard.set(attr, forKey: "attr")
                    }
                    
                    if let value = scriptMessage[2] as? String {
                        print("value: \(value)")
                        UserDefaults.standard.set(value, forKey: "value")
                    }
                    
                    HomeController.type = 0
                    if let newWebVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeDetailViewController") as? NavigationController {
                        
                        UserDefaults.standard.removeObject(forKey: "newWebUrl")
                        UserDefaults.standard.removeObject(forKey: "share_idx")
                        UserDefaults.standard.removeObject(forKey: "push_url")
                        UserDefaults.standard.removeObject(forKey: "companyWeb")
                        UserDefaults.standard.removeObject(forKey: "companyDetail")
                        
                        self.present(newWebVC, animated: true, completion: nil)
                    }
                }
            }
            
        }
        
        if message.name == "onContractAlert" {
            print("\(message.name) : \(message.body)")
            contractBridge = message.body as! String
            popupDialog(title: "<계약진행>", message: "완료 후 3일 이내에 결제 미완료시\n계약이 진행되지 않을 수 있습니다.")
        }
        
        if message.name == "onWebView" {
            print("\(message.name) : \(message.body)")
            
            guard let lat = UserDefaults.standard.string(forKey: "lat"), let lon = UserDefaults.standard.string(forKey: "lon") else {
                return
            }
            
            if let url = message.body as? String{
                if #available(iOS 11.0, *) {
                    var request = URLRequest(url: URL(string: domain + url)!)
                    request.httpMethod = "POST"
                    let postString = "lat=\(lat)&lon=\(lon)"
                    request.httpBody = postString.data(using: .utf8)
                    wkWebView.load(request)
                } else {
                    locationSettingWebView(url: domain + url, lat: lat, lon: lon, wkWebView: wkWebView)
                }
                webViewBottom.constant = 0
            }
        }
        
        if message.name == "setDDay" {
            print("\(message.name) : \(message.body)")
            
            dday.removeFromSuperview()
            col.removeFromSuperview()
            
            var countDay = ""
            
            if ((message.body as? Int) != nil) {
                let count = message.body as! Int
                countDay = String(count)
            } else {
                countDay = message.body as! String
            }
            
            if countDay.isEmpty {
                dday.text = "예정일을 입력해주세요"
                dday.font = UIFont(name: "Daehan-Bold", size: 13)
                dday.textColor = UIColor.init(hex: "929292")
                dday.sizeToFit()
                dday.frame.origin.x = tabVC.marryLabel.frame.maxX + 3
                dday.center.y = tabVC.ddayView.frame.height / 2
            } else {
                if countDay == "0" {
                    dday.text = "D-Day"
                } else {
                    dday.text = "D-\(countDay)"
                }
                dday.font = UIFont(name: "Daehan-Bold", size: 21)
                dday.textColor = UIColor.init(hex: "1DD7ED")
                dday.sizeToFit()
                dday.frame.origin.x = tabVC.marryLabel.frame.maxX + 6
                dday.center.y = tabVC.ddayView.frame.height / 2
            }
            
            tabVC.ddayView.addSubview(dday)
            
            col.text = "\""
            col.font = UIFont(name: "Daehan-Bold", size: 13)
            col.textColor = UIColor.init(hex: "929292")
            col.sizeToFit()
            col.center.y = tabVC.ddayView.frame.height / 2
            col.frame.origin.x = dday.frame.maxX
            tabVC.ddayView.addSubview(col)
        }
        
        if message.name == "goLogin" {
            print("\(message.name) : \(message.body)")
            
            loginPopupDialog(title: "", message: "회원가입 후 이용해 주시기 바랍니다.")
        }
    }
    
    private func backLoginView() {
        let alert = UIAlertController(title: "데이터 가져오기 실패", message: "다시 로그인 해주세요.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) {
            (_) in
            
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
        }
        
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                let readableJSON = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String: Any]
                
                let idx = readableJSON["idx"] as! String
                let name = readableJSON["name"] as! String
                let phone = readableJSON["phone"] as! String
                
                if let marriage = readableJSON["marriage"] as? String {
                    UserDefaults.standard.set(marriage, forKey: "marriage")
                }
                
                if let recom = readableJSON["recom"] as? String {
                    UserDefaults.standard.set(recom, forKey: "recom")
                }
                
                UserDefaults.standard.set(idx, forKey: "idx")
                UserDefaults.standard.set(name, forKey: "name")
                UserDefaults.standard.set(phone, forKey: "phone")
                
                return readableJSON
                
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}

extension HomeController: WKNavigationDelegate {
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

extension HomeController: WKUIDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        wkWebView.isUserInteractionEnabled = false
        tabVC.customTabBar.isUserInteractionEnabled = false
        
//        SwiftLoader.show(animated: true)
        
        // 2. 상단 status bar에도 activity indicator가 나오게 할 것이다.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        print("메인에서 URL : \(webView.url!)")
        
        wkWebView.isUserInteractionEnabled = true
        tabVC.customTabBar.isUserInteractionEnabled = true
        
//        SwiftLoader.hide()
        
        if webView.url != URL(string: domain + homeURL) {
            tabVC.customTabBar.isHidden = true
            tabVC.ddayView.isHidden = true
        } else {
            tabVC.customTabBar.isHidden = false
            tabVC.ddayView.isHidden = false
        }
        
        if webView.url == URL(string: domain + loginSuccessURL) {
            let url = URL(string: domain + homeURL)
            let request = URLRequest(url: url!)
            wkWebView.load(request)
        }
        
    }
    
}

extension HomeController: LoginDelegate {
    func login(id: String, email: String) {
        
        guard let token = UserDefaults.standard.object(forKey: "token") as? String else {
            return
        }
        
        print("id : \(id) / email : \(email)")
        
        if #available(iOS 11.0, *) {
            var request = URLRequest(url: URL(string: domain + loginSuccessURL)!)
            request.httpMethod = "POST"
            let postString = "id=\(id)&email=\(email)&token=\(token)&device=ios"
            request.httpBody = postString.data(using: .utf8)
            wkWebView.load(request)
            
        } else {
            loginSettingWebView(id: id, email: email, token: token)
        }
        
        if UserDefaults.standard.object(forKey: "how") == nil {
            if let howVC = self.storyboard?.instantiateViewController(withIdentifier: "HowViewController") as? HowViewController {
                HamburgerController.selectIdx = 0
                self.present(howVC, animated: true, completion: nil)
            }
        }
    }
    
    func loginSettingWebView(id: String, email: String, token: String) {
        
        let javascriptPOSTRedirect: String = "" +
            "var form = document.createElement('form');" +
            "form.method = 'POST';" +
            "form.action = '\(domain + loginSuccessURL)';" +
            "" +
            "var input = document.createElement('input');" +
            "input.type = 'text';" +
            "input.name = 'id';" +
            "input.value = '\(id)';" +
            "form.appendChild(input);" +
            "var input = document.createElement('input');" +
            "input.type = 'text';" +
            "input.name = 'email';" +
            "input.value = '\(email)';" +
            "form.appendChild(input);" +
            "var input = document.createElement('input');" +
            "input.type = 'text';" +
            "input.name = 'token';" +
            "input.value = '\(token)';" +
            "form.appendChild(input);" +
            "var input = document.createElement('input');" +
            "input.type = 'text';" +
            "input.name = 'device';" +
            "input.value = 'ios';" +
            "form.appendChild(input);" +
            "" +
        "form.submit();"
        //        print(javascriptPOSTRedirect)
        
        wkWebView.evaluateJavaScript(javascriptPOSTRedirect) { (result, error) in
            if let error = error {
                print(error)
            } else {
                print(result)
            }
        }
    }
}

extension HomeController: LogoutDelegate, WithdrawalDelegate {
    func logout() {
        
//        guard let url = URL(string: domain + logoutURL) else {
//            print("로그아웃 url 잘못 됨")
//            return
//        }
//
//        var idx = ""
//
//        if UserDefaults.standard.object(forKey: "idx") != nil {
//            idx = UserDefaults.standard.object(forKey: "idx") as! String
//        }
//
//        if #available(iOS 11.0, *) {
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//            let postString = "login=\(idx)"
//            request.httpBody = postString.data(using: .utf8)
//            wkWebView.load(request)
//        } else {
//            logoutSettingWebView(idx: idx)
//        }
//
        let request = URLRequest(url: URL(string: domain + logout2URL)!)
        wkWebView.load(request)
        
        removeMemberInfo()
        changeRootVC()
    }
    
    func withdraw(id: String, email: String) {
        
//        if #available(iOS 11.0, *) {
//            var request = URLRequest(url: URL(string: domain + withdrawalURL)!)
//            request.httpMethod = "POST"
//            let postString = "id=\(id)&email=\(email)"
//            request.httpBody = postString.data(using: .utf8)
//            wkWebView.load(request)
//        } else {
//            withdrawSettingWebView(id: id, email: email)
//        }
        
        let request = URLRequest(url: URL(string: domain + withdrawal2URL)!)
        wkWebView.load(request)
        
        removeMemberInfo()
        changeRootVC()
    }
    
    func logoutSettingWebView(idx: String) {
        
        let javascriptPOSTRedirect: String = "" +
            "var form = document.createElement('form');" +
            "form.method = 'POST';" +
            "form.action = '\(domain + logoutURL)';" +
            "" +
            "var input = document.createElement('input');" +
            "input.type = 'text';" +
            "input.name = 'login';" +
            "input.value = '\(idx)';" +
            "form.appendChild(input);" +
            "" +
        "form.submit();"
        //        print(javascriptPOSTRedirect)
        
        wkWebView.evaluateJavaScript(javascriptPOSTRedirect, completionHandler: nil)
    }
    
    func withdrawSettingWebView(id: String, email: String) {
        
        let javascriptPOSTRedirect: String = "" +
            "var form = document.createElement('form');" +
            "form.method = 'POST';" +
            "form.action = '\(domain + withdrawalURL)';" +
            "" +
            "var input = document.createElement('input');" +
            "input.type = 'text';" +
            "input.name = 'id';" +
            "input.value = '\(id)';" +
            "form.appendChild(input);" +
            "var input = document.createElement('input');" +
            "input.type = 'text';" +
            "input.name = 'email';" +
            "input.value = '\(email)';" +
            "form.appendChild(input);" +
            "" +
        "form.submit();"
        //        print(javascriptPOSTRedirect)
        
        wkWebView.evaluateJavaScript(javascriptPOSTRedirect, completionHandler: nil)
    }
    
    private func removeMemberInfo() {
        
        let tlogin = NaverThirdPartyLoginConnection.getSharedInstance()
        tlogin?.resetToken()
        
//        wkWebView.evaluateJavaScript("setIndexDelete()") { (result, error) in
//            if let error = error {
//                print("setIndexDelete error : \(error)")
//            } else {
//                print("setIndexDelete result : \(result)")
//            }
//        }
        
        HTTPCookieStorage.clear()
        UserDefaults.standard.removeObject(forKey: "id")
        UserDefaults.standard.removeObject(forKey: "email")
        UserDefaults.standard.removeObject(forKey: "idx")
        UserDefaults.standard.removeObject(forKey: "name")
        UserDefaults.standard.removeObject(forKey: "phone")
        UserDefaults.standard.removeObject(forKey: "marriage")
        UserDefaults.standard.removeObject(forKey: "recom")
        UserDefaults.standard.removeObject(forKey: "getMemberInfo")
        UserDefaults.standard.removeObject(forKey: "how")
        UserDefaults.standard.removeObject(forKey: "completeAlert")
        
//        TabBarController.customTabBar.removeFromSuperview()
        TabBarController.ddayView.removeFromSuperview()
        dday.removeFromSuperview()
        col.removeFromSuperview()
        
        self.wkWebView.evaluateJavaScript("localStorage.getItem('index_login')") { (result, error) in
            if let error = error {
                print(error)
            } else {
                print("localstorage : \(result as! String)")
            }
        }
        
    }
    
    private func changeRootVC() {
        
        if let loginController = self.storyboard?.instantiateViewController(withIdentifier: "LoginController") as? LoginController {
            var option = UIWindow.TransitionOptions(direction: .toTop, style: .easeInOut)
            option.duration = 0.5
            UIApplication.shared.keyWindow?.setRootViewController(loginController, options: option)
        }
        
    }
}

extension HomeController {
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
        
        let cancelButton = CancelButton(title: "취소", height: 48, dismissOnTap: true, action: nil)
        
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
