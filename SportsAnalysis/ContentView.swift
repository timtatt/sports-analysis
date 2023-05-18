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
                        // TODO convert this to an error popup
                        fatalError(error.localizedDescription)
                    }
                }
            }
            HSplitView {
                
                ProjectManagerView(playerState: playerState, project: projectStore.project)
                    .frame(minWidth: 300)
                
                VStack {
                    PreviewWindowView(playerState: playerState)
                        .frame(minWidth: 600, idealWidth: 720, maxWidth: .infinity)
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
                    
                    VideoTimeline(project: projectStore.project, playerState: playerState)
                        .frame(maxWidth: .infinity, maxHeight: 100)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .scaledToFit()
                
                EventManager(project: projectStore.project, playerState: playerState)
                    .frame(minWidth: 300)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .frame(height: 800)
    }
}
