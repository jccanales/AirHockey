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
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "AirHockey Demo"
        myLabel.fontSize = 45
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)*1.5)
        
        let searchPlayersLabel = SKLabelNode(fontNamed: "Arial")
        searchPlayersLabel.name = "searchPlayer"
        searchPlayersLabel.text = "Search Players"
        searchPlayersLabel.fontSize = 30
        searchPlayersLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        
        self.addChild(myLabel)
        self.addChild(searchPlayersLabel)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let sprite = self.nodeAtPoint(location)
            
            if(sprite.name == "searchPlayer"){
                
                let transition = SKTransition.revealWithDirection(.Down, duration: 1.0)
                
                let nextScene = SearchPlayerScene(size: scene!.size)
                nextScene.scaleMode = .AspectFill
                
                scene?.view?.presentScene(nextScene, transition: transition)
            }else{
                print(sprite.name)
            }
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
