//
//  ViewController.swift
//  GopleCustomer
//
//  Created by 김민주 on 2017. 11. 13..
//  Copyright © 2017년 김민주. All rights reserved.
//

import UIKit
import WebKit
import FBSDKCoreKit
import FBSDKLoginKit
import Alamofire

class LoginController: UIViewController, NaverThirdPartyLoginConnectionDelegate {
    
    @IBOutlet weak var guestBtn: UIButton!
    
    let myData = UserDefaults.standard
    var parameter: [String: AnyObject]!
    
    weak var loginDelegate: LoginDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tlogin = NaverThirdPartyLoginConnection.getSharedInstance()
        tlogin?.resetToken()
        
        var attributes: [String : Any]!
        
        if let font = UIFont(name: "DaeHan", size: 13) {
            attributes = [NSFontAttributeName : font,
                          NSForegroundColorAttributeName : UIColor.white,
                          NSUnderlineStyleAttributeName : NSUnderlineStyle.styleSingle.rawValue]
        }
        
        let attributeString = NSMutableAttributedString(string: "게 스 트  로 그 인",
                                                        attributes: attributes)
        guestBtn.setAttributedTitle(attributeString, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        UIApplication.shared.isStatusBarHidden = true
    }
    
    @IBAction func kakaoLogin(_ sender: UIButton) {
        //카카오 로그인
        let session = KOSession.shared()
        //로그인 세션이 생성 됐으면
        if let s = session {
            //이전 열린 세션을 닫고
            if s.isOpen() {
                s.close()
            }
            s.open(completionHandler: { (error) in
                //에러가 없으면
                if error == nil {
                    print("No error")
                    //로그인 성공
                    if s.isOpen(){
                        print("Succces  Token : \(KOSession.shared().accessToken)")
                        KOSessionTask.meTask { (user, error) -> Void in
                            if error == nil {
                                print("userid = \(user)")
                                
                                let koUser = user as! KOUser
                                
                                let email = koUser.email
                                let id = koUser.id
                                
                                let token = self.myData.object(forKey: "token") as! String
                                
                                self.parameter = ["id":id!,
                                                  "email":email! as AnyObject,
                                                  "token":token as AnyObject,
                                                  "device":"ios" as AnyObject]
                                print("kakao paramter : \(self.parameter!)")
                                
                                self.myData.set(id!, forKey: "loginId")
                                self.myData.set(email!, forKey: "loginEmail")
                                
                                self.requestLogin(self.parameter)
                            }
                        }
                    }
                } else {
                    //로그인 실패
                    print("Fail error : \(error)")
                }
            })
        } else {
            //세션 생성 실패
            print("Something wrong")
        }
    }
    
    @IBAction func naverLogin(_ sender: UIButton) {
        //네이버 로그인
        
        let tlogin = NaverThirdPartyLoginConnection.getSharedInstance()
        tlogin?.delegate = self
        tlogin?.requestThirdPartyLogin()
    }
    
    func oauth20ConnectionDidOpenInAppBrowser(forOAuth request: URLRequest!) {
        
        let naverInappBrower = NLoginThirdPartyOAuth20InAppBrowserViewController(request: request)
        naverInappBrower?.modalPresentationStyle = .overFullScreen
        self.present(naverInappBrower!, animated: true, completion: nil)

    }
    
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        getNaverEmail()
    }
    
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        
    }
    
    func oauth20ConnectionDidFinishDeleteToken() {
        
    }
    
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        
    }
    
    func getNaverEmail() {
        //네이버 id, email 가져오기
        let loginConn = NaverThirdPartyLoginConnection.getSharedInstance()
        
        guard let token = loginConn!.accessToken else {
            return
        }
        
        var header = [String: String]()
        header["Authorization"] = "Bearer \(token)"
        
        Alamofire.request("https://openapi.naver.com/v1/nid/me",
                          method: .get,
                          parameters: nil,
                          encoding: URLEncoding.default,
                          headers: header).response(completionHandler: { (response) in
                            do {
                                let readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! [String : AnyObject]
                                print(readableJSON)
                                
                                let reaponse = readableJSON["response"] as! [String : String]
                                
                                let id = reaponse["id"]
                                let email = reaponse["email"]
                                let token = self.myData.object(forKey: "token") as! String

                                self.parameter = ["id":id as AnyObject,
                                                  "email":email as AnyObject,
                                                  "token":token as AnyObject,
                                                  "device":"ios" as AnyObject]
                                print("naver paramter : \(self.parameter!)")

                                self.myData.set(id, forKey: "loginId")
                                self.myData.set(email, forKey: "loginEmail")
                                
                                self.requestLogin(self.parameter)
                                
                            } catch {
                                print("실패")
                                basicAlert(target: self, title: "로그인 실패", message: "다시 시도해주세요.")
                                loginConn?.resetToken()
                            }
                            
                          })
        
    }

    
    @IBAction func facebookLogin(_ sender: UIButton) {
        //페이스북 로그인
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email", "user_friends"], from: self) { (result, error) in
            if(error == nil) {
                let fbloginresult: FBSDKLoginManagerLoginResult = result!
                if fbloginresult.grantedPermissions == nil {
                    return
                } else if (fbloginresult.grantedPermissions.contains("email")){
                    self.getFBUserData()
                }
            }
        }
    }
    
    func getFBUserData() {
        if((FBSDKAccessToken.current()) != nil) {
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, email, name"]).start(completionHandler: { (connection, result, error) -> Void in
                if(error == nil){
                    print("result \(result!)")
                    let res = result as! [String : AnyObject]
                    let email = res["email"] as! String
                    let id = res["id"] as! String
                    let token = self.myData.object(forKey: "token") as! String

                    self.parameter = ["id":id as AnyObject,
                                "email":email as AnyObject,
                                "token":token as AnyObject,
                                "device":"ios" as AnyObject]
                    print("facebook paramter : \(self.parameter!)")

                    self.myData.set(id, forKey: "loginId")
                    self.myData.set(email, forKey: "loginEmail")

                    self.requestLogin(self.parameter)

//                    let parameters = [id, email, token]
//                    
//                    self.login(parameters: parameters, {
//                        let url = URL(string: "http://gople.ghsoft.kr/index/base/setLoginTrace")
//                        var request = URLRequest(url: url!)
//                        request.httpMethod = "POST"
//                        let postString = "id=\(id)&email=\(email)&token=\(token)&device=ios"
//                        request.httpBody = postString.data(using: .utf8)
////                        self.loginSuccess = true
//
//                        if let tabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
//                            if let homeNVC = tabBarController.viewControllers![0] as? NavigationController {
//                                if let homeVC = homeNVC.viewControllers.first as? HomeController {
////                                    self.loginDelegate = homeVC
//                                    homeVC.request = request
//                                    self.present(tabBarController, animated: true, completion: {
////                                        homeVC.login(request: request)
//                                    })
//                                }
//
//                            }
//
//                        }
////                        self.wkWebView.load(request)
//
//                    })
                }
            }
            )}
    }
    
    @IBAction func guestLogin(_ sender: UIButton) {
        //게스트 로그인
        if let token = self.myData.string(forKey: "token") {
            self.parameter = ["id":"guest" as AnyObject,
                              "email":"guest" as AnyObject,
//                              "token":token as AnyObject,
                              "device":"ios" as AnyObject]
            print("guest paramter : \(self.parameter!)")
            
            self.myData.set("guest", forKey: "loginId")
            self.myData.set("guest", forKey: "loginEmail")
            
            self.requestLogin(self.parameter)
        }
    }
    
    func login(parameters : [String], _ completion : @escaping () -> ()) {
        let postString = "id=\(parameters[0])&email=\(parameters[1])&token=\(parameters[2])&device=ios"
        var request = try! URLRequest(url: URL(string: domain + loginURL)!, method: .post, headers: nil)
        request.httpBody = postString.data(using: .utf8)

        Alamofire.request(request).response { (response) in
            let json = try! JSONSerialization.jsonObject(with: response.data!, options: .allowFragments)
            if let json = json as? [String : Int] {
                if json["return"] == 1 {
                    completion()
                }
            }
        }
    }

    
    func requestLogin(_ parameter : [String: AnyObject]) {
        Alamofire.request(domain + loginURL,
                          method: .post,
                          parameters: parameter,
                          encoding: URLEncoding.default,
                          headers: nil).response { (response) in
                            self.loginCheck(response.data!)
        }
    }
    
    func loginCheck(_ data: Data){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        do {
            let readableJSON = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String: AnyObject]
            print(readableJSON)
            
            if readableJSON["return"] as? Int == 1 {
                var id = ""
                
                if ((UserDefaults.standard.object(forKey: "loginId") as? Int) != nil) {
                    let loginID = UserDefaults.standard.object(forKey: "loginId") as! Int
                    id = String(describing: loginID)
                } else {
                    let loginID = UserDefaults.standard.object(forKey: "loginId") as! String
                    id = loginID
                }
                let email = UserDefaults.standard.object(forKey: "loginEmail") as! String
                
                if let tabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController") as? TabBarController {
                    if let homeNVC = tabBarController.viewControllers![0] as? NavigationController {
                        if let homeVC = homeNVC.viewControllers.first as? HomeController {
                            self.loginDelegate = homeVC
                            self.present(tabBarController, animated: true, completion: {
                                UserDefaults.standard.set(id, forKey: "id")
                                UserDefaults.standard.set(email, forKey: "email")
                                self.loginDelegate?.login(id: id, email: email)
                            })
                        }
                    }
                }
            } else {
                if let joinController = storyboard.instantiateViewController(withIdentifier: "JoinController") as? JoinController {
                    self.present(joinController, animated: true, completion: nil)
                }
            }
        } catch {
            print(error)
            basicAlert(target: self, title: nil, message: "파싱 실패")
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}

