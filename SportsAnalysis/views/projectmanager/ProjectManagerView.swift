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
        TabView {
            ProjectCodesView(project: project, playbackTime: $playerState.playbackTime)
                .tabItem {
                    Label("Codes", systemImage: "tray.and.arrow.up.fill")
                }
            ProjectSettingsView(project: project)
                .tabItem {
                    Label("Project Settings", systemImage: "tray.and.arrow.up.fill")
                }
        }
    }
}
