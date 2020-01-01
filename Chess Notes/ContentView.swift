//
//  ContentView.swift
//  chess notes
//
//  Created by Joshua Lin on 18/12/19.
//  Copyright © 2019 Joshua Lin. All rights reserved.
//

import SwiftUI

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
    
    //@EnvironmentObject var masterkey : MasterKey// = MasterKey()
    //@Binding var keycode : Int
    
    
    @State var frames = [CGRect](repeating: .zero, count:64)
    @State var notes: String = ""
    @State var board_history : [[[String]]] = [default_board]
    @State var moves: [String] = [""]
    
    //@State var current_index = 0 //if we press left/right then we are moving between boards
    //@Binding var current_index : Int
    //@Binding var game_length: Int
    //@State var current_index : Int
    
    //var piece_names : [[String]] = board_history[current_index]//default_board
    //let piece_names = board_history[current_index]
    
    //YOU GOT TO BE BIG BRAIIIIIIN
    //View is a value type; not a reference type
    //pass the current_index in from above
    //transcend your medieval thinking
    @ObservedObject var masterkey: MasterKey
    @ObservedObject var userData: UserData
    @Environment(\.managedObjectContext) var managedObjectContext
    
    
    
//    @State var keyBroadcast: KeyBroadcast = KeyBroadcast(){
//        didSet{
//            print("I felt that?")
//        }
//    }
//
//    @EnvironmentObject var master_key: MasterKey{
//        didSet{
//            print("I felt that!")
//        }
//    }
    
    
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
            if legal(board:board_history[masterkey.current_index],x1:index_x,y1:index_y,x2:match/8,y2:match%8) && self.masterkey.current_index == self.board_history.count-1{
                //record which pieces got moved?
                let move : String = cartesian_to_standard(x1:index_x,y1:index_y,
                                      x2:match/8,y2:match%8,
                                      p1:board_history[masterkey.current_index][index_x][index_y],
                                      p2:board_history[masterkey.current_index][match/8][match%8])
                moves.append(move)
                
                print(masterkey.current_index)
                masterkey.current_index = masterkey.current_index + 1
                masterkey.game_length = masterkey.game_length + 1
                print(masterkey.current_index,"how is this not incrementing")
                //move the pieces
                board_history.append(copy_board(board: board_history[masterkey.current_index-1]))
                board_history[masterkey.current_index][match/8][match%8] = board_history[masterkey.current_index][index_x][index_y]
                board_history[masterkey.current_index][index_x][index_y] = "BLANK"
                
                
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
                            Piece(name:self.board_history[self.masterkey.current_index][x][y],
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
                            self.board_history[self.masterkey.current_index] = default_board
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
                        Text("Notes")
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

