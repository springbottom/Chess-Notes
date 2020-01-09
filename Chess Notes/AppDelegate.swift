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
    
    //https://cocoacasts.com/setting-up-the-core-data-stack-with-nspersistentcontainer
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { description, error in
            if let error = error {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                print("ruh roh")
                //fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    
    var backend = Backend()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {

        let context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        backend.moc = context
        
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
        //this is never called...
        //self.backend.save()
        // Insert code here to tear down your application
    }
    
    //TOOLBAR STUFF
    //https://christiantietze.de/posts/2016/06/segmented-nstoolbaritem/
    
    @objc
    let toolbarItems: [String:NSImage] = [
        "Import Game" : NSImage(named: NSImage.addTemplateName)!,
        "Share Game"  : NSImage(named: NSImage.shareTemplateName)!,
        "Back"        : NSImage(named: NSImage.goBackTemplateName)!,
        "Forward"     : NSImage(named:NSImage.goForwardTemplateName)!,
        "Reset"       : NSImage(named:NSImage.refreshTemplateName)!,
        "Save"        : NSImage(named:NSImage.bookmarksTemplateName)!
    ]
    var toolbarTabsIdentifiers: [NSToolbarItem.Identifier] {
        return ["Import Game","Share Game","Save","Back", "Forward", "Reset"]
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
    
    @objc
    func button_save(){backend.save()}
    
    
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
        if itemIdentifier.rawValue == "Save"{button.action = #selector(button_save)}
        
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
        //print("toolbarWillAddItem", (notification.userInfo?["item"] as? NSToolbarItem)?.itemIdentifier ?? "")
    }

    func toolbarDidRemoveItem(_ notification: Notification) {
        print("toolbarDidRemoveItem", (notification.userInfo?["item"] as? NSToolbarItem)?.itemIdentifier ?? "")
    }

}



class EditorWindow: NSWindow, NSWindowDelegate {
    
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

    override func mouseDown(with event: NSEvent) {
        self.makeFirstResponder(self)
        print("clicked, in EditorWindow")
    }
    
    init(backend: Backend){
        self.backend = backend
        super.init(contentRect: NSRect(x: 0, y: 0, width: 480, height: 400),
                   styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                   backing: .buffered, defer: false
                   )
    }
}
