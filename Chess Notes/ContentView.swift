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
    
    //This is the variable that holds the text inside the 'note' textbox.
    @State var note_text = ""
    
    //This is the board_history of the current line of play. In future, we need to implement different lines.
    @State var board_history: [BoardState] = [default_boardstate]
    
    //This is the array that holds the sequence of moves so far in the main line of play. These are shown
    @State var moves: [String] = [""]
    
    //This is the observed object that interacts with the editor window when we press left/right.
    @ObservedObject var masterkey: MasterKey
    
    //This is the environment that makes the coredata work. I don't really know what this is either.
    @Environment(\.managedObjectContext) var moc
    
    //The import/export functionality is baked into the main view, this means that we need
    //state variables controlling if they are around??
    @State var eFEN : Bool = false
    
    //This function handles the event where we release a piece, and it looks for a match.
    func released(location: CGPoint, index_x: Int, index_y: Int, name: String) -> Void{
        if let match = frames.firstIndex(where: {$0.contains(location)}){
            
            if let (move,new_board) = board_history[masterkey.current_index].move(x1:index_x,y1:index_y,x2:match/8,y2:match%8){
                if self.masterkey.current_index == self.board_history.count-1{
                    moves.append(move)
                    masterkey.current_index = masterkey.current_index + 1
                    masterkey.game_length = masterkey.game_length + 1
                    board_history.append(new_board)
                    
                    note_text = stored_notes.first{$0.board_state == board_history[masterkey.current_index].to_FEN()}?.note ?? ""
                }
            }
        }
        return
    }
    
    //resets the program essentially.
    func reset(){
        self.board_history = [default_boardstate]
        self.moves = [""]
        self.masterkey.current_index = 0
        self.masterkey.game_length = 1
        
        self.note_text = self.stored_notes.first{$0.board_state == self.board_history[self.masterkey.current_index].to_FEN()}?.note ?? ""
    }
    
    
    var body: some View {
        VStack {
            
            //this is the top bar of buttons.
            HStack{
                Button(action:{

                }){
                    Text("Import FEN")
                }
                Button(action:{
                    
                }){
                    Text("Import PGN")
                }
                Button(action:{
                    let controller = DetailWindowController(rootView: TextField("",text: .constant(self.board_history[self.masterkey.current_index].to_FEN()))
                    )
                    controller.window?.title = "Exported FEN"
                    controller.showWindow(nil)
                }){
                    Text("Export FEN")
                }
                Button(action:{
                    
                }){
                    Text("Export PGN")
                }
            }
            
            
            
            HStack{
                
                
                VStack{
                    HStack{
                        Text("Notes").font(.system(size: 16))
                        Spacer()
                        Button(action:{
                            let new_note = Note(context : self.moc)
                            new_note.board_state = self.board_history[self.masterkey.current_index].to_FEN()
                            new_note.note = self.note_text//self.userData.text
                            do{
                                try self.moc.save()
                            } catch {
                                print("ruh roh",error)
                            }
                            
                            print("Has it saved?")
                            print((self.stored_notes.first{$0.board_state == self.board_history[self.masterkey.current_index].to_FEN()}?.note ?? ""))
                            //This print line seems to... fix things... which makes no sense to me but that's ok!
                            
                        }){
                            Text("Save Notes")
                        }
                    }
                    VStack{
                        EditorTextView(text: $note_text)
                    }
                }
                .frame(width:CGFloat(300),height:CGFloat(600))
                
                ZStack{
                    Board(frames: self.$frames)
                        .frame(width: CGFloat(600), height: CGFloat(600))
                    
                    ForEach(0..<8){x in
                        ForEach(0..<8){y in
                            Piece(name:self.board_history[self.masterkey.current_index].board[x][y],
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
                            self.reset()
                        }){
                            Text("Reset Board")
                        }
                    }
                    
                    VStack{
                        Text("Debug Region")
                        Button(action: {
                            
                        }){
                            Text("Debug Button")
                        }
                        
                    }
                    
                    
                    VStack{
                        Text("Move List")
                        Text(self.moves.joined(separator:" "))
                        HStack{
                            Button(action: {
                                self.masterkey.backward()
                            }){
                                Text("⬅️")
                                .font(.system(size: 30))
                            }
                            Button(action: {
                                self.masterkey.forward()
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



