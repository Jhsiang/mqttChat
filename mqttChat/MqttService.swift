//
//  MqttService.swift
//  mqttChat
//
//  Created by Jim Chuang on 2017/12/21.
//  Copyright © 2017年 nhr. All rights reserved.
//

import UIKit
import CocoaMQTT

protocol myMqttServerDelegate {
    
    func mqttMessageArrive(topic: String, withMessage message: String)
    func mqttConnectState(connectState:Int)
    func didSubscribeTopic(topic:String)
    func didUnsubscribeTopic(topic:String)
}

class myMqttServer:CocoaMQTTDelegate {
    
    static let shared = myMqttServer()
    var delegate: myMqttServerDelegate?
    
    var myMqtt = CocoaMQTT(clientID: "test6655")
    
    func connectToTestMqttServer()
    {
        myMqtt.delegate = self
        myMqtt.clientID = ""
        
        myMqtt.host = "test.mosquitto.org"
        myMqtt.port = 1883
        myMqtt.username = nil
        myMqtt.password = nil
        
        myMqtt.autoReconnectTimeInterval = 2
        myMqtt.autoReconnect = true
        myMqtt.connect()
    }
    
    func didConnectFromMqttServer()
    {
        myMqtt.disconnect()
    }
    
    func subscribeMqttTopic(topic:String)
    {
        if topic != ""
        {
            myMqtt.subscribe(topic)
        }
    }
    
    func unsubscribeMqttTopic(topic:String)
    {
        if topic != ""
        {
            myMqtt.unsubscribe(topic)
        }
    }
    
    func publishMqttTopic(topic:String,message:String,qos:UInt8)
    {
        if topic != "" && message != ""
        {
            myMqtt.publish(topic, withString: message, qos: CocoaMQTTQOS(rawValue: qos)!, retained: false, dup: false)
        }
    }
    
    //MARK: - CocoaMQTTDelegate
    func mqtt(_ mqtt: CocoaMQTT, didPublishComplete id: UInt16)
    {
        DLog(message: "didPublishComplete")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void)
    {
        DLog(message: "didReceive")
    }
    
    func mqtt(mqtt: CocoaMQTT, didConnect host: String, port: Int)
    {
        DLog(message: "didConnect\(host):\(port)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck)
    {
        DLog(message: ack.hashValue)
        
        if ack.hashValue == 0
        {
            myMqttServer.shared.subscribeMqttTopic(topic: CHAT_CHANNEL)
            myMqttServer.shared.subscribeMqttTopic(topic: LOGIN_CHANNEL)
        }
        
        if (self.delegate != nil)
        {
            self.delegate?.mqttConnectState(connectState: ack.hashValue)
        }
        else
        {
            DLog(message: "didConnectAck delegate fail")
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16)
    {
        if (self.delegate != nil)
        {
            self.delegate?.mqttMessageArrive(topic: message.topic, withMessage: message.string!)
        }
        else
        {
            DLog(message: "receive message delegate fail")
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16)
    {
        //DLog(message: "didPublishAck with id : \(id)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16 )
    {
        /// message.payload = ascii code char
        DLog(message: "Publish (topic: (\(message.topic))) = \(message.string)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String)
    {
        if (self.delegate != nil)
        {
            self.delegate?.didSubscribeTopic(topic: topic)
        }
        else
        {
            DLog(message: "subscribe delegate fail")
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String)
    {
        if (self.delegate != nil)
        {
            self.delegate?.didUnsubscribeTopic(topic: topic)
        }
        else
        {
            DLog(message: "unsubscribe delegate fail")
        }
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT)
    {
        //DLog(message: "didPing")
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT)
    {
        //DLog(message: "didReceivePong")
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?)
    {
        DLog(message: "mqttDidDisconnect")
    }
    
    
}

