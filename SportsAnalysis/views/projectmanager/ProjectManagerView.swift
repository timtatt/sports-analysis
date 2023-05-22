//
//  ProjectManager.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 27/4/2023.
//

import SwiftUI

struct ProjectManagerView : View {
    @ObservedObject var playerState: PlayerState
    @ObservedObject var project: Project
    
    var body : some View {
        VSplitView {
            Widget(icon: "tag.fill", title: "Codes") {
                ProjectCodesView(project: project, playbackTime: $playerState.playbackTime)
            }
//            Widget(icon: "gear", title: "Project Settings") {
//                ProjectSettingsView(project: project)
//                    .tabItem {
//                        Label("Project Settings", systemImage: "tray.and.arrow.up.fill")
//                    }
//            }
        }
    }
}
