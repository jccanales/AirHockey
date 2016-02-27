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
}

protocol MPCSearchPlayerDelegate{
    
    func foundPeer(peerID : MCPeerID)
    
    func lostPeer(peerID : MCPeerID)
    
    func connectedWithPeer(peerID: MCPeerID)
    
    func invitationWasReceived(fromPeer: String)
    
    func assignPlayer(player : String)
}

class MPCManager: NSObject{
    
    let serviceType = "demopeer-game"
    var myPeerId = MCPeerID(displayName: UIDevice.currentDevice().name)
    let serviceBrowser : MCNearbyServiceBrowser
    let serviceAdvertiser : MCNearbyServiceAdvertiser
    var gameDelegate : MPCGameDelegate?
    var searchPlayerDelegate : MPCSearchPlayerDelegate?
    
    override init(){
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)
        
        super.init()
        
        self.serviceAdvertiser.delegate = self
        
        self.serviceBrowser.delegate = self

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
    
}

extension MPCManager: MCNearbyServiceAdvertiserDelegate{
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: ((Bool, MCSession) -> Void)) {
        
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        self.searchPlayerDelegate?.assignPlayer("player2")
        invitationHandler(true, self.session)
    }
}

extension MPCManager: MCNearbyServiceBrowserDelegate{
    
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        searchPlayerDelegate?.foundPeer(peerID)
        self.searchPlayerDelegate?.assignPlayer("player1")
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
            
            let msg = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! DiskData
            
            self.gameDelegate?.loadDisk(msg)
        
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
        }
    }
    
}