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
    @Binding var playbackTime: Double
    
    var body : some View {
        VStack {
            Text("\(playbackTime)")
            ForEach(project.codes, id: \.self) { code in
                HStack {
                    Text(code.name)
                    Button("+") {
                        // add event to video
                        let event = ProjectEvent(code: code, timestamp: playbackTime)
                        print(event)
                        project.events.append(event)
                    }
                }
            }
        }
    }
}
