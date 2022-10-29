//
//  ContentView.swift
//  InRoomLogApp
//
//  Created by Katsuhiko Terada on 2022/10/27.
//

import SwiftUI
import InRoomLogger
import BwLogger

struct ContentView: View {
    @State var logger = Logger([InRoomLogger()])
    
    var body: some View {
        VStack {
            Button {
                logger.log(LogInformation("送信した！"))
            } label: {
                Text("送信")
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
