//
//  Message.swift
//  AirHockey
//
//  Created by Jean Carlo Canales Martinez on 2/27/16.
//  Copyright © 2016 Jean Carlo Canales Martinez. All rights reserved.
//

import Foundation


class Message: NSObject, NSCoding{
    
    var message: String!
    
    required convenience init(coder decoder: NSCoder) {
        self.init()
        self.message = decoder.decodeObjectForKey("message") as! String
    }
    
    convenience init(message : String) {
        self.init()
        self.message = message
    }
    
    func encodeWithCoder(coder: NSCoder) {
        if let message = self.message {
            coder.encodeObject(message, forKey: "message")
        }
        
    }

}

