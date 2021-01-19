//
//  ConnectionManager.swift
//  tcs_one_app
//
//  Created by ibs on 28/10/2020.
//  Copyright © 2020 Personal. All rights reserved.
//
import Reachability
class ConnectionManager {

static let sharedInstance = ConnectionManager()
private var reachability : Reachability!

func observeReachability(){
    self.reachability = try? Reachability()
    NotificationCenter.default.addObserver(self, selector:#selector(self.reachabilityChanged), name: NSNotification.Name.reachabilityChanged, object: nil)
    do {
        try self.reachability.startNotifier()
    }
    catch(let error) {
        print("Error occured while starting reachability notifications : \(error.localizedDescription)")
    }
}

@objc func reachabilityChanged(note: Notification) {
    let reachability = note.object as! Reachability
    switch reachability.connection {
    case .cellular, .wifi:
        print("Network available.")
        NotificationCenter.default.post(Notification.init(name: .networkRefreshed))
        break
//    case .wifi:
//        print("Network available via WiFi.")
//        break
    case .none:
        print("Network is not available.")
        break
    case .unavailable:
        print("Network is  unavailable.")
        break
    }
  }
}
