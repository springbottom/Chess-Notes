//
//  DetailWindowController.swift
//  Chess Notes
//
//  Created by Joshua Lin on 6/1/20.
//  Copyright © 2020 Joshua Lin. All rights reserved.
//

//https://github.com/carson-katri/reddit-swiftui/blob/master/Reddit-macOS/Views/Helpers/DetailWindowController.swift
import Cocoa
import SwiftUI

/// A class to handle opening windows for posts when doubling clicking the entry
class DetailWindowController<RootView : View>: NSWindowController {
    convenience init(rootView: RootView) {
        let hostingController = NSHostingController(rootView: rootView)//.frame())
        let window = NSWindow(contentViewController: hostingController)
        window.setContentSize(NSSize(width: 400, height: 25))
        self.init(window: window)
    }
}
