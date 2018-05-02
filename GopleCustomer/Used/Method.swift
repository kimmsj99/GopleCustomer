//
//  Method.swift
//  Gople
//
//  Created by 김민주 on 2017. 11. 9..
//  Copyright © 2017년 김민주. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import Alamofire
import PopupDialog

//기본 Alert
public func basicAlert(target: UIViewController, title: String?, message: String){
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
    
    alert.addAction(okAction)
    target.present(alert, animated: true, completion: nil)
}

//키보드에 닫기 버튼 추가
public func addToolBar(target: UIView, textField: UITextField) {
    let keyboardToolbar = UIToolbar()
    keyboardToolbar.sizeToFit()
    let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                        target: nil, action: nil)
    let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done,
                                        target: target, action: #selector(UIView.endEditing(_:)))
    keyboardToolbar.items = [flexBarButton, doneBarButton]
    textField.inputAccessoryView = keyboardToolbar
}

//인증번호 만들기
public func random(length: Int = 6) -> String {
    let base = "0123456789"
    var randomString: String = ""
    
    for _ in 0..<length {
        let randomValue = arc4random_uniform(UInt32(base.characters.count))
        randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
    }
    return randomString
}

//핸드폰 정규식
public func isValidPhoneNum(str: String) -> Bool{
    let phoneNumRegEx = "^\\d{3}\\d{4}\\d{4}$"
    
    let phoneNumTest = NSPredicate(format: "SELF MATCHES %@", phoneNumRegEx)
    return phoneNumTest.evaluate(with: str)
}

//패스워드 정규식
public func isValidPassword(str: String) -> Bool{
//    let passwordRegEx = "&(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{6}$"
    let passwordRegEx = "^[a-zA-Z0-9]*$"
    
    let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
    return passwordTest.evaluate(with: str)
}

//네비게이션바 타이틀
public func navigationTitle(_ target: UIViewController, _ title: String){
    let navibar = target.navigationItem
    navibar.title = title
}

//최신 유저 정보 가져오기
func requestUserInfo(){
    if let idx = UserDefaults.standard.object(forKey: "idx") as? String {
        let parameter = ["idx":idx]
        
        DispatchQueue.global().sync {
            Alamofire.request(domain + newUserInfoURL,
                              method: .post,
                              parameters: parameter,
                              encoding: URLEncoding.default,
                              headers: nil).response(completionHandler: { (response) in
                                do {
                                    let readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! [String : AnyObject]
                                    print(readableJSON)
                                    print("업데이트")
                                    
                                    let idx = readableJSON["idx"] as! String
                                    let name = readableJSON["name"] as! String
                                    let phone = readableJSON["phone"] as! String
                                    if let marriage = readableJSON["marriage"] as? String {
                                        UserDefaults.standard.set(marriage, forKey: "marriage")
                                    }
                                    
                                    if let recom = readableJSON["recom"] as? String {
                                        UserDefaults.standard.set(recom, forKey: "recom")
                                    }
                                    
//                                    let alert_event = readableJSON["alert_event"] as! String
//                                    let alert_notice = readableJSON["alert_notice"] as! String
//                                    let alert_time = readableJSON["alert_time"] as! String
//                                    
//                                    if alert_event == "1" {
//                                        UserDefaults.standard.set(true, forKey: "alert_event")
//                                    } else {
//                                        UserDefaults.standard.set(false, forKey: "alert_event")
//                                    }
//
//                                    if alert_notice == "1" {
//                                        UserDefaults.standard.set(true, forKey: "alert_notice")
//                                    } else {
//                                        UserDefaults.standard.set(false, forKey: "alert_notice")
//                                    }
//
//                                    if alert_time == "1" {
//                                        UserDefaults.standard.set(true, forKey: "alert_time")
//                                    } else {
//                                        UserDefaults.standard.set(false, forKey: "alert_time")
//                                    }
                                    
                                    UserDefaults.standard.set(idx, forKey: "idx")
                                    UserDefaults.standard.set(name, forKey: "name")
                                    UserDefaults.standard.set(phone, forKey: "phone")
                                    
                                } catch{
                                    print(error)
                                    print("파싱 실패")
                                }
                              })
        }
    }
        
}

public func gradationButton(_ target: UIViewController, _ button: UIButton) {
    
    let gradientLayer = CAGradientLayer()
    
    let colorLeft = UIColor.init(hex: "1dece6").cgColor
    let colorRight = UIColor.init(hex: "1dd5ec").cgColor
    
    gradientLayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: target.view.frame.width, height: button.frame.height))
    gradientLayer.colors = [colorLeft, colorRight]
    gradientLayer.startPoint = CGPoint(x: 0, y: 0)
    gradientLayer.endPoint = CGPoint(x: 1, y: 0)
    gradientLayer.locations = [0, 1]
    button.layer.addSublayer(gradientLayer)
}

public func getImageWithColorPosition(color: UIColor, size: CGSize, lineSize: CGSize) -> UIImage {
    
    let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    let rectLine = CGRect(x: 0, y: size.height-lineSize.height, width: lineSize.width, height: lineSize.height)
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    UIColor.clear.setFill()
    UIRectFill(rect)
    color.setFill()
    UIRectFill(rectLine)
    let image = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return image
}

public func locationSettingWebView(url: String, lat: String, lon: String, wkWebView: WKWebView) {
    
    let javascriptPOSTRedirect: String = "" +
        "var form = document.createElement('form');" +
        "form.method = 'POST';" +
        "form.action = '\(url)';" +
        "" +
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

public func defaultPopupDialog(target: UIViewController, title: String, message: String, completion: @escaping () -> ()) {
    let popup = PopupDialog(title: title, message: message)
    popup.transitionStyle = .bounceDown
    
    let okButton = DefaultButton(title: "확인", height: 48, dismissOnTap: true, action: {
        completion()
    })
    
    popup.addButton(okButton)
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
    
    target.present(popup, animated: true, completion: nil)
}
