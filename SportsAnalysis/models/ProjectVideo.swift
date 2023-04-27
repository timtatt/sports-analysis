//
//  ProjectVideo.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 27/4/2023.
//

import Foundation

class ProjectVideo : Codable {
    let filePath: String
    
    init(filePath: String) {
        self.filePath = filePath
    }
    
}
