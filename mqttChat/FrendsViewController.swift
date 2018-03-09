//
//  FrendsViewController.swift
//  mqttChat
//
//  Created by Jim Chuang on 2017/12/26.
//  Copyright © 2017年 nhr. All rights reserved.
//

import UIKit

class FrendsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,myMqttServerDelegate {
    
    var myfrends = Array<String>()
    
    @IBOutlet var frendsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DLog(message: "appear")
        myMqttServer.shared.delegate = self
        
        if let msg = UserDefaults.standard.string(forKey: PREF_KEY_SAVE_NICKNAME)
        {
            let onlineMsg = "ON"+msg
            let encodeMsg = Endcode_AES_ECB(strToEncode: onlineMsg)
            myMqttServer.shared.publishMqttTopic(topic: LOGIN_CHANNEL, message: encodeMsg, qos: 1)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        DLog(message: "disappear")
    }
    
//MARK: - UItableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //DLog(message: indexPath.row)
    }
    
//MARK: - UItableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        cell = tableView.dequeueReusableCell(withIdentifier: "frendsCell")!
        let nickname = cell.viewWithTag(1) as! UILabel
        nickname.text = myfrends[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return myfrends.count
    }
    
//MARK: - MqttServerDelegate
    func mqttMessageArrive(topic: String, withMessage message: String) {
        
        let decodeMsg = Decode_AES_ECB(strToDecode: message)
        DLog(message: "my topic (\(topic)) message = (\(message)) decode = \(decodeMsg))")
        
        if decodeMsg.count != 0
        {
            // 從Login channel 確認好友上線狀態
            if topic == LOGIN_CHANNEL
            {
                // 上線時會續持放出 "ON" + 匿稱
                if decodeMsg.prefix(2) == "ON"
                {
                    // 上線時，新增好友匿稱至陣列
                    if myfrends.index(of: decodeMsg.mySubString(from: 2)) != nil
                    {
                        // 匿稱存在好友陣列裡，不新增
                    }
                    else
                    {
                        // 匿稱不在好友陣列裡，新增好友
                        myfrends.append(decodeMsg.mySubString(from: 2))
                        self.frendsTableView.reloadData()
                    }
                }
                    
                    // 退回背景時會放出 "OFF" + 匿稱
                else if decodeMsg.prefix(3) == "OFF"
                {
                    // 離線時，刪除陣列裡的好友匿稱
                    if let index = myfrends.index(of: decodeMsg.mySubString(from: 3))
                    {
                        myfrends.remove(at: index)
                        self.frendsTableView.reloadData()
                    }
                }
            }
        }else {DLog(message: "haha")}
    }
    
    func mqttConnectState(connectState: Int) {
        DLog(message: connectState)
    }
    
    func didSubscribeTopic(topic: String) {
        
    }
    
    func didUnsubscribeTopic(topic: String) {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}
