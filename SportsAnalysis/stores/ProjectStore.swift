//
//  ProjectStore.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 27/4/2023.
//

import Foundation
import AppKit
import UniformTypeIdentifiers

class ProjectStore : ObservableObject {
    @Published var project: Project = Project()
    @Published var projectFilePath: URL? = nil
    
//    func load() async throws {
//            let task = Task<[DailyScrum], Error> {
//                let fileURL = try Self.fileURL()
//                guard let data = try? Data(contentsOf: fileURL) else {
//                    return []
//                }
//                let dailyScrums = try JSONDecoder().decode([DailyScrum].self, from: data)
//                return dailyScrums
//            }
//            let scrums = try await task.value
//            self.scrums = scrums
//        }
    
    
    func load() throws {
        let panel = NSOpenPanel()
        panel.title = "Open project file"
        panel.prompt = "Open Project"
        panel.message = "Choose an existing project to open"
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [UTType.json]
        
        projectFilePath = panel.runModal() == .OK ? panel.url : nil
        
        if (projectFilePath == nil) {
            return;
        }
        
        let data = try Data(contentsOf: projectFilePath!)
        
        project = try JSONDecoder().decode(Project.self, from: data)
    }

    func save() throws {
        if (projectFilePath == nil) {
            let panel = NSSavePanel()
            panel.title = "Save project file"
            panel.prompt = "Save"
            panel.message = "Choose where to save your project file"
            panel.allowedContentTypes = [UTType.json]
            projectFilePath = panel.runModal() == .OK ? panel.url : nil
            
            if (projectFilePath == nil) {
                return;
            }
        }
        
        let data = try JSONEncoder().encode(project)
        try data.write(to: projectFilePath!)
    }
}
