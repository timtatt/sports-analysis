//
//  EventManager.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 27/4/2023.
//

import AppKit
import SwiftUI

struct EventManager : View {
    @ObservedObject var project : Project
    
    var body : some View {
        VStack {
            Text("Event Manager")
            ForEach(Array(project.events.enumerated()), id: \.offset) { index, event in
                HStack {
                    Text("\(event.startTime): \(event.code.name)")
                    Button("x") {
                        project.events.remove(at: index)
                    }
                }
            }
        }
    }
}


struct EventManager_Previews: PreviewProvider {
    static var previews: some View {
        EventManager(project: Project())
    }
}
