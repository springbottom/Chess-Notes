//
//  ImportWindow.swift
//  Chess Notes
//
//  Created by Joshua Lin on 7/1/20.
//  Copyright © 2020 Joshua Lin. All rights reserved.
//

import SwiftUI

struct ImportWindow: View {
    
    @FetchRequest(entity:Note.entity(), sortDescriptors:[]) var stored_notes: FetchedResults<Note>
    @ObservedObject var backend: Backend
    @Environment(\.managedObjectContext) var moc
    var window: NSWindow?
    
    var body: some View {
        VStack{
            EditorTextView(text: self.$backend.iPGN)
            Button(action:{
                let history = import_PGN(PGN: self.backend.iPGN)
                self.backend.reset()
                self.backend.board_history = history.0
                self.backend.moves = history.1
                self.backend.game_length = self.backend.board_history.count
                
                for (index,boardState) in self.backend.board_history.enumerated(){
                    self.backend.stored_notes.append(self.stored_notes.first{$0.board_state == boardState.to_FEN(serialise:true)}?.note ?? "")
                }
                //NSApplication.keyWindow!.close()
                self.window!.close()
            }){
                Text("Import")
            }
        }.frame(width:400,height:300)
    }
}

//struct ImportWindow_Previews: PreviewProvider {
//    static var previews: some View {
//        ImportWindow()
//    }
//}
