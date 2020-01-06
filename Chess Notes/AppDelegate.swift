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
    
    //this variable is for... the text containing the notes I think?
    //var userData = UserData(text:"")
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("not sure - perhaps this is an error?")
                // Add your error UI here
            }
        }
        return container
    }()
    
    
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Show the error here
            }
        }
    }
    
    var masterkey = MasterKey()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        let context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let contentView = ContentView(masterkey:masterkey).environment(\.managedObjectContext,context)//,
                                      //userData: UserData(text:"")).environment(\.managedObjectContext,context)
        window = EditorWindow(masterkey:masterkey)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}


class MasterKey: ObservableObject{
    @Published var keycode : Int = 0
    @Published var current_index : Int = 0
    @Published var game_length : Int = 1
    
    func backward(){
        if (self.current_index != 0){
            self.current_index = self.current_index - 1
        }
        else{
            //make a noise
        }
        return
    }
    
    func forward(){
        if (self.current_index != self.game_length - 1){
            self.current_index = self.current_index + 1
        }
        else{
            //make a noise?
        }
        return
    }
    
}

class EditorWindow: NSWindow {
    
    @ObservedObject var masterkey : MasterKey
    
    
    override func keyDown(with event : NSEvent) {
        super.keyDown(with: event)
        self.masterkey.keycode = Int(event.keyCode)
        
        if event.keyCode == 123{
            self.masterkey.backward()
        }
        if event.keyCode == 124{
            self.masterkey.forward()
        }
        
    }

    init(masterkey: MasterKey){
        self.masterkey = masterkey
        super.init(contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
                   styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                   backing: .buffered, defer: false)
        
    }
}
