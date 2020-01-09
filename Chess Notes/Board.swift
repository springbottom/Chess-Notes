//
//  Board.swift
//  Chess Notes
//
//  Created by Joshua Lin on 4/1/20.
//  Copyright © 2020 Joshua Lin. All rights reserved.
//

import SwiftUI

struct Board: View {
    @Binding var frames: [CGRect]
    let colors = [Color(NSColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)),
                  Color(NSColor(red: 1, green: 1, blue: 1, alpha: 1))]
    var body: some View {
        VStack(spacing : 0){
            ForEach((0...7), id:\.self){y in
                HStack(spacing : 0){
                    ForEach((0...7),id:\.self){x in
                            Rectangle()
                                .foregroundColor(self.colors[(x+y)%2])
                                .overlay(
                                    GeometryReader{ geo in
                                        Color.clear
                                            .onAppear{
                                                self.frames[x*8+y] = geo.frame(in: .global)
                                            }
                                    }.focusable(true)
                                )
                        //.overlay(
                        //    List{
                        //        Rectangle().foregroundColor(Color.clear)
                        //})
                                .focusable(true)
                    }
                }.focusable(true)
            }
        }.focusable(true)
    }
}

//struct Board_Previews: PreviewProvider {
//    static var previews: some View {
//        Board()
//    }
//}
