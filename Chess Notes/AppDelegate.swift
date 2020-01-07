//
//  AppDelegate.swift
//  Joshua Lin
//
//  Created by Joshua Lin on 19/12/19.
//  Copyright © 2019 Joshua Lin. All rights reserved.
//

import Cocoa
import SwiftUI
import Combine
import AppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("not sure - perhaps this is an error?")
            }
        }
        return container
    }()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
    
        var backend = Backend()
        
        let context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let contentView = ContentView(backend:backend).environment(\.managedObjectContext,context)
        window = EditorWindow(backend:backend)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }

    func popup(){
        
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}



class EditorWindow: NSWindow {
    
    @ObservedObject var backend : Backend
    
    
    override func keyDown(with event : NSEvent) {
        super.keyDown(with: event)
        self.backend.keycode = Int(event.keyCode)
        
        if event.keyCode == 123{
            self.backend.backward()
        }
        if event.keyCode == 124{
            self.backend.forward()
        }
        
    }

    init(backend: Backend){
        self.backend = backend
        super.init(contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
                   styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                   backing: .buffered, defer: false)
        
    }
}
