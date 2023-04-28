//
//  ContentView.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 26/4/2023.
//

import SwiftUI
import AVKit

struct ContentView: View {
    @StateObject var playerState = PlayerState()
    
    @StateObject var projectStore = ProjectStore()
    
    var body: some View {
        VStack {
            HStack {
                Button("Save Project") {
                    do {
                        try projectStore.save()
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                }
                Button("Load Project") {
                    do {
                        try projectStore.load()
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                }
                Text("modes for coding|analysis")
            }
            HStack {
                
                ProjectManagerView(playerState: playerState, project: projectStore.project)
                
                PreviewWindowView(playerState: playerState)
                    .frame(width: 720.0, height: 576.0)
                
                EventManager(project: projectStore.project)
                    .tabItem {
                        Label("Events", systemImage: "tray.and.arrow.up.fill")
                    }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
