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
class AppDelegate: NSObject, NSApplicationDelegate, NSToolbarDelegate {

    var window: NSWindow!
    var toolbar: NSToolbar!
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("not sure - perhaps this is an error?")
            }
        }
        return container
    }()
    
    var backend = Backend()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        let context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let contentView = ContentView(backend:backend).environment(\.managedObjectContext,context)
        window = EditorWindow(backend:backend)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        
        
        toolbar = NSToolbar(identifier: NSToolbar.Identifier("TheToolbarIdentifier"))
        toolbar.allowsUserCustomization = true
        toolbar.delegate = self
        self.window?.toolbar = toolbar
        
    }

    func popup(){
        
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


    
    //TOOLBAR STUFF
    //https://christiantietze.de/posts/2016/06/segmented-nstoolbaritem/
    
    @objc
    let toolbarItems: [String:NSImage] = [
        "Import Game" : NSImage(named: NSImage.addTemplateName)!,//AppDelegate.test_f),
        "Share Game"  : NSImage(named: NSImage.shareTemplateName)!,//AppDelegate.test_f),
        "Back"        : NSImage(named: NSImage.goBackTemplateName)!,//AppDelegate.test_f),
        "Forward"     : NSImage(named:NSImage.goForwardTemplateName)!,//AppDelegate.test_f),
        "Reset"       : NSImage(named:NSImage.refreshTemplateName)!//AppDelegate.button_reset)
    ]

    var toolbarTabsIdentifiers: [NSToolbarItem.Identifier] {
        return ["Import Game","Share Game","Back", "Forward", "Reset"]
                .map{ NSToolbarItem.Identifier(rawValue: $0) }
    }

    
    @objc
    func button_reset(){backend.reset()}
    @objc
    func button_back(){backend.backward()}
    @objc
    func button_forward(){backend.forward()}
    
    @objc
    func button_import(){
        
        let iwindow = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 480, height: 400),
                               styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                               backing: .buffered, defer: false)
        let context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let importWindow = ImportWindow(backend:backend,window:iwindow).environment(\.managedObjectContext,context)
        iwindow.center()
        iwindow.setFrameAutosaveName("Import Window")
        iwindow.contentView = NSHostingView(rootView: importWindow)
        iwindow.makeKeyAndOrderFront(nil)
    }
    
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {

        let toolbarItem: NSToolbarItem

        toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
        toolbarItem.label = itemIdentifier.rawValue//infoDictionary["title"]!

        let iconImage = toolbarItems[itemIdentifier.rawValue]!
        let button = NSButton(frame: NSRect(x: 0, y: 0, width: 40, height: 40))
        button.title = ""
        button.image = iconImage//NSImage(named: NSImage.addTemplateName)
        button.bezelStyle = .texturedRounded
        if itemIdentifier.rawValue == "Reset"{button.action = #selector(button_reset)}
        if itemIdentifier.rawValue == "Back"{button.action = #selector(button_back)}
        if itemIdentifier.rawValue == "Forward"{button.action = #selector(button_forward)}
        if itemIdentifier.rawValue == "Import Game"{button.action = #selector(button_import)}
        
        toolbarItem.view = button

        return toolbarItem
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return self.toolbarTabsIdentifiers;
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return self.toolbarDefaultItemIdentifiers(toolbar)
    }

    func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier]{
        return self.toolbarDefaultItemIdentifiers(toolbar)
    }

    func toolbarWillAddItem(_ notification: Notification) {
        print("toolbarWillAddItem", (notification.userInfo?["item"] as? NSToolbarItem)?.itemIdentifier ?? "")
    }

    func toolbarDidRemoveItem(_ notification: Notification) {
        print("toolbarDidRemoveItem", (notification.userInfo?["item"] as? NSToolbarItem)?.itemIdentifier ?? "")
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
        super.init(contentRect: NSRect(x: 0, y: 0, width: 480, height: 400),
                   styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                   backing: .buffered, defer: false
                   )
    }
}
