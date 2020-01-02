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
    
    @FetchRequest(entity:Note.entity(), sortDescriptors:[]) var stored_notes: FetchedResults<Note>
    
    
    @State var frames = [CGRect](repeating: .zero, count:64)
    @State var notes: String = ""
    @State var board_history: [BoardState] = [BoardState(board:default_board,
                                                         wkc:true, wqc:true,
                                                         bkc:true, bqc:true)]
    @State var moves: [String] = [""]
    
    @ObservedObject var masterkey: MasterKey
    @ObservedObject var userData: UserData
    @Environment(\.managedObjectContext) var moc
    
    
//    func button_pressed(keycode: Int){
//        if (keycode == 123){
//            if current_index == 0{
//                //make a noise! we can't go any further back
//                print("youve reached the first move")
//                return
//            }
//            self.current_index = self.current_index - 1
//            //piece_names = board_history[current_index]
//        }
//        if (keycode == 124){
//            if current_index == board_history.count-1{
//                print("you've reached the last move")
//                return
//            }
//            self.current_index = self.current_index + 1
//            //piece_names = board_history[current_index]
//        }
//
//        print("watashi wa kitta desu ne")
//        return
//    }
    
    func released(location: CGPoint, index_x: Int, index_y: Int, name: String) -> Void{
        if let match = frames.firstIndex(where: {$0.contains(location)}){
            //print("board_history.count",board_history.count)
            //if legal(board:board_history[masterkey.current_index],x1:index_x,y1:index_y,x2:match/8,y2:match%8) && self.masterkey.current_index == self.board_history.count-1{
            if board_history[masterkey.current_index].legal(x1:index_x,y1:index_y,x2:match/8,y2:match%8) && self.masterkey.current_index == self.board_history.count-1{
                
                let p1 = board_history[masterkey.current_index].board[index_x][index_y]
                
                //record which pieces got moved?
                let move : String = cartesian_to_standard(x1:index_x,y1:index_y,
                                      x2:match/8,y2:match%8,
                                      p1:p1,
                                      p2:board_history[masterkey.current_index].board[match/8][match%8])
                moves.append(move)
                
                
                
                
                //print(masterkey.current_index)
                masterkey.current_index = masterkey.current_index + 1
                masterkey.game_length = masterkey.game_length + 1
                //print(masterkey.current_index,"how is this not incrementing")
                //move the pieces
                //board_history.append(copy_board(board: board_history[masterkey.current_index-1]))
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
                userData.text = stored_notes.first{$0.board_state == board_history[masterkey.current_index].to_string()}!.note!
                
            }
        }
        return
    }
    

    var body: some View {
        VStack {
            Text("Chess Notes alpha v0.1")
                .font(.title)
            Text("Made by me")
            HStack{
                ZStack{
                    Board(frames: self.$frames)
                        .frame(width: CGFloat(600), height: CGFloat(600))
                    
                    //Text("?")
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
                            //Actually need to reset everything?
                            //self.board_history[self.masterkey.current_index] = default_board
                        }){
                            Text("Reset Board")
                        }
                        Button(action: {
                            print("debug says ",self.masterkey.current_index,self.masterkey.game_length)
                        }){
                            Text("Debug Button")
                        }
                    }
                    VStack{
                        Text("Move List")
                        Text(self.moves.joined(separator:" "))
                        HStack{
                            Button(action: {
                                print("pressed left")
                                //self.button_pressed(keycode:123)
                            }){
                                Text("⬅️")
                                .font(.system(size: 30))
                            }
                            Button(action: {
                                print("pressed right")
                                //self.button_pressed(keycode:124)
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
                   
                    VStack{
                        HStack{
                            Text("Notes")
                            Button(action:{
                                let new_note = Note(context : self.moc)
                                new_note.board_state = self.board_history[self.masterkey.current_index].to_string()
                                new_note.note = self.userData.text
                                do{
                                    try self.moc.save()
                                } catch {
                                    print("ruh roh",error)
                                }
                                
                            }){
                                Text("Save Notes")
                            }
                        }
                        MultilineTextView(text: $userData.text)
                    }
                    .frame(width:CGFloat(200),height:CGFloat(200))
                        .border(Color.blue)
                        
                }
            }
        }


    }
}

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
                                    }
                                )
                    }
                }
            }
        }
    }
}

