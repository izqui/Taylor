//
//  MainViewController.swift
//  Taylor
//
//  Created by Alejandro on 19/09/15.
//  Copyright © 2015 Jorge Izquierdo. All rights reserved.
//

import Foundation
import AppKit

class MainViewController: NSViewController {
    @IBOutlet var statusLabel: NSTextField!
    
    override func viewDidLoad() {
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "checkStatus", userInfo: nil, repeats: true)
    }
    
    func checkStatus () {
        if let port = Application.sharedInstance.server.port {
            self.statusLabel.stringValue = "Server up and running on port: \(port)"
        } else {
            self.statusLabel.stringValue = "Tango down"
        }
    }
    
    @IBAction func open(sender: AnyObject?) {
        let url = NSURL(string: "http://127.0.0.1:\(Application.sharedInstance.server.port!)")
        NSWorkspace.sharedWorkspace().openURL(url!)
    }

}