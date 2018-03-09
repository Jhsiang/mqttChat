//
//  ViewController.swift
//  mqttChat
//
//  Created by Jim Chuang on 2017/12/14.
//  Copyright © 2017年 nhr. All rights reserved.
//

import UIKit
import CryptoSwift
import CocoaMQTT

class LoginViewController: UIViewController, UITextFieldDelegate, myMqttServerDelegate {
    
    @IBOutlet var backgroundIV: UIImageView!
    @IBOutlet var nicknameText: UITextField!
    @IBOutlet var waitImageView: UIImageView!
    var isConnectToMqttServer:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.string(forKey: PREF_KEY_SAVE_NICKNAME) == nil || UserDefaults.standard.string(forKey: PREF_KEY_SAVE_NICKNAME) == ""
        {
            waitImageView.isHidden = true
        }
        else
        {
            backgroundIV.isHidden = true
            waitImageView.isHidden = false
        }
        
        myMqttServer.shared.connectToTestMqttServer()
        myMqttServer.shared.delegate = self
        nicknameText.delegate = self
        
        let deviceToken = UIDevice.current.identifierForVendor?.uuidString
        DLog(message: "deviceToken = \(String(describing: deviceToken))")
        
    }
    
    func presentVC()
    {
        self.performSegue(withIdentifier: "seque_login_to_main", sender: nil)
    }
    
    func publish()
    {
        if let msg = UserDefaults.standard.string(forKey: PREF_KEY_SAVE_NICKNAME)
        {
            let onlineMsg = "ON"+msg
            let encodeMsg = Endcode_AES_ECB(strToEncode: onlineMsg)
            myMqttServer.shared.publishMqttTopic(topic: LOGIN_CHANNEL, message: encodeMsg, qos: 1)            
        }
    }

//MARK: - myMqttServerDelegate
    func mqttMessageArrive(topic: String, withMessage message: String) {
        let decodeMsg = Decode_AES_ECB(strToDecode: message)
        DLog(message: "my topic (\(topic)) message = (\(message)) decode = \(decodeMsg))")
    }
    
    func mqttConnectState(connectState: Int) {
        
        let accept = 0
        if connectState == accept
        {
            isConnectToMqttServer = true
            myMqttServer.shared.subscribeMqttTopic(topic: CHAT_CHANNEL)
            myMqttServer.shared.subscribeMqttTopic(topic: LOGIN_CHANNEL)
            if UserDefaults.standard.string(forKey: PREF_KEY_SAVE_NICKNAME) != nil && UserDefaults.standard.string(forKey: PREF_KEY_SAVE_NICKNAME) != ""
            {
                Timer.every(10, publish)
                presentVC()
            }
        }
        else
        {
            DLog(message: "connect state = \(connectState)")
        }
    }
    
    func didSubscribeTopic(topic: String) {
        DLog(message: "subscribe = (\(topic))")
    }
    
    func didUnsubscribeTopic(topic: String) {
        DLog(message: "unsubscribe = (\(topic))")
    }
    
//MARK: - UITextfielddelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nicknameText.resignFirstResponder()
        return true
    }

//MARK: - Login Button
    @IBAction func loginBtn(_ sender: Any) {
        if nicknameText.text != nil && nicknameText.text != ""
        {
            let nicknameString = nicknameText.text!
            UserDefaults.standard.set(nicknameString, forKey: PREF_KEY_SAVE_NICKNAME)
            if isConnectToMqttServer
            {
                Timer.every(10, publish)
                presentVC()
            }
        }
        else
        {
            DLog(message: "nickname fail")
        }
    }

    


}
