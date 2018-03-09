//
//  SettingViewController.swift
//  mqttChat
//
//  Created by Jim Chuang on 2017/12/26.
//  Copyright © 2017年 nhr. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet var renameText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        renameText.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    @IBAction func renameBtn(_ sender: Any) {
        
        if renameText.text != nil && renameText.text != ""
        {
            let renameString = renameText.text!
            UserDefaults.standard.set(renameString, forKey: PREF_KEY_SAVE_NICKNAME)
        }
        else
        {
            DLog(message: "rename fail")
        }
    }
    
//MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        renameText.resignFirstResponder()
        return true
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  

}
