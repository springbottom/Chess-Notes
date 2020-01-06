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


struct ContentView: View {
    
    //Fetch all the data inside the coredata framework
    @FetchRequest(entity:Note.entity(), sortDescriptors:[]) var stored_notes: FetchedResults<Note>
    
    //I believe these are the frames that hover over the chessboard detecting when we drop a piece
    @State var frames = [CGRect](repeating: .zero, count:64)
    
    //This is the variable that holds the text inside the 'note' textbox.
    @State var note_text = ""
    
    //This is the board_history of the current line of play. In future, we need to implement different lines.
    @State var board_history: [BoardState] = [BoardState(board:default_board,
                                                         wkc:true, wqc:true,
                                                         bkc:true, bqc:true,
                                                         to_move: "w",
                                                         hmc: 0, fmc:1)]
    
    //This is the array that holds the sequence of moves so far in the main line of play. These are shown
    @State var moves: [String] = [""]
    
    //This is the observed object that interacts with the editor window when we press left/right.
    @ObservedObject var masterkey: MasterKey
    
    //This is the environment that makes the coredata work. I don't really know what this is either.
    @Environment(\.managedObjectContext) var moc
    
    //This function handles the event where we release a piece, and it looks for a match.
    //The logic should really be handled inside of Chess_backend or something...
    func released(location: CGPoint, index_x: Int, index_y: Int, name: String) -> Void{
        if let match = frames.firstIndex(where: {$0.contains(location)}){
            
            if board_history[masterkey.current_index].legal(x1:index_x,y1:index_y,x2:match/8,y2:match%8) && self.masterkey.current_index == self.board_history.count-1{
                
                let p1 = board_history[masterkey.current_index].board[index_x][index_y]
                
                //record which pieces got moved?
                let move : String = cartesian_to_standard(x1:index_x,y1:index_y,
                                      x2:match/8,y2:match%8,
                                      p1:p1,
                                      p2:board_history[masterkey.current_index].board[match/8][match%8])
                moves.append(move)
                
                masterkey.current_index = masterkey.current_index + 1
                masterkey.game_length = masterkey.game_length + 1

                board_history.append(board_history[masterkey.current_index-1].copy_board())
                board_history[masterkey.current_index].board[match/8][match%8] = board_history[masterkey.current_index].board[index_x][index_y]
                board_history[masterkey.current_index].board[index_x][index_y] = "BLANK"
                
                //now, if we were castling we need to move the rook as well..
                if (p1 == "WK") && abs(index_x - match/8) == 2{
                    board_history[masterkey.current_index].board[(index_x+match/8)/2][index_y] = "WR"
                    if match/8 > index_x{
                        board_history[masterkey.current_index].board[7][7] = "BLANK"
                    }
                    else{
                        board_history[masterkey.current_index].board[0][7] = "BLANK"
                    }
                }
                if (p1 == "BK") && abs(index_x - match/8) == 2{
                    board_history[masterkey.current_index].board[(index_x+match/8)/2][index_y] = "BR"
                    if match/8 > index_x{
                        board_history[masterkey.current_index].board[7][0] = "BLANK"
                    }
                    else{
                        board_history[masterkey.current_index].board[0][0] = "BLANK"
                    }
                }
                
                //Now, if we have moved a king/rook, we need to update wkc,wqc,...
                if (p1 == "WK"){
                    board_history[masterkey.current_index].wkc = false
                    board_history[masterkey.current_index].wqc = false
                }
                if (p1 == "BK"){
                    board_history[masterkey.current_index].bkc = false
                    board_history[masterkey.current_index].bqc = false
                }
                if (p1 == "WR" && index_y == 7){
                    if (index_x == 0){
                        board_history[masterkey.current_index].wqc = false
                    }
                    if (index_x == 7){
                        board_history[masterkey.current_index].wkc = false
                    }
                }
                if (p1 == "BR" && index_y == 0){
                    if (index_x == 0){
                        board_history[masterkey.current_index].bqc = false
                    }
                    if (index_x == 7){
                        board_history[masterkey.current_index].bkc = false
                    }
                }
                
                
                //Now, if we have notes in the bank, we need to load them
                //userData.text = stored_notes.first{$0.board_state == board_history[masterkey.current_index].to_string()}?.note ?? ""
                note_text = stored_notes.first{$0.board_state == board_history[masterkey.current_index].to_string()}?.note ?? ""
                
            }
        }
        return
    }
    

    var body: some View {
        VStack {
            //Text("Chess Notes alpha v0.1")
            //    .font(.title)
            //Text("Made by me")
            HStack{
                
                
                VStack{
                    HStack{
                        Text("Notes").font(.system(size: 16))
                        Spacer()
                        Button(action:{
                            let new_note = Note(context : self.moc)
                            new_note.board_state = self.board_history[self.masterkey.current_index].to_string()
                            new_note.note = self.note_text//self.userData.text
                            do{
                                print("Saving note")
                                print(new_note.board_state)
                                //print(self.note_text)
                                print(new_note.note)
                                //print(self.userData.text)
                                //print(new_note.note)
                                try self.moc.save()
                            } catch {
                                print("ruh roh",error)
                            }
                            
                            print("Has it saved?")
                            print((self.stored_notes.first{$0.board_state == self.board_history[self.masterkey.current_index].to_string()}?.note ?? ""))
                            //This print line seems to... fix things... which makes no sense to me but that's ok!
                            
                        }){
                            Text("Save Notes")
                        }
                    }
                    VStack{
                        //MultilineTextView(text: $userData.text)
                        //TextView(text: $note_text)//$userData.text)
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



