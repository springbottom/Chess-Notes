//
//  Backend.swift
//  Chess Notes
//
//  Created by Joshua Lin on 7/1/20.
//  Copyright © 2020 Joshua Lin. All rights reserved.
//

import Foundation

class Backend: ObservableObject{
    @Published var keycode : Int = 0
    @Published var current_index : Int = 0
    @Published var game_length : Int = 1
    
    @Published var board_history: [BoardState] = [default_boardstate]
    @Published var moves: [String] = [""]
    @Published var note_text: String = "Hello"
    
    @Published var stored_notes: [String] = [""]
   
    func update_text(){
        self.note_text = self.stored_notes[current_index]
    }
    
    func backward(){
        if (self.current_index != 0){self.current_index = self.current_index - 1}
        else{
            //make a noise
        }
        self.update_text()
        return
    }
    
    func forward(){
        self.update_text()
        if (self.current_index != self.game_length - 1){self.current_index = self.current_index + 1}
        else{
            //make a noise?
        }
        self.update_text()
        return
    }
    
    func process_move(move:String, new_board: BoardState){
        //if let (move,new_board) = self.board_history[masterkey.current_index].move(x1:x1,y1:y1,x2:x2,y2:y2){
            //if self.current_index == self.board_history.count-1{
        self.moves.append(move)
        self.current_index = self.current_index + 1
        self.game_length   = self.game_length + 1
        self.board_history.append(new_board)
                
                //self.stored_notes.append(stored_notes.first{$0.board_state == self.masterkey.board_history[masterkey.current_index].to_FEN(serialise:true)}?.note ?? "")
        //self.update_text()
            //}
        //}
    }

    func reset(){
        self.board_history = [default_boardstate]
        self.moves = [""]
        self.current_index = 0
        self.game_length = 1
        self.stored_notes = [""]

        self.note_text = ""//self.stored_notes.first{$0.board_state == self.masterkey.board_history[self.masterkey.current_index].to_FEN(serialise:true)}?.note ?? ""
    }
    
}

