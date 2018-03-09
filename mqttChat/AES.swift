//
//  AES.swift
//  mqttChat
//
//  Created by Jim Chuang on 2017/12/22.
//  Copyright © 2017年 nhr. All rights reserved.
//

import Foundation
import CryptoSwift

func Endcode_AES_ECB(strToEncode:String)->String {
    
    let data = strToEncode.data(using: String.Encoding.utf8)
    
    var encrypted: [UInt8] = []
    
    do {
        encrypted = try AES(key: MQTT_CHAT_AES128_KEY.bytes, blockMode: .ECB, padding: .pkcs7).encrypt(data!.bytes)
    } catch {
        DLog(message: "encrypted fail")
    }
    
    let encoded =  Data(encrypted)
    return encoded.base64EncodedString()
}

func Decode_AES_ECB(strToDecode:String)->String {
    
    let data = NSData(base64Encoded: strToDecode, options: NSData.Base64DecodingOptions.init(rawValue: 0))
    
    var encrypted: [UInt8] = []
    let count = data?.length
    
    if count == nil
    {
        return ""
    }
    
    for i in 0..<count! {
        var temp:UInt8 = 0
        data?.getBytes(&temp, range: NSRange(location: i,length:1 ))
        encrypted.append(temp)
    }
    
    var decrypted: [UInt8] = []
    do {
        decrypted = try AES(key: MQTT_CHAT_AES128_KEY.bytes, blockMode:.ECB, padding: .pkcs7).decrypt(encrypted)
    } catch {
        DLog(message: "decrypted fail")
    }
    
    let encoded = Data(decrypted)
    
    if let str = String(bytes: encoded.bytes, encoding: .utf8)
    {
        return str
    }
    else
    {
        return ""
    }
}
