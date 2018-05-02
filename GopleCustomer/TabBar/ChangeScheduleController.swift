//
//  ChangeScheduleController.swift
//  GopleCustomer
//
//  Created by 김민주 on 2017. 12. 13..
//  Copyright © 2017년 김민주. All rights reserved.
//

import UIKit

class ChangeScheduleController: UIViewController {

    @IBOutlet weak var delete: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delete.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))

        // Do any additional setup after loading the view.
    }
    
    func endEditing() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
