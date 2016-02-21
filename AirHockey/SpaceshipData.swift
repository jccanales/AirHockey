//
//  SpaceshipData.swift
//  DemoGame
//
//  Created by Jean Carlo Canales Martinez on 1/30/16.
//  Copyright © 2016 Jean Carlo Canales Martinez. All rights reserved.
//

import Foundation
import SpriteKit

class SpaceshipData: NSObject, NSCoding{
    
    var positionX: CGFloat!
    var positionY: CGFloat!
    var dx: CGFloat!
    var dy: CGFloat!
    
    required convenience init(coder decoder: NSCoder) {
        self.init()
        self.positionX = decoder.decodeObjectForKey("positionX") as! CGFloat
        self.positionY = decoder.decodeObjectForKey("positionY") as! CGFloat
        self.dx = decoder.decodeObjectForKey("dx") as! CGFloat
        self.dy = decoder.decodeObjectForKey("dy") as! CGFloat
    }
    convenience init(positionX: CGFloat, positionY: CGFloat, dx: CGFloat, dy: CGFloat) {
        self.init()
        self.positionX = positionX
        self.positionY = positionY
        self.dx = dx
        self.dy = dy
    }
    func encodeWithCoder(coder: NSCoder) {
        if let positionX = positionX {
            coder.encodeObject(positionX, forKey: "positionX")
        }
        if let positionY = positionY {
            coder.encodeObject(positionY, forKey: "positionY")
        }
        if let dx = dx {
            coder.encodeObject(dx, forKey: "dx")
        }
        if let dy = dy {
            coder.encodeObject(dy, forKey: "dy")
        }
        
    }
    
}