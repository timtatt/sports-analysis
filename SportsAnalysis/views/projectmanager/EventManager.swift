//
//  EventManager.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 27/4/2023.
//

import AppKit
import SwiftUI

struct EventManager : View {
    @State var events: [String] = []
    @ObservedObject var playerState: PlayerState
    
    var body : some View {
        VStack {
            ForEach(events, id: \.self) {
                event in Text(event)
            }
            Button("Create Event") {
                events.append(String(playerState.playbackTime))
            }
        }
    }
}


struct EventManager_Previews: PreviewProvider {
    static var previews: some View {
        EventManager(playerState: PlayerState())
    }
}
