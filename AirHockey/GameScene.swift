//
//  GameScene.swift
//  DemoGame
//
//  Created by Jean Carlo Canales Martinez on 1/29/16.
//  Copyright (c) 2016 Jean Carlo Canales Martinez. All rights reserved.
//

import SpriteKit
import MultipeerConnectivity
import AVFoundation

protocol GameSceneDelegate{
    func changeDevice(data: NSData)
}

class GameScene: SKScene {
    
    enum ColliderType: UInt32 {
        case DiskCategory = 0
        case WallCategory = 1
        case PaddleCategory = 2
        case OutsideScreenCategory = 3
        case GoalCategory = 4
    }

    var shouldSendDisk = false
    var padTouched = false
    var playerNumber = 0
    var disk : SKSpriteNode?
    var points = [SKSpriteNode?](count: 7, repeatedValue: nil)
    var currentPoints = 0
    var player: AVAudioPlayer = AVAudioPlayer()
    var pad : SKSpriteNode!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func didMoveToView(view: SKView) {
        
        /* Setup your scene here */
        
        self.appDelegate.mpcManager.gameDelegate = self
        
        //assign players
        
        setupGame()
        addPad()
        
        //print("Connected peers: \(appDelegate.mpcManager.session.connectedPeers)")
        //let vector = CGVector(dx: 100, dy: 100)
        //sprite.physicsBody?.applyImpulse(vector)
    }
    
    func setupGame() {
        
        let bg : SKSpriteNode
        
        if( self.appDelegate.player == "player1") {
            bg = SKSpriteNode(imageNamed: "mesa1")
        } else {
            bg = SKSpriteNode(imageNamed: "mesa2")
        }

        
        bg.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        bg.size.height = self.frame.height
        bg.size.width = self.frame.width
        bg.zPosition = 0
        
        self.addChild(bg)
        
        setupBorders()
        
        setupGoal()
        setupPoints()
        
    }
    
    func setupPoints() {
        
        for index in 0...6 {
            
            let node = SKSpriteNode(imageNamed: "punto_blanco")
            
            node.position.x = self.size.width / 2 - 150 + CGFloat(index * 50)
            node.position.y = self.size.height / 2 - 100
            node.zPosition = 1
            node.setScale(0.1)
            
            points[index] = node
            
            self.addChild(node)
        }
        
        let audioPath = NSBundle.mainBundle().pathForResource("point", ofType: "wav")!
        
        do {
            
            try player = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: audioPath))
            
        } catch {
            
            // Process error here
            
        }
        
    }
    
    func setupGoal() {
        
        let goal = SKNode()
        
        goal.position = CGPoint(x: CGRectGetMidX(self.frame) - 185, y: 30)
        
        self.addChild(goal)
        
        let rect = CGRectMake(0, 0, 370, 30)
        goal.physicsBody = SKPhysicsBody(edgeLoopFromRect: rect)
        goal.physicsBody?.categoryBitMask = ColliderType.GoalCategory.rawValue
        
    }
    
    func setupBorders() {
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        let screenSize = CGRectMake(0, 0, self.frame.width, self.frame.height + 500)
        
        print("frame = \(self.frame.width) - \(self.frame.height)")
        print("size = \(self.frame.size)")
        
        //2048 1536
        
        
        let borderBody = SKPhysicsBody(edgeLoopFromRect: screenSize)
        borderBody.friction = 0
        borderBody.categoryBitMask = ColliderType.WallCategory.rawValue
        self.physicsBody = borderBody
        
        let topEdge = SKNode()
        topEdge.position.x = 0
        topEdge.position.y = 0
        
        self.addChild(topEdge)
        
        topEdge.physicsBody = SKPhysicsBody(edgeFromPoint: CGPointMake(0, self.frame.height + 100), toPoint: CGPointMake(self.frame.width, self.frame.height + 100))
        
        topEdge.physicsBody?.categoryBitMask = ColliderType.OutsideScreenCategory.rawValue
        
    }
    
    func addPad() {
        
        if( self.appDelegate.player == "player1") {
            pad = SKSpriteNode(imageNamed: "pad1")
            addDisk()
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
    
    func printGameState(section: String) {
        
        print("\(section)\n")
        print("\(disk)\n")
        print("Should Send Disk?: \(shouldSendDisk)\n")
        print("Points: \(points)\n")
        print("------\n")
        
    }
    
    func resetPad() {
        
        pad.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame) - 100)
        
    }
    
    func addDisk() {
        
        disk?.removeFromParent()
        disk = nil
        disk = SKSpriteNode(imageNamed: "disk1")
        
        disk?.name = "disk"
        
        setupDisk(self.frame.width / 2, positionY: self.frame.height / 2)
        
        self.addChild(disk!)
        
        configureDiskPhysics()
        
        
        //disk.physicsBody?.applyForce(CGVectorMake(300, 300))
    }
    
    func setupDisk(positionX : CGFloat, positionY : CGFloat) {
        
        disk?.position = CGPoint(x: positionX, y: positionY)
        disk?.size.width = 100
        disk?.size.height = 75
        disk?.zPosition = 2

    }
    
    func configureDiskPhysics() {
        
        disk?.physicsBody = SKPhysicsBody(circleOfRadius: 25)
        disk?.physicsBody?.dynamic = true
        disk?.physicsBody?.restitution = 1.0
        disk?.physicsBody?.friction = 0.0
        disk?.physicsBody?.linearDamping = 0.0
        disk?.physicsBody?.allowsRotation = false
        disk?.physicsBody?.affectedByGravity = false
        disk?.physicsBody?.categoryBitMask = ColliderType.DiskCategory.rawValue
        disk?.physicsBody?.contactTestBitMask = ColliderType.PaddleCategory.rawValue | ColliderType.OutsideScreenCategory.rawValue | ColliderType.GoalCategory.rawValue

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
        
        if(body?.node?.name == "endGame"){
            self.appDelegate.mpcManager.session.disconnect()
            let transition = SKTransition.revealWithDirection(.Up, duration: 1.0)
            let nextScene = MainScene(size: scene!.size)
            nextScene.scaleMode = .AspectFill
            
            scene?.view?.presentScene(nextScene, transition: transition)

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
    
    func loadDisk(data: DiskData) {
        
        disk?.removeFromParent()
        disk = nil
        disk = SKSpriteNode(imageNamed: "disk1")
        disk?.name = "disk"
        
        setupDisk(self.frame.width / 2, positionY: self.frame.height / 2)
        
        self.addChild(disk!)
        
        configureDiskPhysics()

        disk?.physicsBody?.velocity.dx = -data.dx
        disk?.physicsBody?.velocity.dy = data.dy
        disk?.position.x = self.frame.width - data.positionX
        disk?.position.y = self.frame.height + (disk?.size.height)!
        //data.positionY
        self.shouldSendDisk = false
        
    }
    
    func addPoint() {
        
        if ( currentPoints < 6) {
            points[currentPoints++]?.texture = SKTexture(imageNamed: self.appDelegate.pointType)
            player.play()
            resetPad()
            addDisk()
        } else {
            
            //show winning message
            let label = SKSpriteNode(imageNamed: "YouWin")
            label.name = "endGame"
            label.position = CGPointMake(self.frame.width/2, self.frame.height/2)
            label.size.height = label.size.height * 0.8
            label.size.width = label.size.width * 0.8
            
            label.zPosition = 3
            
            self.addChild(label)
            
            self.appDelegate.mpcManager.gameFinished()
            
        }
    }
    
    func hideDisk() {
        disk?.removeFromParent()
        disk = nil
        self.shouldSendDisk = false
    }
    
    func endGame () {
        
        //show losing message
        let label = SKSpriteNode(imageNamed: "YouLose")
        label.name = "endGame"
        label.position = CGPointMake(self.frame.width/2, self.frame.height/2)
        label.size.height = label.size.height * 0.8
        label.size.width = label.size.width * 0.8
        
        label.zPosition = 3
        
        self.addChild(label)

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
        
        //print(secondBody.categoryBitMask)
        
        switch (secondBody.categoryBitMask) {
        
        case ColliderType.OutsideScreenCategory.rawValue:
            
            if( firstBody.velocity.dy < 0 && self.shouldSendDisk) {
            
                let diskData = DiskData(positionX: (firstBody.node?.position.x)!, positionY: (firstBody.node?.position.y)!, dx: firstBody.velocity.dx, dy: firstBody.velocity.dy)
            
                let data = NSKeyedArchiver.archivedDataWithRootObject(diskData)
                
                self.hideDisk()
            
                self.appDelegate.mpcManager.sendDiskData(data)
            }
            
            break
            
        case ColliderType.PaddleCategory.rawValue:
            let vector = CGVectorMake(-(secondBody.node?.position.x)! + (firstBody.node?.position.x)!, -(secondBody.node?.position.y)! + (firstBody.node?.position.y)!)
            
            firstBody.velocity = CGVectorMake(0,0);
            firstBody.applyImpulse(vector)
            shouldSendDisk = true
            break
            
        case ColliderType.GoalCategory.rawValue:
            hideDisk()
            self.appDelegate.mpcManager.goalScored()
            break
        
        case ColliderType.WallCategory.rawValue:
            if(firstBody.node?.position.y < 100) {
                self.shouldSendDisk = true
            }
            break
        default:
            break
        }
    
    }
}

