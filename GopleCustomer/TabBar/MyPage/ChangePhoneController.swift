//
//  ChangePhoneController.swift
//  GopleCustomer
//
//  Created by 김민주 on 2017. 12. 6..
//  Copyright © 2017년 김민주. All rights reserved.
//

import UIKit
import Alamofire

class ChangePhoneController: UIViewController {

    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var numberTF: UITextField!
    
    @IBOutlet weak var phoneBtn: UIButton!
    @IBOutlet weak var numberBtn: UIButton!
    
    static var hiphone = ""
    var number = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        numberTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControlEvents.editingChanged)

        // Do any additional setup after loading the view.
    }
    
    @IBAction func sendNumber(_ sender: UIButton) {
        if phoneTF.text?.isEmpty == true {
            
            return showToast(message: "전화번호를 입력해주세요.")
        } else {
            
            guard isValidPhoneNum(str: phoneTF.text!) else {
                
                return showToast(message: "올바른 전화번호 형식이 아닙니다.")
            }
            
            number = random(length: 6)
            print("인증번호 : \(number)")
            
            let phoneNum = phoneTF.text!
            
            let index = phoneNum.index(phoneNum.startIndex, offsetBy: 3)
            
            var first = phoneNum.substring(to: index)
            first += "-"
            
            var start = phoneNum.index(phoneNum.startIndex, offsetBy: 3)
            var end = phoneNum.index(phoneNum.endIndex, offsetBy: -4)
            var length = start..<end
            
            var second = phoneNum.substring(with: length)
            second += "-"
            
            start = phoneNum.index(phoneNum.startIndex, offsetBy: 7)
            end = phoneNum.index(phoneNum.endIndex, offsetBy: 0)
            length = start..<end
            
            let last = phoneNum.substring(with: length)
            
            ChangePhoneController.hiphone = first + second + last
            
            print(ChangePhoneController.hiphone)
            
            let paramter = ["phone":ChangePhoneController.hiphone,
                            "num":number]
            print("paramter : \(paramter)")
            
            Alamofire.request(domain + certifiNumURL,
                              method: .post,
                              parameters: paramter,
                              encoding: URLEncoding.default,
                              headers: nil).response(completionHandler: {
                                (response) in
                                self.parsePhone(response.data!)
                              })
            
        }
    }
    
    @IBAction func checkNumber(_ sender: UIButton) {
        if numberTF.text?.isEmpty == true {
            showToast(message: "인증번호를 입력해주세요.")
        } else {
            
            if number == "" {
                showToast(message: "인증번호를 발급받아주세요.")
            } else {
                
                guard numberTF.text == number else {
                    return showToast(message: "인증번호가 일치하지 않습니다.")
                    
                }
                
                showToast(message: "전화번호가 인증되었습니다.")
            }
        }
    }
    
}

extension ChangePhoneController {
    func parsePhone(_ data: Data) {
        do {
            let readableJSON = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String : AnyObject]
            
            print("check number Number : \(readableJSON)")
            
            if readableJSON["return"] as? Int == 1 {
                showToast(message: "인증번호가 전송되었습니다.")
                
            } else if readableJSON["return"] as? Int == 2 {
                showToast(message: "중복된 전화번호입니다.")
                phoneTF.text = ""
            } else {
                showToast(message: "전화번호를 가져오지 못했습니다.")
            }
        } catch {
            showToast(message: "파싱실패")
        }
    }
}

extension ChangePhoneController {
    func textFieldDidChange(_ textField: UITextField) {
        
        if textField == phoneTF.self {
            if textField.text! != "" {
                self.phoneBtn.setImage(#imageLiteral(resourceName: "mypage_alert_ok_p"), for: .normal)
            } else {
                self.phoneBtn.setImage(#imageLiteral(resourceName: "mypage_alert_ok"), for: .normal)
            }
        } else if textField == numberTF.self {
            if textField.text! != "" {
                self.numberBtn.setImage(#imageLiteral(resourceName: "mypage_alert_ok_p"), for: .normal)
            } else {
                self.numberBtn.setImage(#imageLiteral(resourceName: "mypage_alert_ok"), for: .normal)
            }
        }
    }
}
