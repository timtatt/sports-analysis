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
    // TODO set playbackTime precision to Float
    @Binding var playbackTime: Float
    
    var body : some View {
        VStack {
            Text("\(playbackTime)")
            ForEach(project.codes, id: \.self) { code in
                HStack {
                    Text(code.name)
                    Button("+") {
                        // add event to video
                        let event = ProjectEvent(code: code, timestamp: playbackTime)
                        
                        // TODO optimise this insert
                        project.events.append(event)
                        project.events.sort(by: { a, b in a.startTime > b.startTime })
                    }
                }
            }
        }
    }
}
