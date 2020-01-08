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
            
            //this is the top bar of buttons.
//            HStack{
//
//                //BorderedButtonStyle()
//
//                Button(action:{
//                    print("ah")
//                }){
//                    VStack{
//                        Image("iFEN")
//                            .resizable()
//                            .frame(width:40,height:40)
//                        Text("Import FEN")
//                    }
//                }.buttonStyle(BorderlessButtonStyle())
//                 .padding()
//
//
//                Button(action:{
//                    let controller = DetailWindowController(rootView:
//                        VStack{
//                            TextField("Paste PGN here",text:self.$iPGN)
//                            Button(action:{
//                                let history = import_PGN(PGN: self.iPGN)
//                                self.backend.board_history = history.0
//                                self.backend.moves = history.1
//                                self.backend.game_length = self.backend.board_history.count
//                            }){
//                                Text("Submit PGN")
//                            }
//                        })
//                    controller.window?.title = "Import PGN"
//                    controller.showWindow(nil)
//                }){
//                    VStack{
//                        Image("iFEN")
//                            .resizable()
//                            .frame(width:CGFloat(40),height:CGFloat(40))
//                        Text("Import PGN")
//                    }
//                }.buttonStyle(BorderlessButtonStyle())
//                .padding()
//
//
//                Button(action:{
//                    let controller = DetailWindowController(rootView: TextField("",text: .constant(self.backend.board_history[self.backend.current_index].to_FEN()))
//                    )
//                    controller.window?.title = "Exported FEN"
//                    controller.showWindow(nil)
//                }){
//                    VStack{
//                        Image("iFEN").resizable()
//                        .frame(width:CGFloat(40),height:CGFloat(40))
//                        Text("Export FEN")
//                    }
//                }.buttonStyle(BorderlessButtonStyle())
//                .padding()
//
//                Button(action:{
//
//                }){
//                    VStack{
//                        Image("iFEN").resizable()
//                        .frame(width:CGFloat(40),height:CGFloat(40))
//                        Text("Export PGN")
//                    }
//                }.buttonStyle(BorderlessButtonStyle())
//                .padding(1)
//                Spacer()
//            }
            
            
            
            HStack{
                
                
                VStack{
                    HStack{
                        Text("Notes").font(.system(size: 16))
                        Spacer()
                        Button(action:{
                            let new_note = Note(context : self.moc)
                            new_note.board_state = self.backend.board_history[self.backend.current_index].to_FEN(serialise:true)
                            new_note.note = self.backend.note_text//self.userData.text
                            do{
                                try self.moc.save()
                            } catch {
                                print("ruh roh",error)
                            }
                            self.backend.stored_notes[self.backend.current_index] = self.backend.note_text
                            
                        }){
                            Text("Save Notes")
                        }
                    }
                    VStack{
                        EditorTextView(text: self.$backend.note_text)
                    }
                }
                .frame(width:CGFloat(300),height:CGFloat(600))
                
                ZStack{
                    Board(frames: self.$frames)
                        .frame(width: CGFloat(600), height: CGFloat(600))
                    
                    ForEach(0..<8){x in
                        ForEach(0..<8){y in
                            Piece(name:self.backend.board_history[self.backend.current_index].board[x][y],
                                  released: self.released,
                                  index_x: x,
                                  index_y: y)
                        }
                    }
                }
                
                
                VStack {
                    Text("Analysis Pane")
                    HStack{
                        Button(action: {
                            self.backend.reset()
                        }){
                            Text("Reset Board")
                        }
                    }
                    
                    VStack{
                        Text("Debug Region")
                        Button(action: {
                            print(self.backend.board_history[self.backend.current_index].to_FEN(serialise:true))
                        }){
                            Text("Debug Button")
                        }
                        Text(self.backend.note_text)
                        //Text(self.backend.stored_notes.)
                    }
                    
                    
                    VStack{
                        Text("Move List")
                        Text(self.backend.moves.joined(separator:" "))
                        HStack{
                            Button(action: {
                                self.backend.backward()
                            }){
                                Text("⬅️")
                                .font(.system(size: 30))
                            }
                            Button(action: {
                                self.backend.forward()
                            }){
                                Text("➡️")
                                .font(.system(size: 30))
                            }
                        }
                    }
                        .frame(width: 200,height:100,alignment :.topLeading)
                        .border(Color.blue)
                    Text("Next Moves")
                        .frame(width: 200,height:100,alignment :.topLeading)
                        .border(Color.blue)
                        
                }
            }
        }


    }
}



