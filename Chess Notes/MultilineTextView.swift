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
    let didChange = PassthroughSubject<UserData, Never>()

    var text = "" {didSet {didChange.send(self)}}

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
       
        //view.string = self.text
    
        return view
    }

    func updateNSView(_ nsView: NSTextView, context: Context) {
        //print("updating notes",text,nsView.string)
        //text = nsView.string
        nsView.string = text
    }
}

struct TextView: NSViewRepresentable {
    @Binding var text: String

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSTextView {

        let myTextView = NSTextView()
        myTextView.delegate = context.coordinator

        //myTextView.font = UIFont(name: "HelveticaNeue", size: 15)
        //myTextView.isScrollEnabled = true
        myTextView.isEditable = true
        //myTextView.isUserInteractionEnabled = true
        //myTextView.backgroundColor = UIColor(white: 0.0, alpha: 0.05)

        return myTextView
    }

    func updateNSView(_ nsView: NSTextView, context: Context) {
        nsView.string = text
    }

    class Coordinator : NSObject, NSTextViewDelegate {

        var parent: TextView

        init(_ nsTextView: TextView) {
            self.parent = nsTextView
        }

        func textView(_ textView: NSTextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            return true
        }

        func textViewDidChange(_ textView: NSTextView) {
            print("text now: \(String(describing: textView.string))")
            self.parent.text = textView.string
        }
        
        func controlTextDidChange(_ obj: Notification) {
            print("Did you type somehting?")
            // check the identifier to be sure you have the correct textfield if more are used
            //if let textField = obj.object as? NSTextField, self.myTextField.identifier == textField.identifier {
            //    print("\n\nMy own textField = \(self.myTextField)\nNotification textfield = \(textField)")
            //    print("\nChanged text = \(textField.stringValue)\n")
            //}
        }
        
        
    }
}


//https://gist.github.com/unnamedd/6e8c3fbc806b8deb60fa65d6b9affab0
struct EditorTextView: NSViewRepresentable {
    @Binding var text: String
    
    var onEditingChanged: () -> Void = {}
    var onCommit: () -> Void = {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> CustomTextView {
        let textView = CustomTextView(text: self.text)
        textView.delegate = context.coordinator
        
        return textView
    }
    
    func updateNSView(_ view: CustomTextView, context: Context) {
        view.text = text
        view.selectedRanges = context.coordinator.selectedRanges
    }
}

extension EditorTextView {
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: EditorTextView
        var selectedRanges: [NSValue] = []
        
        init(_ parent: EditorTextView) {
            self.parent = parent
        }
        
        func textDidBeginEditing(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            
            self.parent.text = textView.string
            self.parent.onEditingChanged()
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            
            self.parent.text = textView.string
            self.selectedRanges = textView.selectedRanges
        }
        
        func textDidEndEditing(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            
            self.parent.text = textView.string
            self.parent.onCommit()
        }
    }
}

final class CustomTextView: NSView {
    private var isEditable: Bool
    private var font: NSFont
    
    weak var delegate: NSTextViewDelegate?
    
    var text: String {
        didSet {
            textView.string = text
        }
    }
    
    var selectedRanges: [NSValue] = [] {
        didSet {
            guard selectedRanges.count > 0 else {
                return
            }
            
            textView.selectedRanges = selectedRanges
        }
    }
    
    private lazy var scrollView: NSScrollView = {
        let scrollView = NSScrollView()
        scrollView.drawsBackground = true
        scrollView.borderType = .noBorder
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalRuler = false
        scrollView.autoresizingMask = [.width, .height]
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        return scrollView
    }()
    
    private lazy var textView: NSTextView = {
        let contentSize = scrollView.contentSize
        let textStorage = NSTextStorage()
        
        
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        
        let textContainer = NSTextContainer(containerSize: scrollView.frame.size)
        textContainer.widthTracksTextView = true
        textContainer.containerSize = NSSize(
            width: contentSize.width,
            height: CGFloat.greatestFiniteMagnitude
        )
        
        layoutManager.addTextContainer(textContainer)
        
        
        let textView                     = NSTextView(frame: .zero, textContainer: textContainer)
        textView.autoresizingMask        = .width
        textView.backgroundColor         = NSColor.textBackgroundColor
        textView.delegate                = self.delegate
        textView.drawsBackground         = true
        textView.font                    = self.font
        textView.isEditable              = self.isEditable
        textView.isHorizontallyResizable = false
        textView.isVerticallyResizable   = true
        textView.maxSize                 = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.minSize                 = NSSize(width: 0, height: contentSize.height)
        textView.textColor               = NSColor.labelColor
    
        return textView
    }()
    
    // MARK: - Init
    init(text: String, isEditable: Bool = true, font: NSFont = NSFont.systemFont(ofSize: 12, weight: .regular)) {
        self.font       = font
        self.isEditable = isEditable
        self.text       = text

        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    
    override func viewWillDraw() {
        super.viewWillDraw()
        
        setupScrollViewConstraints()
        setupTextView()
    }
    
    func setupScrollViewConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
    }
    
    func setupTextView() {
        scrollView.documentView = textView
    }
}
