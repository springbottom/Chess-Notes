//
//  MoveList.swift
//  Chess Notes
//
//  Created by Joshua Lin on 8/1/20.
//  Copyright © 2020 Joshua Lin. All rights reserved.
//

import Foundation
import SwiftUI

struct MovePair : View{
    var moveNumber : Int
    var leftText : String?
    var rightText : String?
    
    var body : some View{
        HStack{
            Text(String(moveNumber) + String("."))
            Text(leftText ?? "...")
            Text(rightText ?? "...")
        }
    }
}

struct MoveList : View{
    var moves : [String]
    
    var body : some View{
        List{
            ForEach(0..<self.moves.count/2,id:\.self){ i in
                MovePair(moveNumber : i+1,
                         leftText   : self.moves[2*i],
                         rightText  : self.moves[2*i+1])
            }
            MovePair(moveNumber : self.moves.count/2 + 1,
                     leftText   : ((self.moves.count%2 == 1) ? self.moves.last! : ""))
        }
    }
}


//func moveList(moves: [String]) -> some View{
//
//
//
//    var my_stack = VStack()
//    my
//
//    return Text(moves.joined(separator:" "))
//}
