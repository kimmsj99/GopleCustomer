//
//  HomeDetailViewController.swift
//  GopleCustomer
//
//  Created by 김민주 on 2017. 12. 11..
//  Copyright © 2017년 김민주. All rights reserved.
//

import UIKit
import WebKit
import MapKit
import Alamofire
import PopupDialog
import DKImagePickerController

class HomeDetailViewController: UIViewController, UIScrollViewDelegate {
    
    var wkWebView = WKWebView()
    
    var viewNavBar = UIView()
    var tmpView = UIView()
    let nTitle = UILabel()
    var setTabTitle = ""
    
    weak var logoutDelegate: LogoutDelegate?
    
    var picker = UIImagePickerController()
    let pickerController = DKImagePickerController()
    
    var imageData: Data?
    var imageDataArr = [Data]()
    var assets: [DKAsset]?
    
    let locationManager = CLLocationManager()
    
    let lat = UserDefaults.standard.object(forKey: "lat") as! String
    let lon = UserDefaults.standard.object(forKey: "lon") as! String
    
    let filterBut = UIButton()
    
    static var filterFunc = ""
    
    var search = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let controller = WKUserContentController()
        controller.add(self, name: "setTab")
        controller.add(self, name: "setGPSRedirect")
        controller.add(self, name: "setGPSDataRedirect")
        controller.add(self, name: "onBack")
        controller.add(self, name: "onCall")
        controller.add(self, name: "onLoadText")
        controller.add(self, name: "setFileUpload")
        controller.add(self, name: "onKeyboard")
        controller.add(self, name: "offKeyboard")
        controller.add(self, name: "onShare")
        controller.add(self, name: "reload")
        controller.add(self, name: "goLogin")
        controller.add(self, name: "offCategory")
        
        let configuration = WKWebViewConfiguration()
        configuration.processPool = MainWKProcess.shared
        configuration.userContentController = controller
        
        wkWebView = WKWebView(frame: self.view.frame, configuration: configuration)
        
        wkWebView.scrollView.delegate = self
        wkWebView.scrollView.bounces = false
        wkWebView.scrollView.isScrollEnabled = true
        wkWebView.scrollView.scrollsToTop = true
        wkWebView.uiDelegate = self
        wkWebView.navigationDelegate = self
        
        guard let home_url = UserDefaults.standard.object(forKey: "home_url") as? String, let home_attr = UserDefaults.standard.object(forKey: "attr") as? String, let home_value = UserDefaults.standard.object(forKey: "value") as? String else {
            return
        }
        
        if #available(iOS 11.0, *) {
            let url = URL(string: domain + home_url)
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            let postString = "\(home_attr)=\(home_value)&lat=\(lat)&lon=\(lon)"
            request.httpBody = postString.data(using: .utf8)
            wkWebView.load(request)
        } else {
            settingWebView(url: domain + home_url, attr: home_attr, value: home_value, lat: lat, lon: lon)
        }
        
        self.view.addSubview(wkWebView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(noti:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        wkWebView.translatesAutoresizingMaskIntoConstraints = false
        wkWebView.topAnchor.constraint(equalTo: self.view.topAnchor, constant : 14).isActive = true
        wkWebView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        wkWebView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        webViewBottomConstraint = wkWebView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        webViewBottomConstraint.isActive = true
        
        print("keyboard hidden = \(webViewBottomConstraint.constant)")
        

        // Do any additional setup after loading the view.
    }
    
    var webViewBottomConstraint : NSLayoutConstraint!
    
    func keyboardWillShow(noti: Notification) {
        
        var userInfo = noti.userInfo
        let keyboardSize: CGSize = ((userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size)!
        
        let webViewBottomConstant = keyboardSize.height
        
        UIView.animate(withDuration: 1.3) {
            self.webViewBottomConstraint.constant = -webViewBottomConstant
            self.view.layoutIfNeeded()
        }
        
        print("keyboard show = \(webViewBottomConstraint.constant)")
        
    }
    
    func keyboardWillHide(noti: Notification) {
        
        UIView.animate(withDuration: 1.3) {
            self.webViewBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if NewWebViewController.isDismiss == true {
            if let tabbarVC = self.presentingViewController as? TabBarController {
                tabbarVC.nextIdx = HamburgerController.selectIdx
                NewWebViewController.isDismiss = false
            }
            self.dismiss(animated: false, completion: nil)
        }
        
//        self.wkWebView.evaluateJavaScript("reload()", completionHandler: { (result, error) in
//            if let error = error {
//                print(error)
//            } else {
//                print(result)
//            }
//        })
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest   //정확도를 최고로
        locationManager.requestWhenInUseAuthorization()             //위치데이터를 위해 사용자에게 승인을 요청
        locationManager.startUpdatingLocation()                     //위치업데이트
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if HomeDetailViewController.filterFunc != "" {
            self.wkWebView.evaluateJavaScript("\(HomeDetailViewController.filterFunc)()", completionHandler: { (result, error) in
                if let error = error {
                    print(error)
                } else {
                    print(result)
                    HomeDetailViewController.filterFunc = ""
                }
            })
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
    
    func calculateConstant(_ value : CGFloat ) -> CGFloat {
        let v = self.view.frame.width
        return (value / 375) * v
    }
}

extension HomeDetailViewController {
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
    
    func createFilterButton() {
        filterBut.setImage(#imageLiteral(resourceName: "filter_back_sh"), for: .normal)
        filterBut.frame.size = CGSize(width: calculateConstant(91), height: calculateConstant(53))
        filterBut.center.x = self.view.frame.width / 2
        filterBut.frame.origin.y = self.view.frame.height - (39 + filterBut.frame.height)
        filterBut.addTarget(self, action: #selector(filteringAction(_:)), for: .touchUpInside)
        
        let filterImg = UIImageView(image: #imageLiteral(resourceName: "f_filter"))
        filterImg.frame.size = CGSize(width: calculateConstant(16), height: calculateConstant(12))
        filterImg.center.y = filterBut.frame.height / 2
        filterImg.frame.origin.x = calculateConstant(24)
        filterBut.addSubview(filterImg)
        
        let f_label = UILabel()
        f_label.text = "필터"
        f_label.font = UIFont(name: "Daehan-Bold", size: 12)
        f_label.textColor = UIColor.init(hex: "3b3b3b")
        f_label.sizeToFit()
        f_label.center.y = filterBut.frame.height / 2
        f_label.frame.origin.x = filterImg.frame.maxX + 5
        filterBut.addSubview(f_label)
        
        self.view.addSubview(filterBut)
    }
    
    func goSearch(_ sender: UIButton) {
        
        search = true
        
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
        
        if let id = UserDefaults.standard.object(forKey: "id") as? String{
            if id == "guest" {
                loginPopupDialog(title: "", message: "회원가입 후 이용해 주시기 바랍니다.")
            } else {
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
        }
        
    }
    
    func goReview(_ sender: UIButton) {
        if let id = UserDefaults.standard.object(forKey: "id") as? String{
            if id == "guest" {
                loginPopupDialog(title: "", message: "회원가입 후 이용해 주시기 바랍니다.")
            } else {
                wkWebView.evaluateJavaScript("gRun.goReviewWrite()", completionHandler: nil)
            }
        }
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
    
    func filteringAction(_ sender: UIButton) {
        print("필터링")
        wkWebView.evaluateJavaScript("goFilter()") { (result, error) in
            if let error = error {
                print(error)
            } else {
                print(result)
            }
        }
    }
    
    func doneBtn(_ sender: UIButton) {
//        guard let home_url = UserDefaults.standard.object(forKey: "home_url") as? String else {
//            return
//        }
        
//        if wkWebView.url != URL(string: domain + home_url) {
        if wkWebView.canGoBack {
            wkWebView.evaluateJavaScript("back();", completionHandler: { (result, error) in
                if let error = error {
                    print(error)
                } else {
                    self.wkWebView.reload()
                    print(result)
                }
            })
        } else {
            if search == true {
                wkWebView.evaluateJavaScript("back();", completionHandler: { (result, error) in
                    if let error = error {
                        print(error)
                    } else {
                        self.wkWebView.reload()
                        self.search = false
//                        print(result)
                    }
                })
            } else {
                if let tabbarVC = self.presentingViewController as? TabBarController {
                    tabbarVC.nextIdx = 0
                }
                self.dismiss(animated: true, completion: nil)
                TabBarController.customTabBar.isHidden = false
            }
        }
    }
}

extension HomeDetailViewController : CLLocationManagerDelegate {
    
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

extension HomeDetailViewController: WKScriptMessageHandler {
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
            let calc = UIButton()
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
                        
                    } else if scriptBtn2 == "filter" {
                        btn2.setImage(#imageLiteral(resourceName: "search_delete"), for: .normal)
                        btn2.frame.size = CGSize(width: 47, height: 46)
                        btn2.frame.origin = CGPoint(x: self.view.frame.width - (btn2.frame.width + 3), y: 7)
                        btn2.addTarget(self, action: #selector(filterBack(_:)), for: .touchUpInside)
                        
                    }
                }
                
                if let scriptBtn1 = scriptMessage[3] as? String {
                    if scriptBtn1 == "search" {
                        
                        btn1.frame.size = CGSize(width: 35, height: 44)
                        btn1.frame.origin.x = btn2.frame.minX - (3 + btn1.frame.width)
                        btn1.addTarget(self, action: #selector(goSearch(_:)), for: .touchUpInside)
                        
                        calc.setImage(#imageLiteral(resourceName: "home"), for: .normal)
                        calc.frame.size = CGSize(width: 34, height: 30)
                        calc.frame.origin.x = btn1.frame.minX - calc.frame.width
                        calc.addTarget(self, action: #selector(goHome(_:)), for: .touchUpInside)
                        
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
                calc.center.y = viewNavBar.frame.height / 2
                viewNavBar.addSubview(calc)
            }
        }
        
        if message.name == "setGPSRedirect" {
            print("\(message.name) : \(message.body)")
            if let scripteMessage = message.body as? [AnyObject] {
                //                [/index/data/detail/82, 0]
                
                if let url = scripteMessage[0] as? String {
                    
                    UserDefaults.standard.set(url, forKey: "companyDetail")
                    
                    if let newWebVC = self.storyboard?.instantiateViewController(withIdentifier: "NewWebViewController") as? NavigationController {
                        self.present(newWebVC, animated: true, completion: nil)
                    }
                    
//                    let rurl = URL(string: domain + url)
//                    let request = URLRequest(url: rurl!)
//                    wkWebView.load(request)
                }
            }
        }
        
        if message.name == "setGPSDataRedirect" {
            print("\(message.name) : \(message.body)")
            
            if let scriptMessage = message.body as? [AnyObject] {
                
                var url = ""
                var attr = ""
                var value = ""
                
                if let scriptUrl = scriptMessage[0] as? String {
                    url = scriptUrl
                }
                
                if let scriptAttr = scriptMessage[1] as? String {
                    attr = scriptAttr
                }
                
                if let scriptValue = scriptMessage[2] as? String {
                    value = scriptValue
                }
                
                if #available(iOS 11.0, *) {
                    let uurl = URL(string: domain + url)
                    var request = URLRequest(url: uurl!)
                    request.httpMethod = "POST"
                    let postString = "\(attr)=\(value)&lat=\(lat)&lon=\(lon)"
                    request.httpBody = postString.data(using: .utf8)
                    wkWebView.load(request)
                } else {
                    settingWebView(url: domain + url, attr: attr, value: value, lat: lat, lon: lon)
                }
                
            }
        }
        
        if message.name == "onBack" {
            print("\(message.name) : \(message.body)")
            wkWebView.evaluateJavaScript("back();", completionHandler: { (result, error) in
                if let error = error {
                    print(error)
                } else {
                    self.wkWebView.reload()
                }
            })
        }
        
        if message.name == "onCall" {
            print("\(message.name) : \(message.body)")
            if let phone = message.body as? String {
                if let url = URL(string: "tel://\(phone)"), UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(url)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }

            }
        }
        
        if message.name == "onLoadText" {
            print("\(message.name) : \(message.body)")
        }
        
        if message.name == "setFileUpload" {
            print("\(message.name) : \(message.body)")
        
            let alert = UIAlertController(title: "이미지 등록", message: nil, preferredStyle: .actionSheet)
            
            let cameraAction = UIAlertAction(title: "사진 촬영하기", style: .default) { (action) in
                self.openCamera()
                
            }
            
            let galleryAction = UIAlertAction(title: "앨범에서 찾기", style: .default) { (action) in
                self.openPhotoLibrary()
                
            }
            
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            
            picker.delegate = self
            
            alert.addAction(cameraAction)
            alert.addAction(galleryAction)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)
        }
        
        if message.name == "onKeyboard" {
            print("\(message.name) : \(message.body)")
        }
        
        if message.name == "offKeyboard" {
            print("\(message.name) : \(message.body)")
        }
        
        if message.name == "onShare" {
            print("\(message.name) : \(message.body)")
            
            let idx = message.body as! Int
            let url = URL(string: domain + shareURL + "/\(idx)")!
            
            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            
            self.present(activityVC, animated: true, completion: nil)
        }
        
        if message.name == "reload" {
            print("\(message.name) : \(message.body)")
        }
        
        if message.name == "goLogin" {
            print("\(message.name) : \(message.body)")
            
            loginPopupDialog(title: "", message: "회원가입 후 이용해 주시기 바랍니다.")
        }
        
        if message.name == "offCategory" {
            print("\(message.name) : \(message.body)")
            
            UserDefaults.standard.removeObject(forKey: "completeAlert")
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension HomeDetailViewController: WKNavigationDelegate {
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

extension HomeDetailViewController: WKUIDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        wkWebView.isUserInteractionEnabled = false
        
        viewNavBar.removeFromSuperview()
        
        // 2. 상단 status bar에도 activity indicator가 나오게 할 것이다.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        wkWebView.isUserInteractionEnabled = true
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        guard let home_url = UserDefaults.standard.object(forKey: "home_url") as? String else {
            return
        }
        
        if wkWebView.url != URL(string: domain + home_url) {
            filterBut.removeFromSuperview()
        } else {
            if search == true {
                filterBut.removeFromSuperview()
            } else {
                createFilterButton()
            }
        }
    
        if webView.url == URL(string: domain + mapURL) {
            UIApplication.shared.statusBarStyle = .default
            
        }
        
    }
    
}

extension HomeDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func openCamera() {
        
        let pickerController = DKImagePickerController()
        pickerController.sourceType = .camera
        pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
            for each in assets {
                each.fetchImageDataForAsset(true, completeBlock: { (data, result) in
                    if let data = data {
                        self.imageDataArr.append(data)
                    }
                })
            }
            self.uploadImages(self.imageDataArr)
        }
        self.present(pickerController, animated: true, completion: nil)
    }
    
    func openPhotoLibrary() {
        let pickerController = DKImagePickerController()
        pickerController.assetType = .allPhotos
        pickerController.showsCancelButton = true
        pickerController.maxSelectableCount = 5
        pickerController.singleSelect = true
        pickerController.defaultSelectedAssets = self.pickerController.selectedAssets
        pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
            for each in assets {
                each.fetchImageDataForAsset(true, completeBlock: { (data, result) in
                    if let data = data {
                        self.imageDataArr.append(data)
                    }
                })
            }
            self.uploadImages(self.imageDataArr)
        }
        
        self.present(pickerController, animated: true, completion: nil)
    }
    
    func uploadImages(_ dataArray: [Data]) {
        let headers = [
            "Content-Type": "application/json"
        ]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (i, data) in dataArray.enumerated() {
                print(i, data)
                multipartFormData.append(data, withName: "file[\(i)]", fileName: "image.jpg", mimeType: "image/jpeg")
            }
        }, to: domain + imgUpladURL,
           method: .post,
           headers: headers) { (result) in
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    print("Succesfully uploaded")
                    //                    print("result : \(result)")
                    //                    print("response : \(response)")
                    print(response.result.value)
                    
                    if let imgs = response.result.value as? [[String : String]] {
                        print(imgs)
                        print(response.value!)
                        var imageUrlArray = [String]()
                        
                        for img in imgs {
                            imageUrlArray.append(img["src"]!)
                        }
                        let imageParameter = imageUrlArray.joined(separator: ",")
                        print("\(imageParameter)")
                        self.wkWebView.evaluateJavaScript("gRun.iOSfilePaging('\(imageParameter)')") { result, error in
                            if let error = error {
                                self.imageDataArr.removeAll()
                                print(error)
                            } else {
                                self.imageDataArr.removeAll()
                                print(result)
                            }
                        }
                        
                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
            }
        }
    }
}

extension HomeDetailViewController {
    func settingWebView(url: String, attr: String, value: String, lat: String, lon: String) {
        
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

extension HomeDetailViewController {
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
            if let tabbarVC = self.presentingViewController as? TabBarController {
                tabbarVC.nextIdx = 0
                self.dismiss(animated: true, completion: nil)
            }
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


