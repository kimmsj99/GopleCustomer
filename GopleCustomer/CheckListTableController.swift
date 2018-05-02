//
//  CheckListTableController.swift
//  GopleCustomer
//
//  Created by 김민주 on 2017. 11. 15..
//  Copyright © 2017년 김민주. All rights reserved.
//

import UIKit
import Alamofire
import DLRadioButton

class CheckListTableController: UITableViewController {
    
    weak var loginDelegate: LoginDelegate?
    
    var checkListName = [String]()
    var checkListValue = [String]()
    
    var list = [Dictionary](repeating : [String : String](), count : 16)
    var checkListJSON: String = ""
    
    @IBOutlet var interval: [NSLayoutConstraint]!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet var sdmb: [DLRadioButton]!
    @IBOutlet var buke: [DLRadioButton]!
    @IBOutlet var jurae: [DLRadioButton]!
    @IBOutlet var mc: [DLRadioButton]!
    @IBOutlet var food: [DLRadioButton]!
    @IBOutlet var play: [DLRadioButton]!
    @IBOutlet var video: [DLRadioButton]!
    @IBOutlet var hanbok: [DLRadioButton]!
    @IBOutlet var jewelry: [DLRadioButton]!
    @IBOutlet var silk: [DLRadioButton]!
    @IBOutlet var cloth: [DLRadioButton]!
    @IBOutlet var honeymoon: [DLRadioButton]!
    @IBOutlet var letter: [DLRadioButton]!
    @IBOutlet var car: [DLRadioButton]!
    @IBOutlet var gajun: [DLRadioButton]!
    @IBOutlet var gagu: [DLRadioButton]!
    
    var checkBoxArray = [[DLRadioButton]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        gradationButton(self, joinBtn)
        
        self.tableView.bounces = false
        
        self.tableView.separatorStyle = .singleLine
        self.tableView.separatorColor = UIColor(hex: "cccccc")
        
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 46))
        customView.backgroundColor = UIColor.red
        
        let joinBtn = UIButton()
        joinBtn.frame = customView.frame
        gradationButton(self, joinBtn)
        joinBtn.titleLabel?.font = UIFont(name: "Daehan-Bold", size: 18)
        joinBtn.titleLabel?.textColor = UIColor.white
        joinBtn.titleColor(for: .normal)
        joinBtn.addTarget(self, action: #selector(btnAction(_:)), for: .touchUpInside)
        
        if MyPageTableController.checkList == true {
            //마이페이지에서 들어왔을 때
            joinBtn.setTitle("수정 완료", for: .normal)
            
            checkListName.removeAll()
            checkListValue.removeAll()
            self.getCheckList()
        } else {
            //회원가입에서 들어왔을 때
            self.getDefaultCheckList()
            joinBtn.setTitle("Join", for: .normal)
        }
        customView.addSubview(joinBtn)
        self.tableView.tableFooterView = customView
        
//        joinBtn.frame.size = CGSize(width: self.view.frame.width, height: 46)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        UIApplication.shared.isStatusBarHidden = true
        
        for i in 0 ..< sdmb.count {
            sdmb[i].isUserInteractionEnabled = false
            buke[i].isUserInteractionEnabled = false
            jurae[i].isUserInteractionEnabled = false
            mc[i].isUserInteractionEnabled = false
            food[i].isUserInteractionEnabled = false
            play[i].isUserInteractionEnabled = false
            video[i].isUserInteractionEnabled = false
            hanbok[i].isUserInteractionEnabled = false
            jewelry[i].isUserInteractionEnabled = false
            silk[i].isUserInteractionEnabled = false
            cloth[i].isUserInteractionEnabled = false
            honeymoon[i].isUserInteractionEnabled = false
            letter[i].isUserInteractionEnabled = false
            car[i].isUserInteractionEnabled = false
            gajun[i].isUserInteractionEnabled = false
            gagu[i].isUserInteractionEnabled = false
        }
        
//        joinBtn.isUserInteractionEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 16
    }
    
    let valueArray = ["미완료", "완료", "필요없음"]

    func sortContainer() {
        sdmb.sort {
            $0.tag < $1.tag
        }
        buke.sort {
            $0.tag < $1.tag
        }
        jurae.sort {
            $0.tag < $1.tag
        }
        mc.sort {
            $0.tag < $1.tag
        }
        food.sort {
            $0.tag < $1.tag
        }
        play.sort {
            $0.tag < $1.tag
        }
        video.sort {
            $0.tag < $1.tag
        }
        hanbok.sort {
            $0.tag < $1.tag
        }
        jewelry.sort {
            $0.tag < $1.tag
        }
        silk.sort {
            $0.tag < $1.tag
        }
        cloth.sort {
            $0.tag < $1.tag
        }
        honeymoon.sort {
            $0.tag < $1.tag
        }
        letter.sort {
            $0.tag < $1.tag
        }
        car.sort {
            $0.tag < $1.tag
        }
        gajun.sort {
            $0.tag < $1.tag
        }
        gagu.sort {
            $0.tag < $1.tag
        }
    }
    
    func restore() {
        
        for i in 0..<interval.count {
            let between = (containerView.frame.width - (49 + 72.5 + 61)) / 2
            interval[i].constant = between
        }
        
        for i in 0 ..< list.count {
            switch i + 1 {
            case 1:
                if let value = Int(list[i]["value"]!) {
                    sdmb[value].isSelected = true
                }
                
            case 2 :
                if let value = Int(list[i]["value"]!) {
                    buke[value].isSelected = true
                }
                
            case 3 :
                if let value = Int(list[i]["value"]!) {
                    jurae[value].isSelected = true
                }
                
            case 4 :
                if let value = Int(list[i]["value"]!) {
                    mc[value].isSelected = true
                }
                
            case 5 :
                if let value = Int(list[i]["value"]!) {
                    food[value].isSelected = true
                }
                
            case 6 :
                if let value = Int(list[i]["value"]!) {
                    play[value].isSelected = true
                }
                
            case 7 :
                if let value = Int(list[i]["value"]!) {
                    video[value].isSelected = true
                }
                
            case 8 :
                if let value = Int(list[i]["value"]!) {
                    hanbok[value].isSelected = true
                }
                
            case 9 :
                if let value = Int(list[i]["value"]!) {
                    jewelry[value].isSelected = true
                }
                
            case 10 :
                if let value = Int(list[i]["value"]!) {
                    silk[value].isSelected = true
                }
                
            case 11 :
                if let value = Int(list[i]["value"]!) {
                    cloth[value].isSelected = true
                }
                
            case 12 :
                if let value = Int(list[i]["value"]!) {
                    honeymoon[value].isSelected = true
                }
                
            case 13 :
                if let value = Int(list[i]["value"]!) {
                    letter[value].isSelected = true
                }
                
            case 14 :
                if let value = Int(list[i]["value"]!) {
                    car[value].isSelected = true
                }
                
            case 15 :
                if let value = Int(list[i]["value"]!) {
                    gajun[value].isSelected = true
                }
                
            case 16 :
                if let value = Int(list[i]["value"]!) {
                    gagu[value].isSelected = true
                }
                
            default:
                return
            }
        }
        
        for i in 0 ..< sdmb.count {
            sdmb[i].isUserInteractionEnabled = true
            buke[i].isUserInteractionEnabled = true
            jurae[i].isUserInteractionEnabled = true
            mc[i].isUserInteractionEnabled = true
            food[i].isUserInteractionEnabled = true
            play[i].isUserInteractionEnabled = true
            video[i].isUserInteractionEnabled = true
            hanbok[i].isUserInteractionEnabled = true
            jewelry[i].isUserInteractionEnabled = true
            silk[i].isUserInteractionEnabled = true
            cloth[i].isUserInteractionEnabled = true
            honeymoon[i].isUserInteractionEnabled = true
            letter[i].isUserInteractionEnabled = true
            car[i].isUserInteractionEnabled = true
            gajun[i].isUserInteractionEnabled = true
            gagu[i].isUserInteractionEnabled = true
            
        }
        
//        joinBtn.isUserInteractionEnabled = true
    }
    
    @IBAction func selectedCheck(_ sender: DLRadioButton) {
        //value - 1 완료 / 0 미완료 / 2 필요없음
        list[sender.tag / 3] = [
            "idx" : String((sender.tag / 3) + 1),
            "name" : checkListName[(sender.tag / 3)],
            "value" : String(describing: valueArray.index(of: (sender.selected()?.titleLabel?.text)!)!)
        ]
        
        list.forEach {
            print($0)
        }
        print("-------------------------------------------------------")

    }
    
    func btnAction(_ sender: UIButton) {
        
        if MyPageTableController.checkList == true {
            //마이페이지에서 들어왔을 때
            self.jsonToString()
        } else {
            //회원가입에서 들어왔을 때
            self.joinAction()
        }
        
    }
    
    @IBAction func doneBtn(_ sender: UIButton) {
        
        if MyPageTableController.checkList == true {
            if let tabbarVC = self.presentingViewController as? TabBarController {
                tabbarVC.nextIdx = 4
            }
            MyPageTableController.checkList = false
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension CheckListTableController {
    func joinAction() {
        if let token = UserDefaults.standard.object(forKey: "token") {
            var id = ""
            if ((UserDefaults.standard.object(forKey: "loginId") as? Int) != nil) {
                let loginID = UserDefaults.standard.object(forKey: "loginId") as! Int
                id = String(describing: loginID)
            } else {
                let loginID = UserDefaults.standard.object(forKey: "loginId") as! String
                id = loginID
            }
            let email = UserDefaults.standard.object(forKey: "loginEmail") as! String
            
            var paramter: [String : Any]!
            
            //json -> String
            jsonToString()
            
            if JoinController.recom != "" && JoinController.marriage != "" {
                paramter = ["id":id,
                            "email":email,
                            "name":JoinController.name,
                            "phone":JoinController.phoneNumHiphone,
                            "recom":JoinController.recom,
                            "marriage":JoinController.marriage,
                            "list":"{ \"list\" : " + checkListJSON + " }",
                            "token":token,
                            "device":"ios"]
            } else {
                if JoinController.recom == "" && JoinController.marriage == "" {
                    paramter = ["id":id,
                                "email":email,
                                "name":JoinController.name,
                                "phone":JoinController.phoneNumHiphone,
                                "list":"{ \"list\" : " + checkListJSON + " }",
                                "token":token,
                                "device":"ios"]
                } else if JoinController.marriage == "" {
                    paramter = ["id":id,
                                "email":email,
                                "name":JoinController.name,
                                "phone":JoinController.phoneNumHiphone,
                                "recom":JoinController.recom,
                                "list":"{ \"list\" : " + checkListJSON + " }",
                                "token":token,
                                "device":"ios"]
                } else if JoinController.recom == "" {
                    paramter = ["id":id,
                                "email":email,
                                "name":JoinController.name,
                                "phone":JoinController.phoneNumHiphone,
                                "marriage":JoinController.marriage,
                                "list":"{ \"list\" : " + checkListJSON + " }",
                                "token":token,
                                "device":"ios"]
                }
            }
            print(paramter)
            
            Alamofire.request(domain + joinURL,
                              method: .post,
                              parameters: paramter,
                              encoding: URLEncoding.default,
                              headers: nil)

            UserDefaults.standard.set(id, forKey: "id")
            UserDefaults.standard.set(email, forKey: "email")

            UserDefaults.standard.removeObject(forKey: "loginId")
            UserDefaults.standard.removeObject(forKey: "loginEmail")

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
        }
    }
}

extension CheckListTableController {
    func getDefaultCheckList() {
        Alamofire.request(domain + checkListURL).response { (response) in
            do {
                let readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! NSDictionary
                print(readableJSON)
                
                DispatchQueue.main.async {
                    let readableArray = readableJSON["list"] as! NSArray
                    print(readableArray)
                    
                    for i in 0..<readableArray.count {
                        let row = readableArray[i] as? NSDictionary
                        let name = row!["name"] as? String
                        
                        self.checkListName.append(name!)
                        
                        self.list[i] = ["idx" : "\(i+1)", "name" : self.checkListName[i] , "value" : "0"]
                    }
                    
                    self.sortContainer()
                    self.restore()
                    
                }
                
            } catch {
                print(error)
            }
        }
    }
    func getCheckList() {
        guard let id = UserDefaults.standard.object(forKey: "id") as? String else {
            return
        }
        
        let parameter = ["id":id]
        print(parameter)
        
        Alamofire.request(domain + getCheckListURL,
                          method: .post,
                          parameters: parameter,
                          encoding: URLEncoding.default,
                          headers: nil).response(completionHandler: { (response) in
                            do {
                                let readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! NSDictionary
                                print(readableJSON)
                                
//                                if MyPageTableController.checkList != true {
                                if let strArray = readableJSON["list"] as? NSArray {

                                    print(strArray)

                                    for i in 0..<strArray.count {
                                        let strRow = strArray[i] as! [String : AnyObject]
                                        print(strRow)

                                        let name = strRow["name"] as! String
                                        var value: Int!
                                        if ((strRow["value"] as? String) != nil) {
                                            let strValue = strRow["value"] as! String
                                            value = Int(strValue)
                                        } else {
                                            value = strRow["value"] as! Int
                                        }
                                        
                                        
                                        print(name)
                                        print(value)

                                        self.checkListName.append(name)
                                        self.checkListValue.append(String(value))

                                        self.list[i] = ["idx" : "\(i+1)", "name" : self.checkListName[i] , "value" : self.checkListValue[i]]
                                    }
                                } else {
                                    let strArray = readableJSON["list"] as! String
                                    print(strArray)

                                    let data = strArray.data(using: .utf8)

                                    let jsonData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSArray
                                    print(jsonData)

                                    for i in 0..<jsonData.count {
                                        let strRow = jsonData[i] as! [String : AnyObject]
                                        print(strRow)

                                        let name = strRow["name"] as? String
                                        let value = strRow["value"] as? String

                                        self.checkListName.append(name!)
                                        self.checkListValue.append(value!)

                                        self.list[i] = ["idx" : "\(i+1)", "name" : self.checkListName[i] , "value" : self.checkListValue[i]]
                                    }
                                }
                                
//                                    }
//                                } else {
//                                    let strArray = readableJSON["list"] as! NSArray
//
////                                    let data = strArray.data(using: .utf8)
////
////                                    let jsonData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSArray
////                                    let jsonData = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as! NSArray
//                                    let jsonData = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as! NSDictionary
//                                    print(jsonData)
//
//                                    for i in 0..<jsonData.count {
////                                        let strRow = jsonData[i] as! String
////
////                                        let rowData = strRow.data(using: .utf8)
////                                        let rowJsonData = try JSONSerialization.jsonObject(with: rowData!, options: .allowFragments) as! NSDictionary
////
////                                        let name = rowJsonData["name"] as? String
////                                        let value = rowJsonData["value"] as? String
//
//                                        let strRow = jsonData[i] as! [String : AnyObject]
//                                        print(strRow)
//
//                                        let name = strRow["name"] as? String
//                                        let value = strRow["value"] as? String
//
//                                        self.checkListName.append(name!)
//                                        self.checkListValue.append(value!)
//
//                                        self.list[i] = ["idx" : "\(i+1)", "name" : self.checkListName[i] , "value" : self.checkListValue[i]]
//                                    }

                                self.sortContainer()
                                self.restore()

                            } catch {
                                print(error.localizedDescription)
//                                self.getDefaultCheckList()
                            }
                          })
    }
    
    func jsonToString() {
        
        do {
        
            var listForServer = list.map({ (dict) -> String in
                let jsonData = try! JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
                return String(data : jsonData, encoding : .utf8)!
            })

            listForServer = listForServer.map {
                $0.replacingOccurrences(of: "\n", with: "")
            }
            
            let jsonData = try JSONSerialization.data(withJSONObject: listForServer, options: .prettyPrinted)
            // here "jsonData" is the dictionary encoded in JSON data
            var jsonStr = String(data : jsonData, encoding : .utf8)!
            jsonStr = jsonStr.replacingOccurrences(of: "\n", with: "")
            jsonStr = jsonStr.replacingOccurrences(of: "\"{", with: "{")
            jsonStr = jsonStr.replacingOccurrences(of: "}\"", with: "}")
            jsonStr = jsonStr.replacingOccurrences(of: "\\", with: "")
            
//            let decoded = try JSONSerialization.jsonObject(with: jsonData, options: [.allowFragments])
            // here "decoded" is of type `Any`, decoded from JSON data
            
            checkListJSON = jsonStr
            
            if MyPageTableController.checkList == true {
                self.requestCheckList()
            }
            
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    func requestCheckList() {
        
        let id = UserDefaults.standard.object(forKey: "id") as! String
        
        let parameters = ["list":checkListJSON,
                          "id":id]
        print(parameters)
        
        Alamofire.request(domain + setCheckListURL,
                          method: .post,
                          parameters: parameters,
                          encoding: URLEncoding.default,
                          headers: nil).response { (response) in
                            do {
                                let readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as! NSDictionary
                                print("setCheckList: \(readableJSON)")

                                if readableJSON["return"] as? Int == 1{
                                    if let tabbarVC = self.presentingViewController as? TabBarController {
                                        tabbarVC.nextIdx = 4
                                    }
                                    self.dismiss(animated: true, completion: nil)
                                    MyPageTableController.checkList = false

                                } else {
                                    self.showToast(message: "체크리스트 변경 실패")
                                }
                            } catch {
                                print("setCheckList error : \(error)")
                            }
        }
        
    }
    
}

extension CheckListTableController {
    func calculateConstant(_ value : CGFloat ) -> CGFloat {
        let v = self.view.frame.width
        return (value / 375) * v
    }
}
