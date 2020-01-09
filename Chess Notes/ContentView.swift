//
//  ContentView.swift
//  chess notes
//
//  Created by Joshua Lin on 18/12/19.
//  Copyright © 2019 Joshua Lin. All rights reserved.
//

import SwiftUI
import CoreData

let default_board : [[String]] = [
    ["BR","BP","BLANK","BLANK","BLANK","BLANK","WP","WR"],
    ["BN","BP","BLANK","BLANK","BLANK","BLANK","WP","WN"],
    ["BB","BP","BLANK","BLANK","BLANK","BLANK","WP","WB"],
    ["BQ","BP","BLANK","BLANK","BLANK","BLANK","WP","WQ"],
    ["BK","BP","BLANK","BLANK","BLANK","BLANK","WP","WK"],
    ["BB","BP","BLANK","BLANK","BLANK","BLANK","WP","WB"],
    ["BN","BP","BLANK","BLANK","BLANK","BLANK","WP","WN"],
    ["BR","BP","BLANK","BLANK","BLANK","BLANK","WP","WR"]
]

let default_boardstate : BoardState = BoardState(board:default_board,
wkc:true, wqc:true,
bkc:true, bqc:true,
to_move: "w",
hmc: 0, fmc:1)


struct ContentView: View {
    
    //Fetch all the data inside the coredata framework
    @FetchRequest(entity:Note.entity(), sortDescriptors:[]) var stored_notes: FetchedResults<Note>
    
    //I believe these are the frames that hover over the chessboard detecting when we drop a piece
    @State var frames = [CGRect](repeating: .zero, count:64)
    
    //This is the observed object that interacts with the editor window when we press left/right.
    @ObservedObject var backend: Backend
    
    //This is the environment that makes the coredata work. I don't really know what this is either.
    @Environment(\.managedObjectContext) var moc
    
    //
    @State var iPGN : String = ""
    
    //This function handles the event where we release a piece, and it looks for a match.
    func released(location: CGPoint, index_x: Int, index_y: Int, name: String) -> Void{
        if let match = frames.firstIndex(where: {$0.contains(location)}){
            if let (move,new_board) = self.backend.board_history[backend.current_index].move(x1:index_x,y1:index_y,x2:match/8,y2:match%8){
                if self.backend.current_index == self.backend.board_history.count-1{
                    self.backend.process_move(move:move, new_board:new_board)
                    self.backend.stored_notes.append(stored_notes.first{$0.board_state == self.backend.board_history[backend.current_index].to_FEN(serialise:true)}?.note ?? "")
                    self.backend.update_text()
                }
            }
        }
        return
    }
    
    
    var body: some View {
        VStack {
            HStack{
                VStack{
                    EditorTextView(text: self.$backend.note_text)//, backend: self.$backend)
                    .padding()
                }
                .frame(width:CGFloat(300),height:CGFloat(600))
                
                ZStack{
                    Board(frames: self.$frames)
                        .frame(width: CGFloat(600), height: CGFloat(600))
                        .focusable(true)
                    
                    ForEach(0..<8){x in
                        ForEach(0..<8){y in
                            Piece(backend: self.backend,
                                  name:self.backend.board_history[self.backend.current_index].board[x][y],
                                  released: self.released,
                                  index_x: x,
                                  index_y: y)
                        }
                    }
                }
                
                
                VStack {
                    VStack{
                        MoveList(moves:Array(self.backend.moves.dropFirst()))
                        .padding()
                        //Text(String(NSApplication.sharedApplication.keyWindow!.contentViewController!))
                    }
                        .frame(width: 200,height:500,alignment :.topLeading)
                    Button(action:{
                        print(NSApplication.shared.keyWindow!.firstResponder!)
                    }){
                        Text("Debug")
                    }
                        
                }
            }
        }


    }
}



