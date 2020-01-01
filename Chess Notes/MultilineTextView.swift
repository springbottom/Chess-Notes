//
//  MultilineTextView.swift
//  Joshua Lin
//
//  Created by Joshua Lin on 26/12/19.
//  Copyright © 2019 Joshua Lin. All rights reserved.
//

import SwiftUI
import Combine


final class UserData: ObservableObject  {
    let didChange = PassthroughSubject<Void, Never>()

    var text = "" {didSet {didChange.send()}}

    init(text: String) {
        self.text = text
    }
}

struct MultilineTextView: NSViewRepresentable {
    
    @Binding var text: String

    func makeNSView(context: Context) -> NSTextView {
        
        let view = NSTextView()
        
        view.isEditable = true
        view.maxSize = NSSize(width: 100, height: 100)
        view.isVerticallyResizable = true
        view.drawsBackground = false
    
        return view
    }

    func updateNSView(_ nsView: NSTextView, context: Context) {
        print("updating notes",text,nsView.string)
        text = nsView.string
    }
}
