//
//  AppDelegate.swift
//  Nyoom
//
//  Created by Anthony Li on 11/13/20.
//

import Cocoa
import EventKit

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let status = EKEventStore.authorizationStatus(for: .event)
        DataManager.shared.setupListeners()
        if status != .denied {
            DataManager.shared.store.requestAccess(to: .event, completion: { _,_  in
                DispatchQueue.main.async {
                    DataManager.shared.load()
                    DataManager.shared.setupListeners()
                }
            })
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }


}

