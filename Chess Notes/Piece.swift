//
//  Piece.swift
//  chess notes
//
//  Created by Joshua Lin on 19/12/19.
//  Copyright © 2019 Joshua Lin. All rights reserved.
//


import SwiftUI

enum DragState {
    case yes
    case no
}

struct Piece: View {
    
    @State var dragAmount = CGSize.zero //this is a vector as far as I can tell
    @State var dragState = DragState.no //Not being dragged?
    
    var name: String //holds the name of the piece... I don't really know
    var released: ((CGPoint, Int, Int, String) -> Void)? //A dummy lambda function that handles what happens when we release?
    
    //Passes in the position at which we end, and also the name of what I am.
    var index_x: Int
    var index_y: Int
    let square_size = Double(75)
    
    var body: some View {
        Image(name)
            .resizable()
            .frame(width:CGFloat(square_size),height:CGFloat(square_size))
            .offset(CGSize(width : (Double(index_x)-3.5)*square_size + Double(dragAmount.width),
                           height: (Double(index_y)-3.5)*square_size + Double(dragAmount.height)))
            .zIndex(dragAmount == .zero ? 0 : 1) //Big brain: z-index controls the front-back layout of everything. This line makes sure that when you drag, it remains on top.
            .gesture(
                DragGesture(minimumDistance: CGFloat(10),
                            coordinateSpace: CoordinateSpace.global)
                    .onChanged {
                        print("changed drag")
                        self.dragAmount = CGSize(width: $0.translation.width, height: -$0.translation.height)
                        self.dragState  = DragState.yes
                    }
                    .onEnded {
                        self.dragAmount = CGSize.zero
                        self.dragState  = DragState.no
                        self.released!($0.location, self.index_x, self.index_y, self.name)
                    })
            .gesture(
                TapGesture(count:1)
                    .onEnded {
                        print("tapped")
                    }
                
            )
            .focusable(true)
    }
}

struct Piece_Previews: PreviewProvider {
    static var previews: some View {
        Piece(name:"WP",
              index_x:0,
              index_y:0)
    }
}

