//
//  ChatViewController.swift
//  mqttChat
//
//  Created by Jim Chuang on 2017/12/22.
//  Copyright © 2017年 nhr. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,myMqttServerDelegate {
    
    @IBOutlet var chatText: UITextField!
    @IBOutlet var chatTableView: UITableView!
    
    @IBOutlet var chatTableLayoutView: UIView!
    var chatArray = Array<String>()
    
    @IBOutlet var chatSendtextLayoutView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatText.delegate = self
        
    }

    override func viewDidAppear(_ animated: Bool) {
        myMqttServer.shared.delegate = self
        
        // 註冊鍵盤出現/消失事件
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(note:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHidden(note:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // 取消註冊鍵盤出現/消失事件≥
        NotificationCenter.default.removeObserver(self,name:NSNotification.Name.UIKeyboardWillShow, object:nil)
        NotificationCenter.default.removeObserver(self,name:NSNotification.Name.UIKeyboardWillHide, object:nil)
    }
    
    @objc func keyboardWillShow(note: NSNotification) {
        let userInfo = note.userInfo!
        let  keyBoardBounds = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        DLog(message: keyBoardBounds)
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let deltaY = keyBoardBounds.size.height
        let animations:(() -> Void) = {
            self.view.transform = CGAffineTransform(translationX: 0, y: -deltaY + (self.tabBarController?.tabBar.frame.size.height)!)
        }

        //動畫持續時間
        if duration > 0 {
            let options = UIViewAnimationOptions(rawValue: UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
            UIView.animate(withDuration: duration, delay: 0, options:options, animations: animations, completion: nil)
        }else{
            animations()
        }
    }

    @objc func keyboardWillHidden(note: NSNotification) {
        let userInfo  = note.userInfo!
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let animations:(() -> Void) = {
            self.view.transform = CGAffineTransform.identity
        }
        if duration > 0 {
            let options = UIViewAnimationOptions(rawValue: UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
            UIView.animate(withDuration: duration, delay: 0, options:options, animations: animations, completion: nil)
        }else{
            animations()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendBtn(_ sender: Any) {
        chatText.resignFirstResponder()
        if chatText.text != ""
        {
            let nickName = UserDefaults.standard.string(forKey: PREF_KEY_SAVE_NICKNAME) ?? "0"
            let nickNameCount = nickName.count
            let chatString = "\(nickNameCount)" + nickName + chatText.text!
            let encodeMsg = Endcode_AES_ECB(strToEncode: chatString)
            myMqttServer.shared.publishMqttTopic(topic: CHAT_CHANNEL, message: encodeMsg, qos: 2)
            chatText.text = ""
        }
    }
    

//MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return chatArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        cell = tableView.dequeueReusableCell(withIdentifier: "chatCell")!
        let chatString = cell.viewWithTag(1) as! UILabel
        chatString.text = chatArray[indexPath.row]

        return cell
    }

//MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Chat room"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        DLog(message: view)
    }
    
//MARK: - MqttServerDelegate
    func mqttMessageArrive(topic: String, withMessage message: String) {
        let decodeMsg = Decode_AES_ECB(strToDecode: message)
        DLog(message: "my topic (\(topic)) message = (\(message)) decode = \(decodeMsg))")
        
        if decodeMsg != ""
        {
            if let nickNameCount = Int(decodeMsg.mySubString(to: 1))
            {
                let tempMsg = decodeMsg.mySubString(from: 1)
                let nickName = tempMsg.mySubString(to: nickNameCount)
                let realMsg = tempMsg.mySubString(from: nickNameCount)
                let publishMsg = nickName + ":" + "「" + realMsg + "」"
                chatArray.append(publishMsg)
                chatTableView.reloadData()
            }
        }
    }
    
    func mqttConnectState(connectState: Int) {

    }
    
    func didSubscribeTopic(topic: String) {
       
    }
    
    func didUnsubscribeTopic(topic: String) {
 
    }

//MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        chatText.resignFirstResponder()
        return true
    }
    
}
