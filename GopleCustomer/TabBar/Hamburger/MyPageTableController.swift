//
//  MyPageTableController.swift
//  GopleCustomer
//
//  Created by 김민주 on 2017. 11. 30..
//  Copyright © 2017년 김민주. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import PopupDialog
import DLRadioButton

class MyPageTableController: UITableViewController {
    
    enum Mode {
        case logout
        case withdrawal
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var marriageDate: UILabel!
    @IBOutlet weak var myPhoneNum: UILabel!
    
    weak var logoutDelegate: LogoutDelegate?
    weak var withdrawalDelgate: WithdrawalDelegate?
    
    let myData = UserDefaults.standard
    
    var wkWebView = WKWebView()
    
    var viewNavBar = UIView()
    let backBtn = UIButton()
    
    let datePicker = UIDatePicker()
    let pickerParentView = UIView()
    
    var id = ""
    var email = ""
    var name = ""
    var phone = ""
    var phoneNumHiphone = ""
    
    static var checkList = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        let config = WKWebViewConfiguration()
        wkWebView = WKWebView(frame: .zero, configuration: config)
        
        let url = domain + bookmarkURL
        let request = URLRequest(url: URL(string: url)!)
        wkWebView.load(request)
        
        self.view.addSubview(wkWebView)
        
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 9))
        self.tableView.tableFooterView?.isHidden = true
        self.tableView.backgroundColor = UIColor.init(hex: "efefef")
        
        self.tableView.separatorStyle = .singleLine
        self.tableView.separatorColor = UIColor(hex: "cfcfcf")
        
        guard #available(iOS 11.0, *) else {
            let adjustForTabbarInsets: UIEdgeInsets = UIEdgeInsetsMake(0, 0, -49, 0)
            self.tableView.contentInset = adjustForTabbarInsets
            self.tableView.scrollIndicatorInsets = adjustForTabbarInsets
            
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let id = UserDefaults.standard.object(forKey: "id") as? String{
            if id == "guest" {
                print("guest")
                loginPopupDialog(title: "", message: "회원가입 후 이용해 주시기 바랍니다.")
            } else {
                UIApplication.shared.isStatusBarHidden = false
                
                createNavigationBar()
                requestUserInfo()
                updateProfile()
                
                if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
                    self.tableView.deselectRow(at: selectionIndexPath, animated: true)
                }
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 1
        } else if section == 1 {
            return 6
        } else if section == 2 {
            return 3
        }
        return 2
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        
        let storyboard: UIStoryboard = self.storyboard!
        
        if section == 1 {
            if row == 0 {
                print("캘린더")
                changeWebView(str: "schedule")
                
            } else if row == 1 {
                print("MY 체크리스트")
                
                MyPageTableController.checkList = true
                
                let checkListTableController = storyboard.instantiateViewController(withIdentifier: "CheckListTableController")
//                self.navigationController?.pushViewController(checkListTableController, animated: true)
                self.present(checkListTableController, animated: true, completion: nil)
                
            } else if row == 2 {
                print("추천인 보기")
                changeWebView(str: "suggest")
                
            } else if row == 3 {
                print("알림 설정")
                
                let pushTableController = storyboard.instantiateViewController(withIdentifier: "PushTableController")
                self.navigationController?.pushViewController(pushTableController, animated: true)
                viewNavBar.removeFromSuperview()
                
            } else if row == 4 {
                print("공지사항")
                
                changeWebView(str: "notice")
            } else if row == 5 {
                print("이용방법")
                
                HamburgerController.selectIdx = 4
                if let howVC = storyboard.instantiateViewController(withIdentifier: "HowViewController") as? HowViewController {
                    self.present(howVC, animated: true, completion: nil)
                }
            }
        } else if section == 2 {
            if row == 0 {
                print("서비스 이용약관")
                changeWebView(str: "service2")
                
            } else if row == 1 {
                print("개인정보 처리 방침")
                changeWebView(str: "privacy")
                
            } else if row == 2 {
                print("위치기반 서비스 동의서")
                changeWebView(str: "location")
                
            }
        } else if section == 3 {
            if row == 0 {
                print("로그아웃")
                
                TabBarController.customTabBar.removeFromSuperview()
                setLogoutPopup(title: "", message: "로그아웃 하시겠습니까?", mode: .logout)
                
            } else if row == 1 {
                print("탈퇴")
                
                TabBarController.customTabBar.removeFromSuperview()
                setLogoutPopup(title: "", message: "회원탈퇴 하시겠습니까?", mode: .withdrawal)
    
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20))
        if section == 0 {
            header.backgroundColor = UIColor.white
        } else {
            header.backgroundColor = UIColor.init(hex: "efefef")
        }
        return header
        
    }
    
    //Header Height
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if( section == 0 ) {
            return 14
        } else {
            return 9
        }
    }
    
    //Header Title
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if( section == 0 ) {
            return ""
        } else {
            return "   "
        }
    }
    
    private func changeWebView(str: String) {
        UserDefaults.standard.set(str, forKey: "webView")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let webViewController = storyboard.instantiateViewController(withIdentifier: "WebViewController") as? WebViewController {
            viewNavBar.removeFromSuperview()
            WebViewController.calenderType = "web"
            self.navigationController?.pushViewController(webViewController, animated: true)
        }
    }
    
    private func execDelegate(mode: Mode) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let rootVC = appDelegate.window?.rootViewController
            
            if let loginVC = rootVC as? LoginController {
                if let tabbarVC = loginVC.presentedViewController as? TabBarController {
                    if let naviVC = tabbarVC.childViewControllers[0] as? NavigationController {
                        if let homeVC = naviVC.viewControllers.first as? HomeController {
                            switch mode {
                            case .logout:
                                
                                self.logoutDelegate = homeVC
                                self.logoutDelegate?.logout()
                                
                            case .withdrawal:
                                
                                self.withdrawalDelgate = homeVC
                                self.withdrawalDelgate?.withdraw(id: id, email: email)
                            }
                        }
                    }
                } else if let tabbarVC = loginVC.presentedViewController?.presentedViewController?.presentedViewController as? TabBarController {
                    if let naviVC = tabbarVC.childViewControllers[0] as? NavigationController {
                        if let homeVC = naviVC.viewControllers.first as? HomeController {
                            switch mode {
                            case .logout:
                                
                                self.logoutDelegate = homeVC
                                self.logoutDelegate?.logout()
                                
                            case .withdrawal:
                                
                                self.withdrawalDelgate = homeVC
                                self.withdrawalDelgate?.withdraw(id: id, email: email)
                            }
                        }
                    }
                }
            } else {
                if let naviVC = rootVC?.childViewControllers[0] as? NavigationController {
                    if let homeVC = naviVC.viewControllers.first as? HomeController {
                        switch mode {
                        case .logout:
                            
                            self.logoutDelegate = homeVC
                            self.logoutDelegate?.logout()
                            
                        case .withdrawal:
                            
                            self.withdrawalDelgate = homeVC
                            self.withdrawalDelgate?.withdraw(id: id, email: email)
                        }
                    }
                }
            }
        }
    }
    
//    private func execDelegate(mode: Mode) {
//        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
//            let rootVC = appDelegate.window?.rootViewController
//
//            if let loginVC = rootVC as? LoginController {
//                if let homeVC = loginVC.presentedViewController as? TabBarController {
//                    switch mode {
//                    case .logout:
//
//                        self.logoutDelegate = homeVC
//                        self.logoutDelegate?.logout()
//
//                    case .withdrawal:
//
//                        self.withdrawalDelgate = homeVC
//                        self.withdrawalDelgate?.withdraw(id: id, email: email)
//                    }
//                }
////                else if let homeVC = loginVC.presentedViewController as? JoinController {
////                    switch mode {
////                    case .logout:
////
////                        self.logoutDelegate = loginVC.presentedViewController
////                        self.logoutDelegate?.logout()
////
////                    case .withdrawal:
////
////                        self.withdrawalDelgate = loginVC.presentedViewController
////                        self.withdrawalDelgate?.withdraw(id: id, email: email)
////                    }
////                }
//            } else {
//
////                if let homeVC = rootVC as? TabBarController {
////                    switch mode {
////                    case .logout:
////
////                        self.logoutDelegate = homeVC
////                        self.logoutDelegate?.logout()
////
////                    case .withdrawal:
////
////                        self.withdrawalDelgate = homeVC
////                        self.withdrawalDelgate?.withdraw(id: id, email: email)
////                    }
////                }
//
//                if let naviVC = rootVC?.childViewControllers[0] as? NavigationController {
//                    if let homeVC = naviVC.viewControllers.first as? HomeController {
//                        switch mode {
//                        case .logout:
//
//                            self.logoutDelegate = homeVC
//                            self.logoutDelegate?.logout()
//
//                        case .withdrawal:
//
//                            self.withdrawalDelgate = homeVC
//                            self.withdrawalDelgate?.withdraw(id: id, email: email)
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    func doneBtn(_ sender: UIButton) {
        if UserDefaults.standard.object(forKey: "webView") != nil {
            self.navigationController?.popViewController(animated: true)
            UserDefaults.standard.removeObject(forKey: "webView")
        } else {
            self.tabBarController?.selectedIndex = 0
            TabBarController.customTabBar.isHidden = false
        }
        
    }
    
    func showMenu(_ sender: UIButton) {
        if let hamburgerVC = self.storyboard?.instantiateViewController(withIdentifier: "HamburgerController") as? HamburgerController {
            self.present(hamburgerVC, animated: true, completion: nil)
            HamburgerController.selectIdx = 4
        }
    }
    
    func removeHiphone() {
        let hiphone = phoneNumHiphone
        let index = hiphone.index(hiphone.startIndex, offsetBy: 3)
        
        let first = hiphone.substring(to: index)
        
        var start = hiphone.index(hiphone.startIndex, offsetBy: 4)
        var end = hiphone.index(hiphone.endIndex, offsetBy: -5)
        var length = start..<end
        
        let second = hiphone.substring(with: length)
        
        start = hiphone.index(hiphone.startIndex, offsetBy: 9)
        end = hiphone.index(hiphone.endIndex, offsetBy: 0)
        length = start..<end
        
        let last = hiphone.substring(with: length)
        
        phone = first + second + last
    }
    
    func setLogoutPopup(title: String, message: String, mode: Mode){
        let popup = PopupDialog(title: title, message: message)
        popup.transitionStyle = .bounceDown
        
        let okButton = DefaultButton(title: "확인", height: 46, dismissOnTap: true, action: {
            self.execDelegate(mode: mode)
        })
        
        let cancelButton = CancelButton(title: "취소", height: 46, dismissOnTap: true, action: nil)
        
        popup.addButtons([cancelButton, okButton])
        popup.buttonAlignment = .horizontal
        
        let pv = PopupDialogDefaultView.appearance()
        pv.titleFont = UIFont(name: "Daehan-Bold", size: 15)!
        pv.titleColor = textColor
        pv.titleTextAlignment = .center
        pv.messageFont = UIFont(name: "Daehan-Bold", size: 15)!
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

extension MyPageTableController {
    @IBAction func marriagePopup(_ sender: UIButton) {
        
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
    
    func donePressed(_ sender : Any) {
        //format date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let date = dateFormatter.string(from: datePicker.date)
        requestMarriage(date: date)
        self.tableView.reloadData()
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.pickerParentView.frame.origin.y = self.view.frame.height
            
        }, completion: { (success) in
            if success {
                self.pickerParentView.removeFromSuperview()
                print("애니메이션 완료")
                requestUserInfo()
                
                guard let id = UserDefaults.standard.string(forKey: "id") else { return }
                guard let email = UserDefaults.standard.string(forKey: "email") else { return }
                guard let name = UserDefaults.standard.string(forKey: "name") else { return }
                guard let phoneNumHiphone = UserDefaults.standard.string(forKey: "phone") else { return }
                
                self.id = id
                self.email = email
                self.name = name
                self.phoneNumHiphone = phoneNumHiphone
                
                self.removeHiphone()
                
                let textFont1: [String: AnyObject] = [NSForegroundColorAttributeName: textColor,
                                                      NSFontAttributeName: UIFont(name: "Daehan-Bold", size: 17)!]
                
                let textFont2: [String: AnyObject] = [NSForegroundColorAttributeName: textColor,
                                                      NSFontAttributeName: UIFont(name: "Daehan-Bold", size: 13)!]
                
                let attributeName = " 님"
                
                let nameStyle1 = NSMutableAttributedString(string: name, attributes: textFont1)
                let nameStyle2 = NSMutableAttributedString(string: attributeName, attributes: textFont2)
                
                nameStyle1.append(nameStyle2)
                
                self.nameLabel.attributedText = nameStyle1
                print(self.phone)
                self.myPhoneNum.text = self.phone
                
                if let marriage = UserDefaults.standard.object(forKey: "marriage") as? String {
                    if marriage == "0000-00-00" {
                        self.marriageDate.text = "미정"
                    } else {
                        self.marriageDate.text = marriage
                    }
                } else {
                    self.marriageDate.text = "미정"
                }
                
                self.tableView.reloadData()
            }
        })
    }
    
    @IBAction func changePhone(_ sender: UIButton) {
        changePhonePopup()
    }
    
    func requestMarriage(date: String) {
        
        guard let idx = UserDefaults.standard.object(forKey: "idx") as? String else {
            return
        }
        
        let parameters = ["marriage":date,
                          "idx":idx]
        print(parameters)
        
        Alamofire.request(domain + setMarriageURL,
                          method: .post,
                          parameters: parameters,
                          encoding: URLEncoding.default,
                          headers: nil).response { (response) in
                            do {
                                let readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! [String : AnyObject]
                                print(readableJSON)
                                
                                if readableJSON["return"] as? Int == 1 {
                                    self.showToast(message: "결혼예정일이 변경됐습니다.")
                                    
                                    requestUserInfo()

                                    if let marriage = UserDefaults.standard.object(forKey: "marriage") as? String {
                                        if marriage == "0000-00-00" {
                                            self.marriageDate.text = "미정"
                                        } else {
                                            self.marriageDate.text = marriage
                                        }
                                    } else {
                                        self.marriageDate.text = "미정"
                                    }
                                    self.tableView.reloadData()
                                    
                                    self.wkWebView.evaluateJavaScript("setMemberInfoRefresh()", completionHandler: { (result, error) in
                                        if let error = error {
                                            print(error)
                                        } else {
                                            print("result: \(result)")
                                            
                                            self.wkWebView.evaluateJavaScript("localStorage.getItem('index_login')") { (result, error) in
                                                if let error = error {
                                                    print(error)
                                                } else {
                                                    print("localstorage : \(result as! String)")
                                                }
                                            }
                                        }
                                    })
                                    
                                }
                                
                            } catch {
                                print(error)
                            }
        }
    }
    
    func changePhonePopup() {
        let changePhoneVC = ChangePhoneController(nibName: "ChangePhoneController", bundle: nil)
        let popup = PopupDialog(viewController: changePhoneVC, buttonAlignment: .horizontal, transitionStyle: .bounceDown, gestureDismissal: false, completion: nil)
        
        let okButton = DefaultButton(title: "확인", height: 52, dismissOnTap: true, action: {
            self.requestPhone()
            
            self.updateProfile()
            
        })
        let cancelButton = CancelButton(title: "취소", height: 52, dismissOnTap: true, action: nil)
        
        popup.addButtons([cancelButton, okButton])
        
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
    
    func requestPhone(){
        
        guard let idx = UserDefaults.standard.object(forKey: "idx") as? String else {
            return
        }
        let parameters = ["phone":ChangePhoneController.hiphone,
                          "idx":idx]
        print(parameters)
        
        Alamofire.request(domain + setPhoneURL,
                          method: .post,
                          parameters: parameters,
                          encoding: URLEncoding.default,
                          headers: nil).response { (response) in
                            do {
                                let readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! [String : AnyObject]
                                print(readableJSON)
                                
                                if readableJSON["return"] as? Int == 1 {
                                    self.showToast(message: "전화번호가 변경됐습니다.")
                                    
                                    self.updateProfile()
                                    
                                    self.tableView.reloadData()
                                    self.wkWebView.evaluateJavaScript("setMemberInfoRefresh()", completionHandler: { (result, error) in
                                        if let error = error {
                                            print(error)

                                        } else {
                                            print("result: \(result)")
                                            
                                            self.wkWebView.evaluateJavaScript("localStorage.getItem('index_login')") { (result, error) in
                                                if let error = error {
                                                    print(error)
                                                } else {
                                                    print("localstorage : \(result as! String)")
                                                }
                                            }
                                        }
                                    })
                                } else if readableJSON["return"] as? Int == 2 {
                                    self.showToast(message: "현재 번호와 동일합니다.")
                                } else {
                                    self.showToast(message: "전화번호 변경을 실패했습니다.")
                                }
                                
                            } catch {
                                print(error)
                            }
        }
    }
}

extension MyPageTableController {
    func updateProfile() {
        
        requestUserInfo()
        
        print("마이페이지")
        
        guard let id = UserDefaults.standard.string(forKey: "id") else { return }
        guard let email = UserDefaults.standard.string(forKey: "email") else { return }
        guard let name = UserDefaults.standard.string(forKey: "name") else { return }
        guard let phoneNumHiphone = UserDefaults.standard.string(forKey: "phone") else { return }
        
        self.id = id
        self.email = email
        self.name = name
        self.phoneNumHiphone = phoneNumHiphone
        
        self.removeHiphone()
        
        let textFont1: [String: AnyObject] = [NSForegroundColorAttributeName: textColor,
                                              NSFontAttributeName: UIFont(name: "Daehan-Bold", size: 17)!]
        
        let textFont2: [String: AnyObject] = [NSForegroundColorAttributeName: textColor,
                                              NSFontAttributeName: UIFont(name: "Daehan-Bold", size: 13)!]
        
        let attributeName = " 님"
        
        let nameStyle1 = NSMutableAttributedString(string: name, attributes: textFont1)
        let nameStyle2 = NSMutableAttributedString(string: attributeName, attributes: textFont2)
        
        nameStyle1.append(nameStyle2)
        
        self.nameLabel.attributedText = nameStyle1
        print(self.phone)
        self.myPhoneNum.text = self.phone
        
        if let marriage = UserDefaults.standard.object(forKey: "marriage") as? String {
            if marriage == "0000-00-00" {
                self.marriageDate.text = "미정"
            } else {
                self.marriageDate.text = marriage
            }
        } else {
            self.marriageDate.text = "미정"
        }
        
        self.tableView.reloadData()
    }
}

extension MyPageTableController {
    func createNavigationBar() {
        viewNavBar = UIView(frame: CGRect(
            origin: CGPoint(x: 0, y: 0),
            size: CGSize(width: self.view.frame.size.width, height: 58)))
        viewNavBar.backgroundColor = UIColor.white
        
        let title = UILabel()
        title.text = "마이페이지"
        title.font = UIFont(name: "DaeHan-Bold", size: 20)
        title.textColor = textColor
        title.frame = CGRect(x: 0, y: 20, width: 140, height: 20)
        title.center.x = self.view.frame.width / 2
        title.textAlignment = .center
        viewNavBar.addSubview(title)
        
        let back = UIButton()
        back.setImage(#imageLiteral(resourceName: "back_black"), for: .normal)
        back.frame = CGRect(x: 9, y: 14, width: 42, height: 31)
        back.addTarget(self, action: #selector(doneBtn(_:)), for: .touchUpInside)
        viewNavBar.addSubview(back)
        
        let menu = UIButton()
        menu.setImage(#imageLiteral(resourceName: "black_4041"), for: .normal)
        menu.frame.size = CGSize(width: 40, height: 41)
        menu.frame.origin.x = self.view.frame.width - (menu.frame.width + 5)
        menu.center.y = viewNavBar.frame.height / 2
        menu.addTarget(self, action: #selector(showMenu(_:)), for: .touchUpInside)
        viewNavBar.addSubview(menu)
        
        self.navigationController?.navigationBar.addSubview(viewNavBar)
        
    }
}

extension MyPageTableController {
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

extension MyPageTableController: WKNavigationDelegate {
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

extension MyPageTableController: WKUIDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        // 2. 상단 status bar에도 activity indicator가 나오게 할 것이다.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
    }
    
}



