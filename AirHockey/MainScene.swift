//
//  GameScene.swift
//  MultipeerHockey
//
//  Created by Jean Carlo Canales Martinez on 2/20/16.
//  Copyright (c) 2016 Jean Carlo Canales Martinez. All rights reserved.
//

import SpriteKit

class MainScene: SKScene {
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        let bg = SKSpriteNode(imageNamed: "main_background")
        bg.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        bg.size.height = self.frame.height
        bg.size.width = self.frame.width
        bg.zPosition = 0
        
        self.addChild(bg)
        
        let shapeAbout = SKShapeNode(circleOfRadius: 90)
        shapeAbout.name = "About"
        shapeAbout.position = CGPoint(x: CGRectGetMidX(self.frame)*1.45, y: CGRectGetMidY(self.frame)*0.62)
        shapeAbout.zPosition = 1
        
        self.addChild(shapeAbout)
        
        
        let shapeRules = SKShapeNode(circleOfRadius: 90)
        shapeRules.name = "Rules"
        shapeRules.position = CGPoint(x: CGRectGetMidX(self.frame)*0.55, y: CGRectGetMidY(self.frame)*0.62)
        shapeRules.zPosition = 1
        
        self.addChild(shapeRules)
        
        
        let shapePlay = SKShapeNode(circleOfRadius: 90)
        shapePlay.name = "Play"
        shapePlay.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)*0.62)
        shapePlay.zPosition = 1
        
        self.addChild(shapePlay)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let sprite = self.nodeAtPoint(location)
            
            if( sprite.name != nil) {
                switch(sprite.name!) {
                    case "Play":
                        let transition = SKTransition.revealWithDirection(.Down, duration: 1.0)
                    
                        let nextScene = SearchPlayerScene(size: scene!.size)
                        nextScene.scaleMode = .AspectFill
                    
                        scene?.view?.presentScene(nextScene, transition: transition)
                
                    case "Rules":
                        let transition = SKTransition.revealWithDirection(.Right, duration: 1.0)
                        let nextScene = RulesScene(size: scene!.size)
                        nextScene.scaleMode = .AspectFill
                    
                        scene?.view?.presentScene(nextScene, transition: transition)
                        break
                    
                    
                    case "About":
                        let transition = SKTransition.revealWithDirection(.Left, duration: 1.0)
                        let nextScene = AboutScene(size: scene!.size)
                        nextScene.scaleMode = .AspectFill
                    
                        scene?.view?.presentScene(nextScene, transition: transition)
                        break
                
                default:
                    break
                }
            }
            
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
