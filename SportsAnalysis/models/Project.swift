//
//  Project.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 27/4/2023.
//

import Foundation

class Project: ObservableObject, Codable {
    var name: String
    var videos: [ProjectVideo]
    
    init(name: String = "My New Project", videos: [ProjectVideo] = []) {
        self.name = name
        self.videos = videos
    }
    
}
