//
//  Chess_backend.swift
//  Joshua Lin
//
//  Created by Joshua Lin on 24/12/19.
//  Copyright © 2019 Joshua Lin. All rights reserved.
//

import Foundation

/*
 So a game-state is determined by the pieces on the board, but also by the fact
 whether or not black/white can castle king/queen side.
 I think for the purpose of this annotation software, we can ignore the following rules:
  - 3 state repetition is draw,
  - 50 moves without moving a pawn or capturing a piece
 */

class BoardState{
    var board : [[String]]
    var wkc,wqc,bkc,bqc : Bool //white/black king/queenside castling
    
    init(board : [[String]],
         wkc : Bool, wqc : Bool,
         bkc : Bool, bqc : Bool){
        self.board = board
        self.wkc = wkc; self.wqc = wqc
        self.bkc = bkc; self.bqc = bqc
    }
    
    //copy a board?! this returns a ccopy of the CLASS...
    func copy_board() -> BoardState{
        //var to_return = [[String]](repeating: [String](repeating:"",count:8), count:8)
        //for x in 0...7{
        //    for y in 0...7{
        //        to_return[x][y] = self.board[x][y]
        //    }
        //}
        return BoardState(board:self.board,
                          wkc:self.wkc,wqc:self.wqc,
                          bkc:self.bkc,bqc:self.bqc)//to_return
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
        let enemy_direction = (color == "W") ? -1 : 1
        
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
    
    //checks if move is legal
    func legal(x1: Int, y1: Int, x2: Int, y2:Int) -> Bool {
        //Very naive legal move checking. So what we can do is
        //first check whether the move is able to be made by the piece being moved
        
        let p = self.board[x1][y1]
        
        if p == "BLANK"{
            return false
        }
        
        let my_color = p[p.startIndex]
        let my_piecetype = p[p.index(before : p.endIndex)]
        let my_direction = (my_color == "W") ? -1 : 1
        
        if self.board[x2][y2][self.board[x2][y2].startIndex] == my_color && self.board[x2][y2] != "BLANK"{
            return false
        }
        
        if x1 == x2 && y1 == y2{
            return false
        }
        if my_piecetype == "P"{
            var good = 0
            if x1 == x2 && y2 - y1 == my_direction && self.board[x2][y2] == "BLANK"{
                good = 1
            }
            if abs(x1 - x2) == 1 && y2 - y1 == my_direction && self.board[x2][y2] != "BLANK"{
                good = 1
            }
            if x1 == x2 && y2 - y1 == my_direction*2 && board[x1][y1+my_direction] == "BLANK" &&
                board[x1][y2] == "BLANK" && y1 == (7 - 5*my_direction)/2{
                good = 1
            }
            //EN PASSANT,
            if good == 0{
                return false
            }
        }
        
        //checks if it's in a line and blank
        if my_piecetype == "R" || my_piecetype == "B" || my_piecetype == "Q"{
            print("check blank line")
            if !self.empty_line(x1:x1,y1:y1,x2:x2,y2:y2){
                return false
            }
        }
        
        //check the line is going the right way
        if my_piecetype == "B"{
            if abs(x1-x2) == 0 || abs(y1-y2) == 0{
                return false
            }
        }
        if my_piecetype == "R"{
            if x1-y1 == x2-y2 || x1+y1 == x2+y2{
                return false
            }
        }
        
        //other pieces
        if my_piecetype == "N"{
            if abs(x1-x2)+abs(y1-y2) == 3{
                if abs(x1-x2) == 3 || abs(y1-y2) == 3{
                    return false
                }
            }
            else{
                return false
            }
        }
        if my_piecetype == "K"{
            if abs(x1-x2)+abs(y1-y2) > 2{
                return false
            }
            if abs(x1-x2)+abs(y1-y2) == 2{
                if x1 == x2{
                    return false
                }
                if y1 == y2{
                    var can_castle = false
                    
                    //check if we are in check right now
                    if self.color_in_check(color:String(my_color)){
                        return false
                    }
                    
                    //check if there is something in the way?
                    if self.board[(x1+x2)/2][y1] != "BLANK"{
                        return false
                    }
                    
                    //check if we are in check on the way?
                    let tboard = self.copy_board()
                    tboard.board[(x1+x2)/2][y1] = p
                    tboard.board[x1][y1] = "BLANK"
                    if tboard.color_in_check(color:String(my_color)){
                        return false
                    }
                    
                    if (my_color == "W"){
                        if x2 > x1 && self.wkc{
                            can_castle = true
                        }
                        if x2 < x1 && self.wqc{
                            can_castle = true
                        }
                    }
                    if (my_color == "B"){
                        if x2 > x1 && self.bkc{
                            can_castle = true
                        }
                        if x2 < x1 && self.wkc{
                            can_castle = true
                        }
                    }
                    if can_castle == false{
                        return false
                    }
                    //return false
                }
            }
        }
        
        let tboard = self.copy_board()
        tboard.board[x1][y1] = "BLANK"
        tboard.board[x2][y2] = p
        if tboard.color_in_check(color:String(my_color)){
            return false
        }
        
        return true
    }
}

/*
 These are functions that aren't 'board specific'?
 */

////Convert to standard notation
//func cartesian_to_standard (x1: Int, y1: Int, x2: Int, y2:Int, p1:String, p2:String) -> String{
//    var to_return : String = ((p1 == "WP" || p1 == "BP") ? "" : String(p1.last!))
//    let letters   = ["a","b","c","d","e","f","g","h"]
//    //let r_letters = ["h","g","f","e","d","c","b","a"]
//
//    to_return = to_return + ((p2 == "BLANK") ? "" : "x") + letters[x2] + String(8-y2)
//
//    if (p1.last! == "K") && (abs(x2-x1) == 2){
//        if x2 > x1{
//            return "O-O"
//        }
//        else{
//            return "O-O-O"
//        }
//    }
//
//    return to_return
//}
//
///*
// Board-specific functions belong to the class in reality?
// */
////copy a board?!
//func copy_board(board:[[String]]) -> [[String]]{
//    var to_return = [[String]](repeating: [String](repeating:"",count:8), count:8)
//    //var to_return = [[String]]()
//    for x in 0...7{
//        //to_return.append([])
//        for y in 0...7{
//            to_return[x][y] = board[x][y]
//            //to_return.last.append(board[x][y])
//        }
//    }
//    return to_return
//}
//
////searches the board for all indices that match.
//func search_for_piece(board:[[String]],p:String) -> [[Int]]{
//    var to_return = [[Int]]()
//    for x in 0...7{
//        for y in 0...7{
//            if (board[x][y] == p){
//                to_return.append([x,y])
//            }
//        }
//    }
//    return to_return
//}
//
////check if a color is in check
//func color_in_check(board:[[String]], color:String) -> Bool{
//    let king_loc = search_for_piece(board:board,p:color+"K")[0]
//    let enemy_color = (color == "W") ? "B" : "W"
//    let enemy_direction = (color == "W") ? -1 : 1
//
//    var attackers = search_for_piece(board:board,p:enemy_color+"P")
//    for a in attackers{
//        if king_loc[1] == a[1]+enemy_direction && abs(king_loc[0]-a[0]) == 1{
//            return true
//        }
//    }
//
//    attackers = search_for_piece(board:board,p:enemy_color+"R")
//    for a in attackers{
//        if a[0]+a[1] == king_loc[0]+king_loc[1] || a[0]-a[1] == king_loc[0]-king_loc[1]{
//            continue
//        }
//        if empty_line(board:board,x1:king_loc[0],y1:king_loc[1],x2:a[0],y2:a[1]){
//            return true
//        }
//    }
//
//    attackers = search_for_piece(board:board,p:enemy_color+"N")
//    for a in attackers{
//        if abs(a[0]-king_loc[0]) == 1 && abs(a[1]-king_loc[1]) == 2{
//            return true
//        }
//        else if abs(a[0]-king_loc[0]) == 2 && abs(a[1]-king_loc[1]) == 1{
//            return true
//        }
//    }
//
//    attackers = search_for_piece(board:board,p:enemy_color+"B")
//    for a in attackers{
//        if a[0] == king_loc[0] || a[1] == king_loc[1]{
//            continue
//        }
//        if empty_line(board:board,x1:king_loc[0],y1:king_loc[1],x2:a[0],y2:a[1]){
//            return true
//        }
//    }
//
//    attackers = search_for_piece(board:board,p:enemy_color+"Q")
//    for a in attackers{
//        if empty_line(board:board,x1:king_loc[0],y1:king_loc[1],x2:a[0],y2:a[1]){
//            return true
//        }
//    }
//
//    attackers = search_for_piece(board:board,p:enemy_color+"K")
//    for a in attackers{
//        if abs(a[0]-king_loc[0])+abs(a[1]-king_loc[1]) == 1{
//            return true
//        }
//        if abs(a[0]-king_loc[0])+abs(a[1]-king_loc[1]) == 2{
//            if a[0] != king_loc[0] || a[1] == king_loc[1]{
//                return true
//            }
//        }
//
//    }
//
//    return false
//}
//
////Color-neutral in_check check.
//func in_check(board:[[String]]) -> Bool {
//    if color_in_check(board:board,color:"W") || color_in_check(board:board,color:"B"){
//        return true
//    }
//    return false
//}
//
////returns true if the two points are in a straight line, and nothing inbetween
//func empty_line(board:[[String]],x1: Int, y1: Int, x2: Int, y2:Int) -> Bool{
//    //print("checking blank line",x1,y1,x2,y2)
//    if x1 == x2{
//        print("equal x")
//        if abs(y1-y2) == 1{
//            return true
//        }
//        return !(min(y1,y2)+1...max(y1,y2)-1).map({board[x1][$0] != "BLANK"}).contains(true)
//    }
//    if y1 == y2{
//        print("equal y")
//        if abs(x1-x2) == 1{
//            return true
//        }
//        return !(min(x1,x2)+1...max(x1,x2)-1).map({board[$0][y1] != "BLANK"}).contains(true)
//    }
//    if x1-x2 == y1-y2{
//        print("minus B",x1,y1)
//        if abs(x1-x2) == 1{
//            return true
//        }
//        return !(1...max(x1,x2)-min(x1,x2)-1).map({board[min(x1,x2)+$0][min(y1,y2)+$0] != "BLANK"}).contains(true)
//    }
//    if x1+y1 == x2+y2{
//        print("add B",x1,y1)
//        if abs(x1-x2) == 1{
//            return true
//        }
//        return !(1...max(x1,x2)-min(x1,x2)-1).map({board[min(x1,x2)+$0][max(y1,y2)-$0] != "BLANK"}).contains(true)
//    }
//    //print("no hooks")
//    return false
//}
//
////checks if move is legal
//func legal(board:[[String]], x1: Int, y1: Int, x2: Int, y2:Int) -> Bool {
//    //Very naive legal move checking. So what we can do is
//    //first check whether the move is able to be made by the piece being moved
//
//    let p = board[x1][y1]
//
//    if p == "BLANK"{
//        return false
//    }
//
//    let my_color = p[p.startIndex]
//    let my_piecetype = p[p.index(before : p.endIndex)]
//    let my_direction = (my_color == "W") ? -1 : 1
//
//    if board[x2][y2][board[x2][y2].startIndex] == my_color && board[x2][y2] != "BLANK"{
//        return false
//    }
//
//    if x1 == x2 && y1 == y2{
//        return false
//    }
//    if my_piecetype == "P"{
//        var good = 0
//        if x1 == x2 && y2 - y1 == my_direction && board[x2][y2] == "BLANK"{
//            good = 1
//        }
//        if abs(x1 - x2) == 1 && y2 - y1 == my_direction && board[x2][y2] != "BLANK"{
//            good = 1
//        }
//        if x1 == x2 && y2 - y1 == my_direction*2 && board[x1][y1+my_direction] == "BLANK" &&
//            board[x1][y2] == "BLANK" && y1 == (7 - 5*my_direction)/2{
//            good = 1
//        }
//        //EN PASSANT,
//        if good == 0{
//            return false
//        }
//    }
//
//    //checks if it's in a line and blank
//    if my_piecetype == "R" || my_piecetype == "B" || my_piecetype == "Q"{
//        print("check blank line")
//        if !empty_line(board:board,x1:x1,y1:y1,x2:x2,y2:y2){
//            return false
//        }
//    }
//
//    //check the line is going the right way
//    if my_piecetype == "B"{
//        if abs(x1-x2) == 0 || abs(y1-y2) == 0{
//            return false
//        }
//    }
//    if my_piecetype == "R"{
//        if x1-y1 == x2-y2 || x1+y1 == x2+y2{
//            return false
//        }
//    }
//
//    //other pieces
//    if my_piecetype == "N"{
//        if abs(x1-x2)+abs(y1-y2) == 3{
//            if abs(x1-x2) == 3 || abs(y1-y2) == 3{
//                return false
//            }
//        }
//        else{
//            return false
//        }
//    }
//    if my_piecetype == "K"{
//        if abs(x1-x2)+abs(y1-y2) > 2{
//            return false
//        }
//        if abs(x1-x2)+abs(y1-y2) == 2{
//            if x1 == x2{
//                return false
//            }
//            if y1 == y2{
//                //no castling yet
//                return false
//            }
//        }
//    }
//
//    var tboard = copy_board(board:board)
//    tboard[x1][y1] = "BLANK"
//    tboard[x2][y2] = p
//    if color_in_check(board:tboard,color:String(my_color)){
//        return false
//    }
//
//    return true
//}

