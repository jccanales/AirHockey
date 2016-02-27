//
//  SpaceshipServiceManager.swift
//  DemoGame
//
//  Created by Jean Carlo Canales Martinez on 1/30/16.
//  Copyright © 2016 Jean Carlo Canales Martinez. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import SpriteKit

protocol MPCGameDelegate{
    
    func loadDisk(data : DiskData)
    
    func addPoint()
}

protocol MPCSearchPlayerDelegate{
    
    func foundPeer(peerID : MCPeerID)
    
    func lostPeer(peerID : MCPeerID)
    
    func connectedWithPeer(peerID: MCPeerID)
    
    func invitationWasReceived(fromPeer: String)
    
    func assignPlayer(player : String, pointType : String)
    
    func setBoardType(boardType : String)
}

class MPCManager: NSObject{
    
    let serviceType = "demopeer-game"
    var myPeerId = MCPeerID(displayName: UIDevice.currentDevice().name)
    var serviceBrowser : MCNearbyServiceBrowser
    var serviceAdvertiser : MCNearbyServiceAdvertiser
    var gameDelegate : MPCGameDelegate?
    var searchPlayerDelegate : MPCSearchPlayerDelegate?
    var myNumber : Int32
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override init(){
        
        let time = UInt32(NSDate().timeIntervalSinceReferenceDate)
        srand(time)
        
        myNumber = rand()
        
        var discoveryInfo = [String:String]()
        
        discoveryInfo["number"] = String(myNumber)
        
        let boardVariation = rand() % 3 + 1
        
        let boardType = "var\(boardVariation)"
        
        self.appDelegate.boardType = boardType
        
        discoveryInfo["boardType"] = boardType
        
        
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: discoveryInfo, serviceType: serviceType)
        
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)

        
        super.init()
        
        self.serviceAdvertiser.delegate = self
        
        self.serviceBrowser.delegate = self

    }
    
    func resetMPCObjects() {
        
        self.serviceBrowser.stopBrowsingForPeers()
        self.serviceAdvertiser.stopAdvertisingPeer()
        
        myNumber = rand()
        
        var discoveryInfo = [String:String]()
        
        discoveryInfo["number"] = String(myNumber)
        
        let boardVariation = rand() % 3 + 1
        
        let boardType = "var\(boardVariation)"
        
        self.appDelegate.boardType = boardType
        
        discoveryInfo["boardType"] = boardType
        
        
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: discoveryInfo, serviceType: serviceType)
        
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)
        
        self.serviceAdvertiser.delegate = self
        self.serviceBrowser.delegate = self
        
        self.serviceBrowser.startBrowsingForPeers()
        self.serviceAdvertiser.startAdvertisingPeer()
        
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    lazy var session: MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.Required)
        session.delegate = self
        return session
    }()
    
    func sendDiskData(data: NSData){
        do{
            try self.session.sendData(data, toPeers: self.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            
        }catch{
            NSLog("Error ocurred")
        }
    }
    
    func goalScored() {
        do {
            
            let message = Message(message: "goal")
            
            let data = NSKeyedArchiver.archivedDataWithRootObject(message)
            
            try self.session.sendData(data, toPeers: self.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
        } catch {
            NSLog("Error ocurred")
        }
    }
    
}

extension MPCManager: MCNearbyServiceAdvertiserDelegate{
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: ((Bool, MCSession) -> Void)) {
        
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        self.searchPlayerDelegate?.assignPlayer("player2", pointType: "punto_azul")
        invitationHandler(true, self.session)
    }
}

extension MPCManager: MCNearbyServiceBrowserDelegate{
    
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        
        let string = info!["number"]
        
        let number = Int32(string!)
        
        if ( number > myNumber) {
            self.searchPlayerDelegate?.assignPlayer("player1", pointType: "punto_rojo")
            browser.invitePeer(peerID, toSession: self.session, withContext: nil, timeout: 10)
        } else {
            self.appDelegate.boardType = info!["boardType"]!
        }
        
        //NSLog("%@", "invitePeer: \(peerID)")
        //browser.invitePeer(peerID, toSession: self.session, withContext: nil, timeout: 10)
    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
    }
}

extension MPCManager: MCSessionDelegate{
    
    func session(session: MCSession, didReceiveData data : NSData, fromPeer peerID: MCPeerID){
        dispatch_async(dispatch_get_main_queue()){
            
            
            let msg = NSKeyedUnarchiver.unarchiveObjectWithData(data)
            
            print("DiskData? : \(msg?.isKindOfClass(DiskData))")
            print("Message? : \(msg?.isKindOfClass(Message))")
                
            if (msg!.isKindOfClass(DiskData)) {
                self.gameDelegate?.loadDisk(msg as! DiskData)
            } else {
                
                if (msg!.isKindOfClass(Message)) {
                    let messageType = (msg as! Message).message
                    
                    if(messageType == "goal") {
                        self.gameDelegate?.addPoint()
                    }
                    
                }
                
            }
        
        }
    }
    
    func session(session: MCSession,
        didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID, withProgress progress: NSProgress)  {
            // Called when a peer starts sending a file to us
    }
    
    func session(session: MCSession,
        didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        atURL localURL: NSURL, withError error: NSError?)  {
            // Called when a file has finished transferring from another peer
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream,
        withName streamName: String, fromPeer peerID: MCPeerID)  {
            // Called when a peer establishes a stream with us
    }
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        switch state {
        case MCSessionState.Connected:
            print("Connected: \(peerID.displayName)")
            //self.delegate!.addFirstShip()
            
            self.searchPlayerDelegate?.connectedWithPeer(peerID)
            
        case MCSessionState.Connecting:
            print("Connecting: \(peerID.displayName)")
            
        case MCSessionState.NotConnected:
            print("Not Connected: \(peerID.displayName)")
            
            self.resetMPCObjects()
        }
    }
    
}