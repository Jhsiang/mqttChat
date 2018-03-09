//
//  Definition.swift
//  mqttChat
//
//  Created by Jim Chuang on 2017/12/25.
//  Copyright © 2017年 nhr. All rights reserved.
//

import Foundation
import UIKit

func DLog<T> (message: T, fileName: String = #file, funcName: String = #function, lineNum: Int = #line) {
    
    #if DEBUG
        
        let file = (fileName as NSString).lastPathComponent
        
        print("-\(file) \(funcName)-[\(lineNum)]: \(message)")
        
    #endif
    
}

extension String {
    /*
     let helloWorld = "Hello, World!"
     subStringTo8: Hello, W
     subStringFrom5: , World!
     */
    func mySubString(to index: Int) -> String {
        return String(self[..<self.index(self.startIndex, offsetBy: index)])
    }
    
    func mySubString(from index: Int) -> String {
        return String(self[self.index(self.startIndex, offsetBy: index)...])
    }
}

/*
 let myString1 = "556"
 let myInt1 = Int(myString1)
 
 As with other data types (Float and Double) you can also convert by using NSString:
 
 let myString2 = "556"
 let myInt2 = (myString2 as NSString).integerValue
 */

