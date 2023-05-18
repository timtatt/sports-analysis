//
//  ProjectVideo.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 27/4/2023.
//

import Foundation
import AVFoundation

struct ProjectVideo : Codable {
    var name: String
    let filePath: URL
    
    private enum CodingKeys: String, CodingKey {
        case name, filePath
    }
    
    init(name: String, filePath: URL) {
        self.filePath = filePath
        self.name = name
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        
        let absoluteFilePath = try values.decode(String.self, forKey: .filePath)
        filePath = URL(fileURLWithPath: absoluteFilePath)
    }
    
}
