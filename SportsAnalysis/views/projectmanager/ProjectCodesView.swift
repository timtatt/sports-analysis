//
//  ProjectCodesView.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 28/4/2023.
//

import Foundation
import SwiftUI

struct ProjectCodesView : View {
    @ObservedObject var project: Project
    @Binding var playbackTime: Float
    
    // TODO add shortcuts to coding
    var body : some View {
        VStack {
            Text("\(playbackTime)")
            ForEach(project.codes, id: \.self) { code in
                HStack {
                    Circle()
                        .fill(code.color)
                        .frame(width: 20, height: 20)
                    Text(code.name)
                    Button("+") {
                        // add event to video
                        let event = ProjectEvent(code: code, timestamp: playbackTime)
                        
                        // TODO optimise this insert
                        project.events[event.id] = event
                        project.events.sort(by: { a, b in a.value.startTime < b.value.startTime })
                    }
                }
            }
        }
    }
}
