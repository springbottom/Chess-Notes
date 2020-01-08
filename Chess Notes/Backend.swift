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
    
    @Published var iPGN: String = ""
   
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
        self.moves.append(move)
        self.current_index = self.current_index + 1
        self.game_length   = self.game_length + 1
        self.board_history.append(new_board)
    }

    func reset(){
        self.board_history = [default_boardstate]
        self.moves = [""]
        self.current_index = 0
        self.game_length = 1
        self.stored_notes = [""]

        self.note_text = ""
    }
    
}

