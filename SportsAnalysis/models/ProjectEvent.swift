//
//  ProjectVideoEvent.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 28/4/2023.
//

import Foundation

class ProjectEvent : Identifiable, ObservableObject {
    
    var id: UUID
    var code: ProjectCode
    
    @Published var startTime: Float
    @Published var endTime: Float
    
    var duration: Float { endTime - startTime }
        
    static func == (lhs: ProjectEvent, rhs: ProjectEvent) -> Bool {
        return lhs.id == rhs.id
    }
    
    init(id: UUID = UUID(), code: ProjectCode, timestamp: Float) {
        self.id = id
        self.code = code
        self.startTime = max(timestamp - code.leadingTime, 0)
        self.endTime = timestamp + code.trailingTime
    }
    
    init(id: UUID = UUID(), code: ProjectCode, startTime: Float, endTime: Float) {
        self.id = id
        self.code = code
        self.startTime = startTime
        self.endTime = endTime
    }
}
