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
    @State var playerItem: AVPlayerItem? = nil
    
    var body: some View {
        VStack {
            HStack {
                Button("New Project") {
                    projectStore.newProject()
                }
                Button("Save Project") {
                    do {
                        try projectStore.save()
                    } catch {
                        print(error)
                        fatalError(error.localizedDescription)
                    }
                }
                Button("Load Project") {
                    do {
                        try projectStore.load()
                        Task {
                            playerItem = try await projectStore.project.getVideoPlayerItem()
                            playerState.playerItem = playerItem
                        }
                        
                    } catch {
                        print(error)
                        fatalError(error.localizedDescription)
                    }
                }
                Text("modes for coding|analysis")
            }
            HStack {
                
                ProjectManagerView(playerState: playerState, project: projectStore.project)
                
                VStack {
                    PreviewWindowView(playerState: playerState)
                        .frame(height: 576.0)
                        .task {
                            do {
                                projectStore.loadLastProject()
                                playerItem = try await projectStore.project.getVideoPlayerItem()
                                playerState.playerItem = playerItem
                            } catch {
                                print("Unable to load project")
                                print(error)
                            }
                        }
                    
                    VideoTimeline(events: projectStore.project.events, playerState: playerState)
                        .frame(maxWidth: .infinity)
                }
                .frame(width: 720)
                
                EventManager(project: projectStore.project, playerState: playerState)
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
