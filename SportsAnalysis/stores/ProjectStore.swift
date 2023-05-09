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
    static let LAST_PROJECT_PATH_KEY = "lastProjectBookmark"
    
    @Published var project: Project = Project()
    @Published var projectFilePath: URL? = nil
    
    func newProject() {
        project = Project()
        projectFilePath = nil
    }
    
    func loadLastProject() {
        let lastProjectBookmark = UserDefaults.standard.data(forKey: ProjectStore.LAST_PROJECT_PATH_KEY)
        
        if (lastProjectBookmark != nil) {
            do {
                logger.info("Attempting to load project bookmark")
                
                var isStale = false
                let lastProject = try URL(resolvingBookmarkData: lastProjectBookmark!, options: .withoutUI, relativeTo: nil, bookmarkDataIsStale: &isStale)
                
                if (isStale) {
                    logger.warning("Last project data is stale, not loading the project")
                    return;
                }

                try load(filePath: lastProject)
                
                logger.info("Successfully loaded previous project")
            } catch {
                logger.warning("Unable to load previous project")
                print(error)
            }
        } else {
            logger.info("No previous project to load")
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
            
            saveProjectBookmark(filePath: filePath!)
        }
    }
    
    func saveProjectBookmark(filePath: URL) {
        do {
            let bookmark = try filePath.bookmarkData()
            UserDefaults.standard.set(bookmark, forKey: ProjectStore.LAST_PROJECT_PATH_KEY)
        } catch {
            logger.warning("Unable to save project as bookmark")
            print(error)
        }
    }
    
    func load(filePath: URL) throws {
        let data = try Data(contentsOf: filePath)
        
        let project = try JSONDecoder().decode(Project.self, from: data)
        
        self.project = project
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
        
        saveProjectBookmark(filePath: filePath!)
    }
}
