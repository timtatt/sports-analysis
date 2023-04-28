//
//  ProjectVideoEvent.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 28/4/2023.
//

import Foundation

struct ProjectEvent : Codable, Hashable {
    var code: ProjectCode
    var startTime: Double
    var endTime: Double
    
    var duration: Double {
        get {
            return endTime - startTime
        }
    }
    
    init(code: ProjectCode, timestamp: Double) {
        self.code = code
        self.startTime = max(timestamp - code.leadingTime, 0)
        self.endTime = timestamp + code.trailingTime
    }
    
    init(code: ProjectCode, startTime: Double, endTime: Double) {
        self.code = code
        self.startTime = startTime
        self.endTime = endTime
    }
}
