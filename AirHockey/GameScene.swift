//
//  GameScene.swift
//  DemoGame
//
//  Created by Jean Carlo Canales Martinez on 1/29/16.
//  Copyright (c) 2016 Jean Carlo Canales Martinez. All rights reserved.
//

import SpriteKit
import MultipeerConnectivity

protocol GameSceneDelegate{
    func changeDevice(data: NSData)
}

class GameScene: SKScene {
    
    enum ColliderType: UInt32 {
        case DiskCategory = 0
        case WallCategory = 1
        case PaddleCategory = 2
    }

    
    var padTouched = false
    var playerNumber = 0
    var selectedNode = SKSpriteNode()
    
    let mpcManager = MPCManager()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func didMoveToView(view: SKView) {
        
        /* Setup your scene here */
        
        setupGame()
        
        addPad("player2")
        addDisk()
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        let screenSize = CGRectMake(0, 0, self.frame.width, self.frame.height)
        let borderBody = SKPhysicsBody(edgeLoopFromRect: screenSize)
        borderBody.friction = 0
        borderBody.categoryBitMask = ColliderType.WallCategory.rawValue
        self.physicsBody = borderBody
        
        //print("Connected peers: \(appDelegate.mpcManager.session.connectedPeers)")
        
        //let vector = CGVector(dx: 100, dy: 100)
        //sprite.physicsBody?.applyImpulse(vector)
        
    }
    
    func setupGame() {
        
        let bg = SKSpriteNode(imageNamed: "mitad1")
        
        bg.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        bg.size.height = self.frame.height
        bg.size.width = self.frame.width
        bg.zPosition = 0
        
        self.addChild(bg)
        
    }
    
    func addPad(player : String) {
        
        let pad : SKSpriteNode
        if( player == "player1") {
            pad = SKSpriteNode(imageNamed: "pad1")
        } else {
            pad = SKSpriteNode(imageNamed: "pad2")
        }
        
        pad.name = "pad"
        pad.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame) - 100)
        pad.size.width = 100
        pad.size.height = 100
        
        pad.zPosition = 2
        
        self.addChild(pad)
        
        pad.physicsBody = SKPhysicsBody(circleOfRadius: 50)
        pad.physicsBody?.dynamic = true
        pad.physicsBody?.restitution = 1.0
        pad.physicsBody?.friction = 0.0
        pad.physicsBody?.linearDamping = 0.0
        pad.physicsBody?.allowsRotation = false
        pad.physicsBody?.affectedByGravity = false
        pad.physicsBody?.categoryBitMask = ColliderType.PaddleCategory.rawValue
        pad.physicsBody?.contactTestBitMask = ColliderType.DiskCategory.rawValue
        
    }
    
    func addDisk() {
        
        let disk = SKSpriteNode(imageNamed: "disk")
        disk.name = "disk"
        disk.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        disk.size.width = 50
        disk.size.height = 50
        
        disk.zPosition = 2
        
        self.addChild(disk)
        
        disk.physicsBody = SKPhysicsBody(circleOfRadius: 25)
        disk.physicsBody?.dynamic = true
        disk.physicsBody?.restitution = 1.0
        disk.physicsBody?.friction = 0.0
        disk.physicsBody?.linearDamping = 0.0
        disk.physicsBody?.allowsRotation = false
        disk.physicsBody?.affectedByGravity = false
        disk.physicsBody?.categoryBitMask = ColliderType.DiskCategory.rawValue
        disk.physicsBody?.contactTestBitMask = ColliderType.PaddleCategory.rawValue
        
        //disk.physicsBody?.applyForce(CGVectorMake(300, 300))
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        let touch = touches.first
        
        let location = touch!.locationInNode(self)
            
        let body = self.physicsWorld.bodyAtPoint(location)
            
        if( body?.node?.name == "pad" ){
            padTouched = true
        } else {
            padTouched = false
        }
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if( padTouched) {
            let touch = touches.first
            let location = touch!.locationInNode(self)
            
            let pad = self.childNodeWithName("pad")
            pad?.position = location
        }
        
    }
    
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
    }
    
}

extension GameScene: MPCGameDelegate{
    
    func assignPlayers() {
        
        let myNumber = rand()
        
        print(myNumber)
        
    }
    
}

extension GameScene: SKPhysicsContactDelegate {
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        var firstBody: SKPhysicsBody = SKPhysicsBody()
        var secondBody: SKPhysicsBody = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        //firstBody es el disco
        
        let vector = CGVectorMake(-(secondBody.node?.position.x)! + (firstBody.node?.position.x)!, -(secondBody.node?.position.y)! + (firstBody.node?.position.y)!)
        
        firstBody.applyImpulse(vector)
        
    }
}

