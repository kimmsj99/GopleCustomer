//
//  HomeNoticeViewController.swift
//  GopleCustomer
//
//  Created by 김민주 on 2017. 12. 13..
//  Copyright © 2017년 김민주. All rights reserved.
//

import UIKit
import WebKit
import MapKit
import Alamofire
import PopupDialog
import DKImagePickerController

class NewWebViewController: UIViewController, UIScrollViewDelegate {
    var tempList : WKBackForwardList?
    
    var wkWebView = WKWebView()
    
    var viewNavBar = UIView()
    var tmpView = UIView()
    let nTitle = UILabel()
    
    weak var logoutDelegate: LogoutDelegate?
    
    let locationManager = CLLocationManager()
    
    let lat = UserDefaults.standard.object(forKey: "lat") as! String
    let lon = UserDefaults.standard.object(forKey: "lon") as! String
    
    let datePicker = UIDatePicker()
    let pickerParentView = UIView()
    
    var yearDate: Int = 0
    var monthDate: Int = 0
    
    var contractBridge = ""
    var webViewBottom: NSLayoutConstraint!
    
    var picker = UIImagePickerController()
    let pickerController = DKImagePickerController()
    
    var imageData: Data?
    var imageDataArr = [Data]()
    var assets: [DKAsset]?
    
    var historyArr: [WKBackForwardListItem]?
    
    static var isDismiss = false

    override func viewDidLoad() {
        super.viewDidLoad()
            
        let config = WKWebViewConfiguration()
        
        config.processPool = MainWKProcess.shared
        
        config.userContentController.add(self, name: "setTab")              //탭 바꾸기
        config.userContentController.add(self, name: "setGPSRedirect")      //
        config.userContentController.add(self, name: "setGPSDataRedirect")  //
        config.userContentController.add(self, name: "onLoadDateSet")       //
        config.userContentController.add(self, name: "onLoadDate")          //
        config.userContentController.add(self, name: "onAlarmAlert")        //
        config.userContentController.add(self, name: "onBack")              //뒤로가기
        config.userContentController.add(self, name: "onCall")              //전화걸기
        config.userContentController.add(self, name: "onLoadText")
        config.userContentController.add(self, name: "setFileUpload")       //이미지 업로드
        config.userContentController.add(self, name: "offView")             //뷰닫기
        config.userContentController.add(self, name: "onShare")             //공유하기
        config.userContentController.add(self, name: "onWebView")           //웹 띄우기
        config.userContentController.add(self, name: "runBackView")         //
        config.userContentController.add(self, name: "goLogin")             //게스트 로그인
        config.userContentController.add(self, name: "selectWish")          //찜하기
        
        wkWebView = WKWebView(frame: self.view.frame, configuration: config)
        
        wkWebView.uiDelegate = self
        wkWebView.navigationDelegate = self
        wkWebView.scrollView.delegate = self
        wkWebView.scrollView.bounces = false
        wkWebView.scrollView.isScrollEnabled = false
        
        if UserDefaults.standard.object(forKey: "companyWeb") != nil {
            whichWebView()
        }
        
        if UserDefaults.standard.string(forKey: "companyDetail") != nil {
            if UserDefaults.standard.object(forKey: "companyWeb") != nil {
                whichWebView()
            } else {
                if UserDefaults.standard.object(forKey: "newWebUrl") != nil {
                    whichWebView()
                } else {
                    let companyDetail = UserDefaults.standard.string(forKey: "companyDetail")!
                    if #available(iOS 11.0, *) {
                        let url = URL(string: domain + companyDetail)
                        var request = URLRequest(url: url!)
                        request.httpMethod = "POST"
                        let postString = "lat=\(lat)&lon=\(lon)"
                        request.httpBody = postString.data(using: .utf8)
                        wkWebView.load(request)
                    } else {
                        locationSettingWebView(url: domain + companyDetail, lat: lat, lon: lon, wkWebView: wkWebView)
                    }
                }
                
            }
            
        } else {
            whichWebView()
        }
        
        self.view.addSubview(wkWebView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(noti:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        wkWebView.translatesAutoresizingMaskIntoConstraints = false
        wkWebView.topAnchor.constraint(equalTo: self.view.topAnchor, constant : 14).isActive = true
        wkWebView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        wkWebView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        webViewBottom = wkWebView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        webViewBottom.isActive = true

        // Do any additional setup after loading the view.
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
        
        UIApplication.shared.statusBarStyle = .default
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest   //정확도를 최고로
        locationManager.requestWhenInUseAuthorization()             //위치데이터를 위해 사용자에게 승인을 요청
        locationManager.startUpdatingLocation()                     //위치업데이트
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if WebViewController.calenderFunc != "" {
            wkWebView.evaluateJavaScript("\(WebViewController.calenderFunc)()", completionHandler: { (result, error) in
                if let error = error {
                    print(error)
                } else {
                    print(result)
                    WebViewController.calenderFunc = ""
                }
            })
        }
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
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
    
    func whichWebView() {
        var url = ""
        
        if UserDefaults.standard.object(forKey: "home_url") != nil {
            if UserDefaults.standard.string(forKey: "companyWeb") != nil {
                
                let companyWeb = UserDefaults.standard.string(forKey: "companyWeb")!
//                url = URL(string: companyWeb)
                url = companyWeb
                
                let back = UIButton()
                back.frame = CGRect(x: 9, y: 14, width: 42, height: 31)
                back.setImage(#imageLiteral(resourceName: "back_black"), for: .normal)
                back.addTarget(self, action: #selector(doneBtn(_:)), for: .touchUpInside)
                UIApplication.shared.statusBarStyle = .default
                createNavigationBar(backColor: UIColor.white, title: "", titleColor: UIColor.clear, align: .center, btn1: UIButton(), btn2: UIButton(), back: back)
            }
            
        } else if UserDefaults.standard.object(forKey: "share_idx") != nil {
            let share_idx = UserDefaults.standard.object(forKey: "share_idx") as! String
//            url = URL(string: domain + comDetailURL + "/\(share_idx)")
            url = domain + comDetailURL + "/\(share_idx)"
            
        } else if UserDefaults.standard.string(forKey: "newWebUrl") != nil{
            
            if UserDefaults.standard.string(forKey: "companyWeb") != nil {
                let companyWeb = UserDefaults.standard.string(forKey: "companyWeb")!
//                url = URL(string: companyWeb)
                url = companyWeb
                
                let back = UIButton()
                back.frame = CGRect(x: 9, y: 14, width: 42, height: 31)
                back.setImage(#imageLiteral(resourceName: "back_black"), for: .normal)
                back.addTarget(self, action: #selector(doneBtn(_:)), for: .touchUpInside)
                UIApplication.shared.statusBarStyle = .default
                createNavigationBar(backColor: UIColor.white, title: "", titleColor: UIColor.clear, align: .center, btn1: UIButton(), btn2: UIButton(), back: back)
                
            } else if UserDefaults.standard.object(forKey: "companyDetail") != nil {
                
                let companyDetail = UserDefaults.standard.string(forKey: "companyDetail")!
//                url = URL(string: domain + companyDetail)
                url = domain + companyDetail
                
            } else {
                
                let newWebUrl = UserDefaults.standard.string(forKey: "newWebUrl")!
//                url = URL(string: domain + newWebUrl)
                url = domain + newWebUrl
            }
            
        } else if UserDefaults.standard.object(forKey: "push_url") != nil {
            let push_url = UserDefaults.standard.object(forKey: "push_url") as! String
//            url = URL(string: domain + push_url)
            url = domain + push_url
        }
        
        if #available(iOS 11.0 , *) {
            let uurl = URL(string: url)
            var request = URLRequest(url: uurl!)
            request.httpMethod = "POST"
            let postString = "lat=\(lat)&lon=\(lon)"
            request.httpBody = postString.data(using: .utf8)
            wkWebView.load(request)
        } else {
            locationSettingWebView(url: url, lat: lat, lon: lon, wkWebView: wkWebView)
        }
        
    }

}

extension NewWebViewController : CLLocationManagerDelegate {
    
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

extension NewWebViewController {
    
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
        if let id = UserDefaults.standard.object(forKey: "id") as? String{
            if id == "guest" {
                loginPopupDialog(title: "", message: "회원가입 후 이용해 주시기 바랍니다.")
            } else {
                wkWebView.evaluateJavaScript("gRun.goReviewWrite()", completionHandler: { result, error in
                    if let error = error {
                        print(error)
                    } else {
                        print(result)
                    }
                })
            }
        }
    }
    
    func showMenu(_ sender: UIButton) {
        if let hamburgerVC = self.storyboard?.instantiateViewController(withIdentifier: "HamburgerController") as? HamburgerController {
            self.present(hamburgerVC, animated: true, completion: nil)
        }
    }
    
    func goSchedule(_ sender: UIButton) {
        wkWebView.evaluateJavaScript("gRun.goScheduleWrite()", completionHandler: { result, error in
            if let error = error {
                print()
            } else {
                print(result)
            }
        })
    }
    
    func goHome(_ sender: UIButton) {
        if let tabbarVC = self.presentingViewController as? TabBarController {
            tabbarVC.nextIdx = 0
        }
        HamburgerController.selectIdx = 0
        NewWebViewController.isDismiss = true
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - 닫기
    func doneBtn(_ sender: UIButton) {
        
        var url: URL!
        
        if UserDefaults.standard.object(forKey: "home_url") != nil {
            if UserDefaults.standard.string(forKey: "companyDetail") != nil {
                if UserDefaults.standard.string(forKey: "companyWeb") != nil {
                    let companyWeb = UserDefaults.standard.object(forKey: "companyWeb") as! String
                    url = URL(string: companyWeb)
                } else {
                    let companyDetail = UserDefaults.standard.object(forKey: "companyDetail") as! String
                    url = URL(string: domain + companyDetail)
                }
            } else {
                let home_url = UserDefaults.standard.string(forKey: "home_url")!
                url = URL(string: domain + home_url)
            }
            
        } else if UserDefaults.standard.object(forKey: "share_idx") != nil {
            
                let share_idx = UserDefaults.standard.object(forKey: "share_idx") as! String
                url = URL(string: domain + comDetailURL + "/\(share_idx)")
            
        } else if UserDefaults.standard.string(forKey: "newWebUrl") != nil{
            if UserDefaults.standard.string(forKey: "companyWeb") != nil {
                let companyWeb = UserDefaults.standard.object(forKey: "companyWeb") as! String
                url = URL(string: companyWeb)
            } else if UserDefaults.standard.object(forKey: "companyDetail") != nil {
                
                let companyDetail = UserDefaults.standard.string(forKey: "companyDetail")!
                url = URL(string: domain + companyDetail)
                
            } else {
                let newWebUrl = UserDefaults.standard.string(forKey: "newWebUrl")!
                url = URL(string: domain + newWebUrl)
            }
                
        } else if UserDefaults.standard.object(forKey: "push_url") != nil {
            let push_url = UserDefaults.standard.object(forKey: "push_url") as! String
            url = URL(string: domain + push_url)
            
        }
        
        let calenderCom = URL(string: "http://gople.ghsoft.kr/index/bookmark/schedule/company")
        let calenderPer = URL(string: "http://gople.ghsoft.kr/index/bookmark/schedule/person")
        let calender = URL(string: "http://gople.ghsoft.kr/index/bookmark/schedule")
        
        print(wkWebView.url!)
        print(url)
        
        if wkWebView.url == calenderPer || wkWebView.url == calenderCom || wkWebView.url == url || wkWebView.url == calender {
            UserDefaults.standard.removeObject(forKey: "companyWeb")
            UserDefaults.standard.removeObject(forKey: "companyDetail")
            UserDefaults.standard.removeObject(forKey: "newWebUrl_n")
            UserDefaults.standard.removeObject(forKey: "home_url")
            UserDefaults.standard.removeObject(forKey: "share_idx")
            UserDefaults.standard.removeObject(forKey: "newWebUrl")
            UserDefaults.standard.removeObject(forKey: "push_url")
            if let tabbarVC = self.presentingViewController as? TabBarController {
                if HamburgerController.selectIdx == nil {
                    tabbarVC.nextIdx = HomeController.type
                } else {
                    tabbarVC.nextIdx = HamburgerController.selectIdx
                }
            }
            self.dismiss(animated: true, completion: nil)
            
        } else if wkWebView.url != url {
            
            wkWebView.backForwardList.backList.forEach {
                print($0.url)
            }
            
            if wkWebView.canGoBack {
                wkWebView.evaluateJavaScript("back();", completionHandler: { (result, error) in
                    if let error = error {
                        print(error)
                    } else {
                        print(result)
                        
                    }
                })
            } else {
                UserDefaults.standard.removeObject(forKey: "companyWeb")
                UserDefaults.standard.removeObject(forKey: "companyDetail")
                UserDefaults.standard.removeObject(forKey: "newWebUrl_n")
                UserDefaults.standard.removeObject(forKey: "home_url")
                UserDefaults.standard.removeObject(forKey: "share_idx")
                UserDefaults.standard.removeObject(forKey: "newWebUrl")
                UserDefaults.standard.removeObject(forKey: "push_url")
                if let tabbarVC = self.presentingViewController as? TabBarController {
                    tabbarVC.nextIdx = HamburgerController.selectIdx
                }
                self.dismiss(animated: true, completion: nil)
            }
            
        } else {
            if let tabbarVC = self.presentingViewController as? TabBarController {
                if HomeController.type == 0 {
                    tabbarVC.nextIdx = 0
                }
                if HomeController.type == 1 {
                    tabbarVC.nextIdx = 1
                }
                if HomeController.type == 2 {
                    tabbarVC.nextIdx = 2
                }
                if HomeController.type == 3 {
                    tabbarVC.nextIdx = 3
                }
                if HomeController.type == 4 {
                    tabbarVC.nextIdx = 4
                }
            }
            
            if UserDefaults.standard.string(forKey: "companyWeb") != nil {
                UserDefaults.standard.removeObject(forKey: "companyWeb")
            } else if UserDefaults.standard.object(forKey: "companyDetail") != nil {
                UserDefaults.standard.removeObject(forKey: "companyDetail")
            } else {
                if UserDefaults.standard.object(forKey: "newWebUrl_n") != nil {
                    UserDefaults.standard.removeObject(forKey: "newWebUrl_n")
                } else {
                    UserDefaults.standard.removeObject(forKey: "home_url")
                    UserDefaults.standard.removeObject(forKey: "share_idx")
                    UserDefaults.standard.removeObject(forKey: "newWebUrl")
                    UserDefaults.standard.removeObject(forKey: "push_url")
                }
            }
            
            self.dismiss(animated: true, completion: nil)
        }
        
    }
}

extension NewWebViewController: WKScriptMessageHandler {
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
                        btn2.setImage(#imageLiteral(resourceName: "search_delete"), for: .normal)
                        btn2.frame.size = CGSize(width: 47, height: 46)
                        btn2.frame.origin = CGPoint(x: self.view.frame.width - (btn2.frame.width + 3), y: 7)
                        btn2.addTarget(self, action: #selector(doneBtn(_:)), for: .touchUpInside)
                        
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
                        btn1.setImage(#imageLiteral(resourceName: "home_black"), for: .normal)
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
                                    
//                                    wkWebView.evaluateJavaScript("back();", completionHandler: { (result, error) in
//                                        if let error = error {
//                                            print(error)
//                                        } else {
//                                            print(result)
//                                            self.wkWebView.reload()
//                                        }
//                                    })
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
                                
                                if let newWebVC = self.storyboard?.instantiateViewController(withIdentifier: "NewWebViewController") as? NavigationController {
                                    self.present(newWebVC, animated: true, completion: nil)
                                }
                            }
                            
                            
//                            let rurl = URL(string: domain + url)
//                            let request = URLRequest(url: rurl!)
//                            wkWebView.load(request)
                        }
                    }
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
        
        if message.name == "onLoadDateSet" {
            print("\(message.name) : \(message.body)")
            
            let pickerParentOriginY = self.view.frame.height
            let pickerParentY = self.view.frame.height - 300 + 44
            
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            
            datePicker.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 256)
            datePicker.backgroundColor = UIColor.white
            datePicker.datePickerMode = .date
            
            let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
            toolbar.setItems([flexBarButton, doneButton], animated: false)
            
            pickerParentView.frame = CGRect(x: 0, y: pickerParentOriginY, width: self.view.frame.width, height: 300)
            pickerParentView.addSubview(datePicker)
            pickerParentView.addSubview(toolbar)
            
            self.view.addSubview(pickerParentView)
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.pickerParentView.frame.origin.y = pickerParentY
                
            }, completion: { (success) in
                if success {
                    print("애니메이션 완료")
                }
            })
        }
        
        if message.name == "onAlarmAlert" {
            print("\(message.name) : \(message.body)")
            contractBridge = message.body as! String
            
            let AlaramVC = AlaramController(nibName: "AlaramController", bundle: nil)
            let popup = PopupDialog(viewController: AlaramVC, buttonAlignment: .horizontal, transitionStyle: .bounceDown, gestureDismissal: true, completion: nil)
            
            let okButton = DefaultButton(title: "확인", height: 55, dismissOnTap: true, action: {
                self.wkWebView.evaluateJavaScript("\(self.contractBridge)()", completionHandler: { (result, error) in
                    if let error = error {
                        print("error : \(error)")
                    } else {
                        print("result: \(result)")
                        if let tabbarVC = self.presentingViewController as? TabBarController {
                            tabbarVC.nextIdx = 3
                        }
                        BookmarkController.reloadExecution = false
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            })
            
            let cancelButton = CancelButton(title: "취소", height: 55, dismissOnTap: true, action: nil)
            
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
        
        if message.name == "onBack" {
            wkWebView.evaluateJavaScript("back();", completionHandler: { (result, error) in
                if let error = error {
                    print(error)
                } else {
                    self.wkWebView.reload()
                }
            })
        }
        
        if message.name == "onCall" {
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
        
        //MARK: 갤러리 들어갈때
        if message.name == "setFileUpload" {
            print("\(message.name) : \(message.body)")
            self.tempList = self.wkWebView.backForwardList
            
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
        
        if message.name == "offView" {
            print("\(message.name) : \(message.body)")
            
            if let tabbarVC = self.presentingViewController as? TabBarController {
                
                if HomeController.type == 3 {
                    BookmarkController.scheduleSave = true
                    BookmarkController.javascriptFunc = message.body as! String
                } else if HomeController.type == 0 {
                    HomeController.completeAlert = true
                    
//                    if UserDefaults.standard.object(forKey: "completeAlert") == nil {
//                        defaultPopupDialog(target: self, title: "", message: "결제총액을 입금해주시면 승인알림 메세지 확인 후 스케줄을 입력해주세요.", completion: {
//                            UserDefaults.standard.set("completeAlert", forKey: "completeAlert")
//                            self.dismiss(animated: true, completion: nil)
//                        })
//                    }
                    
                }
                
                tabbarVC.nextIdx = HomeController.type
            }
            
            UserDefaults.standard.removeObject(forKey: "companyWeb")
            UserDefaults.standard.removeObject(forKey: "companyDetail")
            UserDefaults.standard.removeObject(forKey: "newWebUrl_n")
            UserDefaults.standard.removeObject(forKey: "home_url")
            UserDefaults.standard.removeObject(forKey: "share_idx")
            UserDefaults.standard.removeObject(forKey: "newWebUrl")
            UserDefaults.standard.removeObject(forKey: "push_url")
            
//            if UserDefaults.standard.object(forKey: "completeAlert") != nil {
//                UserDefaults.standard.removeObject(forKey: "completeAlert")
                self.dismiss(animated: true, completion: nil)
//            }
        }
        
        if message.name == "onShare" {
            print("\(message.name) : \(message.body)")
            
            let idx = message.body as! Int
            let url = URL(string: domain + shareURL + "/\(idx)")!
            
            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            
            self.present(activityVC, animated: true, completion: nil)
        }
        
        if message.name == "onWebView" {
            print("\(message.name) : \(message.body)")
            
            let url = message.body as! String
            UserDefaults.standard.set(url, forKey: "companyWeb")
            
            if let newWebVC = self.storyboard?.instantiateViewController(withIdentifier: "NewWebViewController") as? NavigationController {
                self.present(newWebVC, animated: true, completion: nil)
            }
        }
        
        if message.name == "runBackView" {
            print("\(message.name) : \(message.body)")
            
            if let scriptMessage = message.body as? [AnyObject] {
                if let type = scriptMessage[1] as? Int {
                    if type == 3 {
                        if let jsFunc = scriptMessage[0] as? String {
                            HomeDetailViewController.filterFunc = jsFunc
                            if let tabbarVC = self.presentingViewController as? TabBarController {
                                if HamburgerController.selectIdx == nil {
                                    tabbarVC.nextIdx = HamburgerController.selectIdx
                                } else {
                                    tabbarVC.nextIdx = HomeController.type
                                }
                            }
                            
//                            if HomeDetailViewController.filterFunc != "" {
//                                self.wkWebView.evaluateJavaScript("\(HomeDetailViewController.filterFunc)()", completionHandler: { (result, error) in
//                                    if let error = error {
//                                        print(error)
//                                    } else {
//                                        print(result)
//                                        HomeDetailViewController.filterFunc = ""
//                                    }
//                                })
//                            }
                            
                            self.dismiss(animated: true, completion: nil)
                        }
                    } else if type == 4 {
                        if let jsFunc = scriptMessage[0] as? String {
                            WebViewController.calenderFunc = jsFunc
                            
                            if let tabbarVC = self.presentingViewController as? TabBarController {
                                if HamburgerController.selectIdx == nil {
                                    tabbarVC.nextIdx = HamburgerController.selectIdx
                                } else {
                                    tabbarVC.nextIdx = HomeController.type
                                }
                            }
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
            
//            wkWebView.evaluateJavaScript("\(WebViewController.calenderFunc)()", completionHandler: { (result, error) in
//                if let error = error {
//                    print(error)
//                } else {
//                    print(result)
//                }
//            })
        }
        
        if message.name == "goLogin" {
            print("\(message.name) : \(message.body)")
            
            loginPopupDialog(title: "", message: "회원가입 후 이용해 주시기 바랍니다.")
        }
        
        if message.name == "selectWish" {
            print("\(message.name) : \(message.body)")
            
            HomeDetailViewController.filterFunc = message.body as! String
        }
        
    }
    
    func donePressed(_ sender : Any) {
        //format date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let date = dateFormatter.string(from: datePicker.date)
        print(date)
        
        wkWebView.evaluateJavaScript("gRun.setDateDoc('\(date)')") { (result, error) in
            if let error = error {
                print(error)
            } else {
                print(result)
                UIView.animate(withDuration: 0.3, animations: {
                    
                    self.pickerParentView.frame.origin.y = self.view.frame.height
                    
                }, completion: { (success) in
                    if success {
                        self.pickerParentView.removeFromSuperview()
                        print("애니메이션 완료")
                    }
                })
            }
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

extension NewWebViewController: WKNavigationDelegate {
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

extension NewWebViewController: WKUIDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        // 2. 상단 status bar에도 activity indicator가 나오게 할 것이다.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
//        if UserDefaults.standard.string(forKey: "newWebUrl") != nil {
//            UserDefaults.standard.removeObject(forKey: "newWebUrl")
//            UserDefaults.standard.set(String(describing: wkWebView.url!), forKey: "newWebUrl")
//            print(UserDefaults.standard.string(forKey: "newWebUrl")!)
//        }
        
        let strUrl = String(describing: webView.url!)
        print(strUrl)
        var strArr = [String]()
        
        strUrl.characters.map{
            strArr.append(String($0))
        }
        
        for i in 0..<strArr.count {
            print("글자 수 : \(i+1) / \(strArr[i])")
        }
        
        if strArr.count > 41 {
            let index = strUrl.index(strUrl.startIndex, offsetBy: 41)
            let url = strUrl.substring(to: index)
            
            print(url)
            
            if url == "http://gople.ghsoft.kr/index/data/detail/" {
                wkWebView.evaluateJavaScript("tabMove()", completionHandler: { (result, error) in
                    if let error = error {
                        print(error)
                    } else {
                        print(result)
                    }
                })
            }
        }
        
        if UserDefaults.standard.string(forKey: "companyWeb") != nil {
            UserDefaults.standard.set(String(describing: wkWebView.url!), forKey: "companyWeb")
            print(UserDefaults.standard.string(forKey: "companyWeb")!)
        }
        
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        // 중복적으로 리로드가 일어나지 않도록 처리 필요.
        webView.reload()
    }
    
}

extension NewWebViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
                multipartFormData.append(data, withName: "file[\(i)]", fileName: "image", mimeType: "image/jpeg")
                
            }
        }, to: domain + imgUpladURL,
           method: .post,
           headers: headers) { (result) in
            switch result{
            case .success(let upload, _, _):
//                upload.responseString(completionHandler: { (response) in
//                    print(response)
//                })
                upload.responseJSON { response in
                    print("Succesfully uploaded")
//                    print("result : \(result)")
//                    print("response : \(response)")

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

extension NewWebViewController {
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

extension NewWebViewController {
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
