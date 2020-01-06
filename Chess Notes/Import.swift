//
//  Import.swift
//  Chess Notes
//
//  Created by Joshua Lin on 5/1/20.
//  Copyright © 2020 Joshua Lin. All rights reserved.
//

import SwiftUI

struct Import: View {
    @State var text:String = "confused"
    var body: some View {
        TextField("Hmm", text : $text)
        //Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

//struct Import_Previews: PreviewProvider {
//    static var previews: some View {
//        Import()
//    }
//}
