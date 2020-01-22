//
//  SocketStream.swift
//  ScreenShareReplayKitExtension
//
//  Created by Ravi's MacBook Pro on 22/01/20.
//  Copyright © 2020 Ravi's MacBook. All rights reserved.
//

import UIKit
import Starscream

class SocketStream: NSObject {
    
    var webSocket = WebSocket(url: URL(string: "https://screenshare.siteforge.com/")! )

    deinit {
        webSocket.disconnect(forceTimeout: 0)
        webSocket.delegate = nil
    }

    func intiliazeSocket() {
        
        webSocket.delegate = self
        webSocket.onConnect = { }

        webSocket.onDisconnect = { (error: Error?) in
            self.webSocket.delegate = nil
        }

        webSocket.onText = { (text: String) in
        
        }

        webSocket.onData = { (data: Data) in
       
        }
        webSocket.connect()
    }
    
    func sendDataToWebServer(data: String) {
        if !webSocket.isConnected {
            return
        }
        let notificationName = CFNotificationName("com.notification.name" as CFString)
        let notificationCenter = CFNotificationCenterGetDarwinNotifyCenter()
        
        CFNotificationCenterPostNotification(notificationCenter, notificationName, nil, nil, false)
        
        webSocket.write(string: data)
    }

}

extension SocketStream : WebSocketDelegate {
    
    func websocketDidConnect(socket: WebSocketClient) {
        
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
    }
    
}
