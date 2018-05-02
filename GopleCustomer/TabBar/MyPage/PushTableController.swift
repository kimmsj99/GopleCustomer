//
//  PushTableController.swift
//  GopleCustomer
//
//  Created by 김민주 on 2017. 11. 15..
//  Copyright © 2017년 김민주. All rights reserved.
//

import UIKit
import Alamofire

class PushTableController: UITableViewController {
    
    let idx = UserDefaults.standard.object(forKey: "idx") as! String
    let myData = UserDefaults.standard
    
    var viewNavBar = UIView()
    let backBtn = UIButton()
    
    @IBOutlet weak var eventSwitch: UIButton!
    @IBOutlet weak var noticeSwitch: UIButton!
    @IBOutlet weak var reserveSwitch: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        if myData.bool(forKey: "alert_event") == true {
            eventSwitch.setImage(#imageLiteral(resourceName: "push_on"), for: .normal)
        } else {
            eventSwitch.setImage(#imageLiteral(resourceName: "push_off"), for: .normal)
        }
        
        if myData.bool(forKey: "alert_notice") == true {
            noticeSwitch.setImage(#imageLiteral(resourceName: "push_on"), for: .normal)
        } else {
            noticeSwitch.setImage(#imageLiteral(resourceName: "push_off"), for: .normal)
        }
        
        if myData.bool(forKey: "alert_time") == true {
            reserveSwitch.setImage(#imageLiteral(resourceName: "push_on"), for: .normal)
        } else {
            reserveSwitch.setImage(#imageLiteral(resourceName: "push_off"), for: .normal)
        }
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.tableFooterView?.isHidden = true
        self.tableView.backgroundColor = UIColor.init(hex: "ffffff")
        
        self.tableView.separatorStyle = .singleLine
        self.tableView.separatorColor = UIColor(hex: "cccccc")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        createNavigationBar()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20))
        header.backgroundColor = UIColor.white
        return header
        
    }
    
    //Header Height
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 14
    }
    
    @IBAction func eventPush(_ sender: UIButton) {
        var eventAlert = ""
        sender.isSelected = !sender.isSelected

        myData.set(sender.isSelected, forKey: "alert_event")

        if sender.isSelected {
            sender.setImage(#imageLiteral(resourceName: "push_on"), for: .normal)
            eventAlert = "1"
        } else {
            sender.setImage(#imageLiteral(resourceName: "push_off"), for: .normal)
            eventAlert = "0"
        }

        let parameter = ["type":"alert_event",
                         "alert":eventAlert,
                         "idx":idx]
        print(parameter)

        requestAlert(parameter)

    }
    
    @IBAction func noticePush(_ sender: UIButton) {
        var noticeAlert = ""
        sender.isSelected = !sender.isSelected
        
        myData.set(sender.isSelected, forKey: "alert_notice")
        
        if sender.isSelected {
            sender.setImage(#imageLiteral(resourceName: "push_on"), for: .normal)
            noticeAlert = "1"
        } else {
            sender.setImage(#imageLiteral(resourceName: "push_off"), for: .normal)
            noticeAlert = "0"
        }
        
        let parameter = ["type":"alert_notice",
                         "alert":noticeAlert,
                         "idx":idx]
        print(parameter)
        
        requestAlert(parameter)
    }
    
    @IBAction func reservePush(_ sender: UIButton) {
        var reserveAlert = ""
        sender.isSelected = !sender.isSelected
        
        myData.set(sender.isSelected, forKey: "alert_time")
        
        if sender.isSelected {
            sender.setImage(#imageLiteral(resourceName: "push_on"), for: .normal)
            reserveAlert = "1"
        } else {
            sender.setImage(#imageLiteral(resourceName: "push_off"), for: .normal)
            reserveAlert = "0"
        }
        
        let parameter = ["type":"alert_time",
                         "alert":reserveAlert,
                         "idx":idx]
        print(parameter)
        
        requestAlert(parameter)
    }
    
    func requestAlert(_ parameter : [String: String]){
        Alamofire.request(domain + alertURL,
                          method: .post,
                          parameters: parameter,
                          encoding: URLEncoding.default,
                          headers: nil).response(completionHandler: { (response) in
                            do {
                                let readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! [String : AnyObject]
                                
                                print(readableJSON)
                                
                                if readableJSON["return"] as? Int == 1 {
                                    print("푸시 변경 성공")
                                    
                                    requestUserInfo()
                                    
                                } else {
                                    print("푸시 변경 실패")
                                }
                                
                            } catch {
                                basicAlert(target: self, title: nil, message: "파싱 실패")
                            }
                          })
    }
    
}

extension PushTableController {
    func createNavigationBar() {
        viewNavBar = UIView(frame: CGRect(
            origin: CGPoint(x: 0, y: 0),
            size: CGSize(width: self.view.frame.size.width, height: 58)))
        viewNavBar.backgroundColor = UIColor.white
        
        let title = UILabel()
        title.text = "알림 설정"
        title.font = UIFont(name: "DaeHan-Bold", size: 20)
        title.textColor = textColor
        title.frame = CGRect(x: 0, y: 20, width: 250, height: 20)
        title.center.x = self.view.frame.width / 2
        title.textAlignment = .center
        viewNavBar.addSubview(title)
        
        backBtn.frame = CGRect(x: 9, y: 14, width: 42, height: 31)
        backBtn.setImage(#imageLiteral(resourceName: "back_black"), for: .normal)
        backBtn.addTarget(self, action: #selector(doneBtn(_:)), for: .touchUpInside)
        viewNavBar.addSubview(backBtn)
        
        let menu = UIButton()
        menu.setImage(#imageLiteral(resourceName: "hamburger_black"), for: .normal)
        menu.frame.size = CGSize(width: 47, height: 41)
        menu.frame.origin.x = self.view.frame.width - (5 + menu.frame.width)
        menu.center.y = viewNavBar.frame.height / 2
        menu.addTarget(self, action: #selector(showMenu(_:)), for: .touchUpInside)
        viewNavBar.addSubview(menu)
        
        let underline = UIView(frame: CGRect(x: 0, y: viewNavBar.frame.height - 0.5, width: self.view.frame.width, height: 0.5))
        underline.backgroundColor = UIColor.init(hex: "cccccc")
        viewNavBar.addSubview(underline)
        self.navigationController?.navigationBar.addSubview(viewNavBar)
    }
    
    func doneBtn(_ sender: UIButton) {
        viewNavBar.removeFromSuperview()
        self.navigationController?.popViewController(animated: true)
    }
    
    func showMenu(_ sender: UIButton) {
        if let hamburgerVC = self.storyboard?.instantiateViewController(withIdentifier: "HamburgerController") as? HamburgerController {
            self.present(hamburgerVC, animated: true, completion: nil)
        }
    }
}
