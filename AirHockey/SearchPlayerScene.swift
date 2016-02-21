//
//  SearchPlayerScene.swift
//  MultipeerHockey
//
//  Created by Jean Carlo Canales Martinez on 2/20/16.
//  Copyright © 2016 Jean Carlo Canales Martinez. All rights reserved.
//

import SpriteKit
import MultipeerConnectivity

class SearchPlayerScene: SKScene {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var lastPeer: MCPeerID?
    
    override func didMoveToView(view: SKView) {
        
        
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "SearchPlayerScene"
        myLabel.fontSize = 20
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)*1.9)
        
        appDelegate.mpcManager.searchPlayerDelegate = self
        
        appDelegate.mpcManager.serviceBrowser.startBrowsingForPeers()
        appDelegate.mpcManager.serviceAdvertiser.startAdvertisingPeer()
        
        self.addChild(myLabel)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.locationInNode(self)
            
            let sprite = self.nodeAtPoint(location)
            
            if(sprite.name == "player"){
                self.appDelegate.mpcManager.serviceBrowser.invitePeer(lastPeer!, toSession: appDelegate.mpcManager.session, withContext: nil, timeout: 20)
            }
            
        }
    }
    
    
}

extension SearchPlayerScene: MPCSearchPlayerDelegate {
    
    func foundPeer(peerID : MCPeerID) {
        print("found peer (\(peerID))")
        let peer = SKLabelNode(fontNamed: "Chalkduster")
        peer.text = peerID.displayName
        peer.name = "player"
        peer.fontSize = 20
        peer.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        
        lastPeer = peerID
        
        self.addChild(peer)
        
    }
    
    func lostPeer(peerID : MCPeerID) {
        print("lost peer \(peerID)")
    }
    
    func connectedWithPeer(peerID: MCPeerID) {
        
        self.appDelegate.mpcManager.serviceBrowser.stopBrowsingForPeers()
        self.appDelegate.mpcManager.serviceAdvertiser.stopAdvertisingPeer()
        
        let transition = SKTransition.revealWithDirection(.Down, duration: 1.0)
        
        let nextScene = GameScene(size: scene!.size)
        nextScene.scaleMode = .AspectFill
        
        scene?.view?.presentScene(nextScene, transition: transition)
    }
    
    func invitationWasReceived(fromPeer: String) {
        
    }
    
}