//
//  Chess_backend.swift
//  Joshua Lin
//
//  Created by Joshua Lin on 24/12/19.
//  Copyright © 2019 Joshua Lin. All rights reserved.
//

import Foundation

class BoardState{
    var board : [[String]] //The only thing that is necessary is the board
    var wkc,wqc,bkc,bqc : Bool? //white/black king/queenside castling
    var to_move : String?
    var hmc : Int? //Half-move clock - how many moves have been made without any pawn moves or captures
    var fmc : Int? //Full-move clock, 1e4 1e5 2Nc3 that kind of stuff
    var en_passant: String?
    
    init(board : [[String]],
         wkc : Bool? = nil, wqc : Bool? = nil,
         bkc : Bool? = nil, bqc : Bool? = nil,
         to_move : String? = nil,
         hmc: Int? = nil, fmc:Int? = nil,
         en_passant: String? = nil
         ){
        
        self.board = board
        self.wkc = wkc; self.wqc = wqc //white can castle, king or queen side
        self.bkc = bkc; self.bqc = bqc //black can castle, king or queen side
        self.to_move = to_move//"w" or "b", describes whose turn it is to move.
        self.hmc = hmc
        self.fmc = fmc
        self.en_passant = en_passant
    }
    
    //transform the board into its FEN - which we should use rather than my other janky thing..
    func to_FEN(serialise: Bool = false) -> String{
        //if serialise is true, then we should not include the hmc and the fmc
        var to_return = ""
        var blank_count = 0
        for y in 0...7{
            for x in 0...7{
                if self.board[x][y] == "BLANK"{
                    blank_count = blank_count + 1
                }
                else{
                    if blank_count != 0{
                        to_return = to_return + String(blank_count)
                        blank_count = 0
                    }
                    if self.board[x][y].first! == "W"{
                        to_return = to_return + String(self.board[x][y].last!)
                    }
                    else{
                        to_return = to_return + String(self.board[x][y].lowercased().last!)
                    }
                }
            }
            if blank_count != 0{
                to_return = to_return + String(blank_count)
                blank_count = 0
            }
            if y < 7{
                to_return = to_return + "/"
            }
            else{
                to_return = to_return + " "
            }
        }
        to_return = to_return + self.to_move! + " "
        if !self.wkc! && !self.wqc! && !self.bkc! && !self.bqc!{
            to_return = to_return + "-" + " "
        }
        else{
            if self.wkc!{
                to_return = to_return + "K"
            }
            if self.wqc!{
                to_return = to_return + "Q"
            }
            if self.bkc!{
                to_return = to_return + "k"
            }
            if self.bqc!{
                to_return = to_return + "q"
            }
            to_return = to_return + " "
        }
        
        to_return = to_return + (self.en_passant ?? "-")
        if !serialise{
            to_return = to_return + " " + String(self.hmc!) + " " + String(self.fmc!)
        }
        
        //var to_return = self.board.joined(separator:[","])
        return to_return
    }
    
    //FEN without the fuss - I think we will ignore the hmc and the fmc to allow for transposition kind of ideas.
//    func serialise() -> String{
//        var to_return = self.to_FEN()
//        to_return.removeLast(4)
//        //print(to_return)
//        return to_return
//    }
    
    //copy a board?! this returns a ccopy of the CLASS...
    func copy_board() -> BoardState{
        return BoardState(board:self.board,
                          wkc:self.wkc,wqc:self.wqc,
                          bkc:self.bkc,bqc:self.bqc,
                          to_move:self.to_move,
                          hmc:self.hmc,
                          fmc:self.fmc,
                          en_passant:self.en_passant)
    }
    
    //searches the board for all indices that match.
    func search_for_piece(p:String) -> [[Int]]{
        var to_return = [[Int]]()
        for x in 0...7{
            for y in 0...7{
                if (self.board[x][y] == p){
                    to_return.append([x,y])
                }
            }
        }
        return to_return
    }
    
    //check if a color is in check
    func color_in_check(color:String) -> Bool{
        let king_loc = self.search_for_piece(p:color+"K")[0]
        let enemy_color = (color == "W") ? "B" : "W"
        let enemy_direction = (color == "W") ? 1 : -1
        
        var attackers = self.search_for_piece(p:enemy_color+"P")
        for a in attackers{
            if king_loc[1] == a[1]+enemy_direction && abs(king_loc[0]-a[0]) == 1{
                return true
            }
        }
        
        attackers = self.search_for_piece(p:enemy_color+"R")
        for a in attackers{
            if a[0]+a[1] == king_loc[0]+king_loc[1] || a[0]-a[1] == king_loc[0]-king_loc[1]{
                continue
            }
            if self.empty_line(x1:king_loc[0],y1:king_loc[1],x2:a[0],y2:a[1]){
                return true
            }
        }
        
        attackers = self.search_for_piece(p:enemy_color+"N")
        for a in attackers{
            if abs(a[0]-king_loc[0]) == 1 && abs(a[1]-king_loc[1]) == 2{
                return true
            }
            else if abs(a[0]-king_loc[0]) == 2 && abs(a[1]-king_loc[1]) == 1{
                return true
            }
        }
        
        attackers = self.search_for_piece(p:enemy_color+"B")
        for a in attackers{
            if a[0] == king_loc[0] || a[1] == king_loc[1]{
                continue
            }
            if self.empty_line(x1:king_loc[0],y1:king_loc[1],x2:a[0],y2:a[1]){
                return true
            }
        }
        
        attackers = self.search_for_piece(p:enemy_color+"Q")
        for a in attackers{
            if self.empty_line(x1:king_loc[0],y1:king_loc[1],x2:a[0],y2:a[1]){
                return true
            }
        }
        
        attackers = self.search_for_piece(p:enemy_color+"K")
        for a in attackers{
            if abs(a[0]-king_loc[0])+abs(a[1]-king_loc[1]) == 1{
                return true
            }
            if abs(a[0]-king_loc[0])+abs(a[1]-king_loc[1]) == 2{
                if a[0] != king_loc[0] || a[1] == king_loc[1]{
                    return true
                }
            }
            
        }
        
        return false
    }
    
    //Color-neutral in_check check.
    func in_check() -> Bool {
        if self.color_in_check(color:"W") || color_in_check(color:"B"){
            return true
        }
        return false
    }
    
    //returns true if the two points are in a straight line, and nothing inbetween
    func empty_line(x1: Int, y1: Int, x2: Int, y2:Int) -> Bool{
        //print("checking blank line",x1,y1,x2,y2)
        if x1 == x2{
            print("equal x")
            if abs(y1-y2) == 1{
                return true
            }
            return !(min(y1,y2)+1...max(y1,y2)-1).map({self.board[x1][$0] != "BLANK"}).contains(true)
        }
        if y1 == y2{
            print("equal y")
            if abs(x1-x2) == 1{
                return true
            }
            return !(min(x1,x2)+1...max(x1,x2)-1).map({self.board[$0][y1] != "BLANK"}).contains(true)
        }
        if x1-x2 == y1-y2{
            print("minus B",x1,y1)
            if abs(x1-x2) == 1{
                return true
            }
            return !(1...max(x1,x2)-min(x1,x2)-1).map({self.board[min(x1,x2)+$0][min(y1,y2)+$0] != "BLANK"}).contains(true)
        }
        if x1+y1 == x2+y2{
            print("add B",x1,y1)
            if abs(x1-x2) == 1{
                return true
            }
            return !(1...max(x1,x2)-min(x1,x2)-1).map({self.board[min(x1,x2)+$0][max(y1,y2)-$0] != "BLANK"}).contains(true)
        }
        //print("no hooks")
        return false
    }
 
    //"moves a move", returns the move, and the new board.
    func move(x1: Int, y1: Int, x2: Int, y2:Int) -> (String,BoardState)?{
        
        let p = self.board[x1][y1]
        if p == "BLANK"{return nil} //can't move nothing.
        
        let p2 = self.board[x2][y2]
        
        let my_color     = p.first! //p[p.startIndex]
        let my_piecetype = p.last!  //p[p.index(before : p.endIndex)]
        let my_direction = (my_color == "W") ? -1 : 1
        
        //if we move a pawn twice we need to remember that.
        var en_passant : String? = nil
        
        //record whether we need to increment the half-move-clock.
        var increment_hmc : Bool = true
        
        //record whether or not the castling rights get revoked.
        var cwkc = false; var cwqc = false
        var cbkc = false; var cbqc = false //do we need to change the rights to none?
        
        //keep track of if we promote
        var did_promote : Bool = false
        
        //here are the squares that get changed
        var changed : [(Int,Int,String)] = []
        
        //If we are trying to move an incorrect color?
        if my_color.lowercased() != self.to_move!{return nil}
        
        //If we are trying to capture our own piece? it's not legal.
        if self.board[x2][y2].first! == my_color && self.board[x2][y2] != "BLANK"{return nil}
        
        //If we haven't moved, it isn't a legal move
        if x1 == x2 && y1 == y2{return nil}
        
        //now, if we are moving a pawn:
        if my_piecetype == "P"{
            var good = 0
            if x1 == x2 && y2 - y1 == my_direction && self.board[x2][y2] == "BLANK"{
                //we are moving forward one into a blank square
                good = 1
                if (y2 == 0 && my_color == "W") || (y2 == 7 && my_color == "B"){
                    did_promote = true
                }
            }
            else if abs(x1 - x2) == 1 && y2 - y1 == my_direction && self.board[x2][y2] != "BLANK"{
                //we are capturing a piece
                good = 1
                if (y2 == 0 && my_color == "W") || (y2 == 7 && my_color == "B"){
                    did_promote = true
                }
            }
            else if x1 == x2 && y2 - y1 == my_direction*2 && board[x1][y1+my_direction] == "BLANK" &&
                board[x1][y2] == "BLANK" && y1 == (7 - 5*my_direction)/2{
                //we are pushing two from our original rank
                en_passant = cartesian_to_standard(x:x1,y:(y1+y2)/2)
                good = 1
            }
            else if abs(x1 - x2) == 1 && y2 - y1 == my_direction && cartesian_to_standard(x:x2,y:y2) == (self.en_passant ?? ""){
                //we have taken by en passant!?!?
                good = 1
                changed.append((x2,y1,"BLANK")) // taking the en-passant pawn.
            }
            
            //You moved the pawn to an invalid square.
            if good == 0{return nil}
            increment_hmc = false
        }
        
        //checks if it's in a line and blank
        if my_piecetype == "R" || my_piecetype == "B" || my_piecetype == "Q"{
            if !self.empty_line(x1:x1,y1:y1,x2:x2,y2:y2){
                return nil
            }
        }
        
        //check the line is going the right way
        if my_piecetype == "B"{
            if abs(x1-x2) == 0 || abs(y1-y2) == 0{
                return nil
            }
        }
        if my_piecetype == "R"{
            if x1-y1 == x2-y2 || x1+y1 == x2+y2{
                return nil
            }
            if my_color == "W"{
                if x1 == 0{cwqc = true}
                if x1 == 7{cwkc = true}
            }
            if my_color == "B"{
                if x1 == 0{cbqc = true}
                if x1 == 7{cbkc = true}
            }
        }
        
        //other pieces
        if my_piecetype == "N"{
            if abs(x1-x2)+abs(y1-y2) == 3{
                if abs(x1-x2) == 3 || abs(y1-y2) == 3{
                    return nil
                }
            }
            else{
                return nil
            }
        }
        if my_piecetype == "K"{
            
            if my_color == "W"{cwkc = false; cwqc = false}
            if my_color == "B"{cbkc = false; cbqc = false}
            
            if abs(x1-x2)+abs(y1-y2) > 2{
                return nil
            }
            if abs(x1-x2)+abs(y1-y2) == 2{
                if x1 == x2{
                    return nil
                }
                if y1 == y2{
                    var can_castle = false
                    
                    //check if we are in check right now
                    if self.color_in_check(color:String(my_color)){
                        return nil
                    }
                    
                    //check if there is something in the way?
                    if self.board[(x1+x2)/2][y1] != "BLANK"{
                        return nil
                    }
                    
                    //check if we are in check on the way?
                    let tboard = self.copy_board()
                    tboard.board[(x1+x2)/2][y1] = p
                    tboard.board[x1][y1] = "BLANK"
                    if tboard.color_in_check(color:String(my_color)){
                        return nil
                    }
                    
                    if (my_color == "W"){
                        if x2 > x1 && self.wkc!{
                            can_castle = true
                            changed.append((7,7,"BLANK"))
                            changed.append((5,7,"WR"))
                        }
                        if x2 < x1 && self.wqc!{
                            can_castle = true
                            changed.append((0,7,"BLANK"))
                            changed.append((3,7,"BLANK"))
                        }
                    }
                    if (my_color == "B"){
                        if x2 > x1 && self.bkc!{
                            can_castle = true
                            changed.append((7,0,"BLANK"))
                            changed.append((5,0,"BR"))
                        }
                        if x2 < x1 && self.wkc!{
                            can_castle = true
                            changed.append((0,0,"BLANK"))
                            changed.append((3,0,"BLANK"))
                        }
                    }
                    if can_castle == false{
                        return nil
                    }
                }
            }
        }
        
        if self.board[x2][y2] != "BLANK"{increment_hmc = false}
        
        //PROMOTION CODE HERE
        if did_promote{
            changed.append((x1,y1,"BLANK"))
            changed.append((x2,y2,String(my_color) + String("Q")))
        }
        else{
            changed.append((x1,y1,"BLANK"))
            changed.append((x2,y2,p))
        }
        
        let tboard = self.copy_board()
        for x in changed{
            tboard.board[x.0][x.1] = x.2
        }
        if tboard.color_in_check(color:String(my_color)){
            return nil
        }
        //increment full move clock
        if self.to_move == "b"{tboard.fmc = tboard.fmc! + 1}
        //set the en-passant
        tboard.en_passant = en_passant
        //increment half move clock
        if increment_hmc{tboard.hmc = tboard.hmc! + 1}
        //change to_move
        tboard.to_move = ((tboard.to_move == "w") ? "b" : "w")
        //change the castling rights
        if cwkc{tboard.wkc = false}
        if cwqc{tboard.wqc = false}
        if cbkc{tboard.bkc = false}
        if cbqc{tboard.bqc = false}
        
        //Now, we need to figure out the notation for the move.
        var to_return : String = ((p == "WP" || p == "BP") ? "" : String(p.last!))
        //let letters   = ["a","b","c","d","e","f","g","h"]
        to_return = to_return + ((p2 == "BLANK") ? "" : "x") + cartesian_to_standard(x:x2,y:y2)
        if (p.last! == "K") && (abs(x2-x1) == 2){
            if x2 > x1{to_return = "O-O"}
            else{to_return = "O-O-O"}
        }
        
        return (to_return,tboard)
    }
    
    //
    func find_move(move: String) -> (String,BoardState)?{
        //Given a move in algebraic notation, time to find it!
        //First, we have specials, castling:
        if move == "O-O"{
            if self.to_move == "w"{
                return self.move(x1: 4, y1: 7, x2:6, y2:7)
            }
            else{
                return self.move(x1: 4, y1: 7, x2:2, y2:7)
            }
        }
        if move == "O-O-O"{
            if self.to_move == "w"{
                return self.move(x1: 4, y1:0, x2:6,y2:0)
            }
            else{
                return self.move(x1:4,y1:0,x2:2,y2:0)
            }
        }
        
        let letters = ["a","b","c","d","e","f","g","h"]
        if let move_dict = read_move(standard: move){
            let matching_pieces = search_for_piece(p:self.to_move!.uppercased() + move_dict["piece"]!)
            for coordinate in matching_pieces{
                if move_dict["file1"]! != "" && letters[coordinate[0]] != move_dict["file1"] {continue}
                if move_dict["rank1"]! != "" && coordinate[1] != 8-Int(move_dict["rank1"]!)! {continue}
                if let good = self.move(x1:coordinate[0], y1:coordinate[1], x2: letters.firstIndex(of: move_dict["file2"]!)!, y2: 8-Int(move_dict["rank2"]!)!){
                    return good
                }
            }
        }
        
        return nil
    }
}

/*
 These are functions that aren't 'board specific'?
 */

//Convert a cartesian coordinate to standard letters
func cartesian_to_standard(x: Int, y:Int) -> String{
    let letters   = ["a","b","c","d","e","f","g","h"]
    return letters[x] + String(8-y)
}

//takes in a PGN, outputs a board_history, and a list of moves.
func import_PGN(PGN: String) -> ([BoardState],[String]){
    
    //https://www.chessclub.com/help/PGN-spec
    
    var board_history = [default_boardstate]
    var moves = [""]
    
    var  PGN_data = (PGN.split{$0.isNewline})
    PGN_data = PGN_data.filter{String($0) != ""}
    PGN_data = PGN_data.filter{String($0.first ?? Character("")) != "["}
    
    for line in PGN_data{
        //you gotta strip it of the comments, in {...}
        var temp_line = String(line)
        while let found_range = temp_line.range(of:#"\{.*?\}"#,options:.regularExpression){
            print("found a comment?", temp_line[found_range])
            temp_line.removeSubrange(found_range)
        }
        let move_list = temp_line.split{$0.isWhitespace}
        for move in move_list{
            let last_state = board_history.last
            if let new_state  = last_state!.find_move(move:String(move)){
                board_history.append(new_state.1)
                moves.append(new_state.0)
            }
        }
    }
    //For now, I want to ignore the metadata.
    
    return (board_history,moves)
}

//Some regex for reading moves
func read_move(standard: String) -> [String:String]?{
    //https://nshipster.com/swift-regular-expressions/
    //piece, file1, rank1, file2, rank2, promote
    var to_return : [String:String] = [:]
    
    let pattern = #"""
    (?x)
    (?<piece>[A-Z]?)
    (?<file1>[a-h]?)
    (?<rank1>[0-9]?)
    x?
    (?<file2>[a-h])
    (?<rank2>[0-9])
    =?
    (?<promote>[A-Z]?)
    """#

    let fields = ["piece","file1","rank1","file2","rank2","promote"]
    let regex = try! NSRegularExpression(pattern: pattern, options: [])
    let nsrange = NSRange(standard.startIndex..<standard.endIndex,in: standard)
    if let match = regex.firstMatch(in : standard, options: [], range: nsrange)
    {
        to_return = Dictionary(uniqueKeysWithValues: zip(fields, fields.map{String(standard[Range(match.range(withName:$0),in:standard)!])}))
        if to_return["piece"] == ""{to_return["piece"] = "P"}
        return to_return
    }
    return nil
}
