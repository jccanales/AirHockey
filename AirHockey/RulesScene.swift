//
//  RulesScene.swift
//  AirHockey
//
//  Created by Jean Carlo Canales Martinez on 2/27/16.
//  Copyright © 2016 Jean Carlo Canales Martinez. All rights reserved.
//

import SpriteKit

class RulesScene: SKScene {
    
    override func didMoveToView(view: SKView) {
        let bg = SKSpriteNode(imageNamed: "rules_background")
        bg.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        bg.size.height = self.frame.height
        bg.size.width = self.frame.width
        bg.zPosition = 0
        
        self.addChild(bg)
        
        let back = SKShapeNode(circleOfRadius: 90)
        
        back.name = "Back"
        back.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)*1.3)
        back.zPosition = 1
        
        self.addChild(back)

    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.locationInNode(self)
            
            let sprite = self.nodeAtPoint(location)
            
            if(sprite.name == "Back") {
                let transition = SKTransition.revealWithDirection(.Left, duration: 1.0)
                let nextScene = MainScene(size: scene!.size)
                nextScene.scaleMode = .AspectFill
                
                scene?.view?.presentScene(nextScene, transition: transition)
            }
            
        }
    }

}