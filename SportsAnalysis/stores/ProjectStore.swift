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
    static let LAST_PROJECT_PATH_KEY = "LastProjectPath"
    
    @Published var project: Project = Project()
    @Published var projectFilePath: URL? = nil
    
    func loadLastProject() {
        let lastProjectPath = UserDefaults.standard.string(forKey: ProjectStore.LAST_PROJECT_PATH_KEY)
        
        if (lastProjectPath != nil) {
            do {
                let lastProjectPathUrl = URL(fileURLWithPath: lastProjectPath!)
                print(lastProjectPathUrl)
                try load(filePath: lastProjectPathUrl)
            } catch {
                // TODO use proper logger
                print("Unable to load previous project")
                print(error)
            }
        }
    }
    
    func load() throws {
        let panel = NSOpenPanel()
        panel.title = "Open project file"
        panel.prompt = "Open Project"
        panel.message = "Choose an existing project to open"
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [UTType.json]
        
        let filePath = panel.runModal() == .OK ? panel.url : nil
        
        if (filePath != nil) {
            try load(filePath: filePath!)
        }
    }
    
    func setProjectPath(filePath: URL) {
        UserDefaults.standard.set(filePath.path, forKey: ProjectStore.LAST_PROJECT_PATH_KEY)
    }
    
    func load(filePath: URL) throws {
        let data = try Data(contentsOf: filePath)
        
        project = try JSONDecoder().decode(Project.self, from: data)
        
        setProjectPath(filePath: filePath)
    }

    func save() throws {
        var filePath = projectFilePath
        if (projectFilePath == nil) {
            let panel = NSSavePanel()
            panel.title = "Save project file"
            panel.prompt = "Save"
            panel.message = "Choose where to save your project file"
            panel.allowedContentTypes = [UTType.json]
            filePath = panel.runModal() == .OK ? panel.url : nil
            
            if (filePath == nil) {
                return;
            }
        }
        
        let data = try JSONEncoder().encode(project)
        try data.write(to: filePath!)
        
        setProjectPath(filePath: filePath!)
    }
}
