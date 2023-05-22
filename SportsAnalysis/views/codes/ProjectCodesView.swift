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
        VStack(spacing: 0) {
            ForEach(project.codes, id: \.id) { code in
                ProjectCodeItem(code: code, addEventHandler: {
                    addEvent(code: code)
                })
            }
        }
    }
    
    func addEvent(code: ProjectCode) {
        let event = ProjectEvent(code: code, timestamp: playbackTime)
        
        // TODO optimise this insert
        project.events[event.id] = event
        project.events.sort(by: { a, b in a.value.startTime < b.value.startTime })
    }
}

struct ProjectCodesView_Preview : PreviewProvider {
    static var previews: some View {
        let project = Project()
        ProjectCodesView(project: project, playbackTime: .constant(2))
    }
}
