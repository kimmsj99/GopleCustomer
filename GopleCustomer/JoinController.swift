//
//  ViewController.swift
//  GopleCustomer
//
//  Created by 김민주 on 2017. 12. 1..
//  Copyright © 2017년 김민주. All rights reserved.
//

import UIKit
import Alamofire
import PopupDialog

class JoinController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var centerView: UIView!
    
    @IBOutlet weak var topConstant: NSLayoutConstraint!
    @IBOutlet weak var centerConstant: NSLayoutConstraint!
    @IBOutlet weak var centerConstant2: NSLayoutConstraint!
    
    @IBOutlet weak var backImg: UIImageView!
    @IBOutlet weak var backHeight: NSLayoutConstraint!
    
    @IBOutlet weak var phoneNumBtn: UIButton!
    @IBOutlet weak var certifiNumBtn: UIButton!
    
    @IBOutlet weak var overTime: UILabel!
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var phoneNumTF: UITextField!
    @IBOutlet weak var certifiNumTF: UITextField!
    @IBOutlet weak var recommenderTF: UITextField!
    @IBOutlet weak var marryDateTF: UITextField!
    
    @IBOutlet weak var marryLabel: UILabel!
    @IBOutlet weak var noMarryDate: UIButton!
    
    @IBOutlet weak var allAgreeBtn: UIButton!
    @IBOutlet weak var serviceBtn: UIButton!
    @IBOutlet weak var privacyBtn: UIButton!
    @IBOutlet weak var locationBtn: UIButton!
    
    
    @IBOutlet weak var joinBtn: UIButton!
    
    let myData = UserDefaults.standard
    
    var timer: Timer!
    var certificationNum = ""
    var seconds = 180
    
    static var userId: String!
    static var userEmail: String!
    static var name: String!
    static var phoneNumHiphone: String!
    static var recom: String!
    static var marriage: String!
    
    let datePicker = UIDatePicker()
    let pickerParentView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var tmpView = UIView()
        
        scrollView.bounces = false
        
        if UIScreen.main.nativeBounds.height == 2436 {
            tmpView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 44.0 ))
            tmpView.backgroundColor = UIColor.red
            //            self.view.addSubview(tmpView)
        }
        
        backImg.image = #imageLiteral(resourceName: "join_back")
        backHeight.constant = 183
        
        if UIScreen.main.nativeBounds.height > 1334 {
            let centerY = self.view.frame.height - (138 + joinBtn.frame.height)
            
            centerConstant.constant = centerY / 2
            centerConstant2.constant = centerY / 2
            
            if phoneHeight == 2436 {
                topConstant.constant = -44
                backImg.image = #imageLiteral(resourceName: "join_back_x")
                backHeight.constant = 227
            }
        }
        
        overTime.isHidden = true
        
        marryDateTF.tintColor = .clear
        marryDateTF.textColor = .clear
        
        addToolBar(target: self.view, textField: nameTF)
        addToolBar(target: self.view, textField: phoneNumTF)
        addToolBar(target: self.view, textField: certifiNumTF)
        addToolBar(target: self.view, textField: recommenderTF)
        addToolBar(target: self.view, textField: marryDateTF)
        
        phoneNumTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        certifiNumTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(noti:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        scrollView.contentSize = contentView.frame.size
        
        gradationButton(self, joinBtn)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        UIApplication.shared.isStatusBarHidden = true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        
        if textField == phoneNumTF.self {
            if textField.text! != "" {
                self.phoneNumBtn.setImage(#imageLiteral(resourceName: "number_p"), for: .normal)
            } else {
                self.phoneNumBtn.setImage(#imageLiteral(resourceName: "number"), for: .normal)
            }
        } else if textField == certifiNumTF.self {
            if textField.text! != "" {
                certifiNumBtn.setImage(#imageLiteral(resourceName: "ok_p"), for: .normal)
            } else {
                certifiNumBtn.setImage(#imageLiteral(resourceName: "ok"), for: .normal)
            }
        }
    }
    
    func keyboardWillShow(noti: Notification) {
        
        guard let userInfo = noti.userInfo else { return }
        guard var keyboardFrame: CGRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }
    
    func keyboardWillHide(noti: Notification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @IBAction func certifiNumSend(_ sender: UIButton) {
        if phoneNumTF.text?.isEmpty == true {
            
            return popupDialog(title: "", message: "전화번호를 입력해주세요.")
        } else {
            
            guard isValidPhoneNum(str: phoneNumTF.text!) else {
                return popupDialog(title: "", message: "올바른 전화번호 형식이 아닙니다.")
            }
            
            certificationNum = random(length: 6)
            print("인증번호 : \(certificationNum)")
            
            let phoneNum = phoneNumTF.text!
            
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
            
            JoinController.phoneNumHiphone = first + second + last
            
            print(JoinController.phoneNumHiphone!)
            
            let paramter = ["phone":JoinController.phoneNumHiphone!,
                            "num":certificationNum]
            print("paramter : \(paramter)")
            
            Alamofire.request(domain + certifiNumURL,
                              method: .post,
                              parameters: paramter,
                              encoding: URLEncoding.default,
                              headers: nil).response(completionHandler: {
                                (response) in
                                self.parsePhoneNum(data: response.data!)
                              })
            
        }
    }
    
    func parsePhoneNum(data: Data) {
        do {
            let readableJSON = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String : AnyObject]
            
            print("check Certification Number : \(readableJSON)")
            
            if readableJSON["return"] as? Int == 1 {
                popupDialog(title: "", message: "인증번호가 전송되었습니다.")
                phoneNumBtn.titleLabel?.lineBreakMode = .byCharWrapping
                var buttonText: NSString = "인증번호\n재전송"
                
                var substring1 = ""
                var substring2 = ""
                
                var newlineRange: NSRange = buttonText.range(of: "\n")
                
                if(newlineRange.location != NSNotFound) {
                    substring1 = buttonText.substring(to: newlineRange.location)
                    substring2 = buttonText.substring(from: newlineRange.location)
                }
                
                let font = UIFont.systemFont(ofSize: 12)
                let textFont: [String:AnyObject] = [NSForegroundColorAttributeName: UIColor.blue, NSFontAttributeName: font]
                
                let attrString = NSMutableAttributedString(string: substring1, attributes: textFont)
                let attrString2 = NSMutableAttributedString(string: substring2, attributes: textFont)
                
                attrString.append(attrString2)
                
                phoneNumBtn.setAttributedTitle(attrString, for: .normal)
                
                runTimer()
                
            } else if readableJSON["return"] as? Int == 2 {
                popupDialog(title: "", message: "중복된 전화번호입니다.")
                phoneNumTF.text = ""
            } else {
                popupDialog(title: "", message: "전화번호를 가져오지 못했습니다.")
            }
        } catch {
            popupDialog(title: "", message: "파싱 실패")
        }
    }
    
    @IBAction func certifiNumCheck(_ sender: UIButton) {
        if certifiNumTF.text?.isEmpty == true {
            popupDialog(title: "", message: "인증번호를 입력해주세요.")
        } else {
            
            if certificationNum == "" {
                popupDialog(title: "", message: "인증번호를 발급받아주세요.")
            } else {
                
                guard certifiNumTF.text == certificationNum else {
                    return popupDialog(title: "", message: "인증번호가 일치하지 않습니다.")
                    
                }
                
                popupDialog(title: "", message: "전화번호가 인증되었습니다.")
                phoneNumTF.isEnabled = false
                phoneNumBtn.isEnabled = false
                phoneNumBtn.setImage(#imageLiteral(resourceName: "number"), for: .normal)
                certifiNumTF.isEnabled = false
                sender.isEnabled = false
                sender.setImage(#imageLiteral(resourceName: "ok"), for: .normal)
                overTime.isHidden = true
                stopTimer()
            }
        }
    }
    
    @IBAction func marryDateAction(_ sender: UIButton) {
        createDatePicker()
    }
    
    @IBAction func noMarryDateAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            marryDateTF.text = ""
            marryDateTF.isEnabled = false
            self.marryLabel.textColor = mainColor
            self.noMarryDate.setImage(#imageLiteral(resourceName: "check_p"), for: .normal)
            
        } else {
            marryDateTF.isEnabled = true
            marryLabel.textColor = UIColor.init(hex: "A9A9A9")
            self.noMarryDate.setImage(#imageLiteral(resourceName: "check"), for: .normal)
            if marryDateTF.text != "" {
                sender.isSelected = true
                self.marryLabel.textColor = mainColor
                self.noMarryDate.setImage(#imageLiteral(resourceName: "check_p"), for: .normal)
            }
        }
    }
    
    @IBAction func showService(_ sender: UIButton) {
        goWebView("service2")
    }
    
    @IBAction func serviceAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            self.serviceBtn.setImage(#imageLiteral(resourceName: "check_p"), for: .normal)
            
            if self.serviceBtn.isSelected == true && privacyBtn.isSelected == true && locationBtn.isSelected == true {
                self.allAgreeBtn.setImage(#imageLiteral(resourceName: "check_p"), for: .normal)
            }
            
        } else {
            self.serviceBtn.setImage(#imageLiteral(resourceName: "check"), for: .normal)
            
            if self.serviceBtn.isSelected == false || privacyBtn.isSelected == false || locationBtn.isSelected == false {
                self.allAgreeBtn.setImage(#imageLiteral(resourceName: "check"), for: .normal)
            }
        }
    }
    
    @IBAction func showPrivacy(_ sender: UIButton) {
        goWebView("privacy")
    }
    
    @IBAction func privacyAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            self.privacyBtn.setImage(#imageLiteral(resourceName: "check_p"), for: .normal)
            
            if self.serviceBtn.isSelected == true && privacyBtn.isSelected == true && locationBtn.isSelected == true {
                self.allAgreeBtn.setImage(#imageLiteral(resourceName: "check_p"), for: .normal)
            }
        } else {
            self.privacyBtn.setImage(#imageLiteral(resourceName: "check"), for: .normal)
            
            if self.serviceBtn.isSelected == false || privacyBtn.isSelected == false || locationBtn.isSelected == false {
                self.allAgreeBtn.setImage(#imageLiteral(resourceName: "check"), for: .normal)
            }
        }
    }
    
    @IBAction func showLocation(_ sender: UIButton) {
        goWebView("location")
    }
    
    @IBAction func locationAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            locationBtn.setImage(#imageLiteral(resourceName: "check_p"), for: .normal)
            
            if self.serviceBtn.isSelected == true && privacyBtn.isSelected == true && locationBtn.isSelected == true {
                self.allAgreeBtn.setImage(#imageLiteral(resourceName: "check_p"), for: .normal)
            }
        } else {
            locationBtn.setImage(#imageLiteral(resourceName: "check"), for: .normal)
            
            if self.serviceBtn.isSelected == false || privacyBtn.isSelected == false || locationBtn.isSelected == false {
                self.allAgreeBtn.setImage(#imageLiteral(resourceName: "check"), for: .normal)
            }
        }
    }
    
    @IBAction func allAgreeAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            self.serviceBtn.setImage(#imageLiteral(resourceName: "check_p"), for: .normal)
            self.privacyBtn.setImage(#imageLiteral(resourceName: "check_p"), for: .normal)
            self.locationBtn.setImage(#imageLiteral(resourceName: "check_p"), for: .normal)
            self.allAgreeBtn.setImage(#imageLiteral(resourceName: "check_p"), for: .normal)
            
            self.serviceBtn.isSelected = true
            self.privacyBtn.isSelected = true
            self.locationBtn.isSelected = true
            
        } else {
            self.serviceBtn.setImage(#imageLiteral(resourceName: "check"), for: .normal)
            self.privacyBtn.setImage(#imageLiteral(resourceName: "check"), for: .normal)
            self.locationBtn.setImage(#imageLiteral(resourceName: "check"), for: .normal)
            self.allAgreeBtn.setImage(#imageLiteral(resourceName: "check"), for: .normal)
            
            self.serviceBtn.isSelected = false
            self.privacyBtn.isSelected = false
            self.locationBtn.isSelected = true
        }
    }
    
    @IBAction func joinAction(_ sender: UIButton) {
        
        if UserDefaults.standard.object(forKey: "token") != nil && UserDefaults.standard.object(forKey: "loginId") != nil && UserDefaults.standard.object(forKey: "loginEmail") != nil{
            if nameTF.text?.isEmpty == true {
                popupDialog(title: "", message: "이름을 입력해주세요.")
                
            } else {
                if phoneNumTF.text?.isEmpty == true {
                    popupDialog(title: "", message: "전화번호를 입력해주세요.")
                    
                } else {
                    if certifiNumTF.text?.isEmpty == true {
                        popupDialog(title: "", message: "인증번호를 입력해주세요.")
                        
                    } else {
                        if marryDateTF.text?.isEmpty == true && noMarryDate.isSelected == false {
                            popupDialog(title: "", message: "결혼 예정일을 선택해주세요.")
                            
                        } else {
                            if serviceBtn.isSelected == false || privacyBtn.isSelected == false || locationBtn.isSelected == false {
                                popupDialog(title: "", message: "이용약관에 모두 동의해야 회원가입이 가능합니다.")
                                
                            } else {
                                
                                var id = ""
                                if ((UserDefaults.standard.object(forKey: "loginId") as? Int) != nil) {
                                    let loginID = UserDefaults.standard.object(forKey: "loginId") as! Int
                                    id = String(describing: loginID)
                                } else {
                                    let loginID = UserDefaults.standard.object(forKey: "loginId") as! String
                                    id = loginID
                                }
                                let email = UserDefaults.standard.object(forKey: "loginEmail") as! String
        
                                if let checkListTableController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CheckListTableController") as? CheckListTableController {
                                
                                    JoinController.userId = id
                                    JoinController.userEmail = email
                                    JoinController.name = nameTF.text!
                                    JoinController.recom = recommenderTF.text!
                                    JoinController.marriage = marryDateTF.text!
                                    
                                    self.present(checkListTableController, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func runTimer() {
        seconds = 180
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    
    func updateTimer() {
        
        seconds -= 1
        
        let minutesLeft = Int(seconds) / 60 % 60
        let secondsLeft = Int(seconds) % 60
        overTime.text = "\(minutesLeft):\(secondsLeft)"
        overTime.isHidden = false
        
        if seconds == 0 {
            stopTimer()
            popupDialog(title: "", message: "발송된 인증번호 시간이 만료되었습니다.")
        }
        
    }
    
    func stopTimer(){
        self.timer?.invalidate()
        self.timer = nil
        overTime.isHidden = true
        certificationNum = ""
    }
    
    func createDatePicker() {
        
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
        
        marryDateTF.textColor = textColor
        marryDateTF.text = dateFormatter.string(from: datePicker.date)
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.pickerParentView.frame.origin.y = self.view.frame.height
            self.pickerParentView.removeFromSuperview()
            
        }, completion: { (success) in
            if success {
                print("애니메이션 완료")
            }
        })
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func DoneBtn(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}

extension JoinController {
    func popupDialog(title: String, message: String){
        let popup = PopupDialog(title: title, message: message)
        popup.transitionStyle = .bounceDown
        
        let okButton = DefaultButton(title: "확인", height: 46, dismissOnTap: true, action: nil)
//        let cancelButton = CancelButton(title: "취소", height: 46, dismissOnTap: true, action: nil)
        
//        popup.addButtons([cancelButton, okButton])
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
        
        let cb = CancelButton.appearance()
        cb.titleFont = UIFont(name: "Daehan-Bold", size: 15)!
        cb.titleColor = UIColor.init(hex: "979797")
        cb.buttonColor = UIColor.white
        
        self.present(popup, animated: true, completion: nil)
    }
    
    func goWebView(_ str: String) {
        UserDefaults.standard.set(str, forKey: "webView")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let webViewController = storyboard.instantiateViewController(withIdentifier: "NWebViewController") as? NavigationController {
//            self.navigationController?.pushViewController(webViewController, animated: true)
            self.present(webViewController, animated: true, completion: nil)
        }
    }
}
