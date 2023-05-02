//
//  ProjectVideoEvent.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 28/4/2023.
//

import Foundation

class ProjectEvent : Codable, Identifiable, ObservableObject {
    
    var id: UUID
    
    var code: ProjectCode
    var startTime: Float
    var endTime: Float
    
    var duration: Float {
        get {
            return endTime - startTime
        }
    }
    
    static func == (lhs: ProjectEvent, rhs: ProjectEvent) -> Bool {
        return lhs.id == rhs.id
    }
    
    enum CodingKeys: String, CodingKey {
        case code, startTime, endTime
    }
    
    init(code: ProjectCode, timestamp: Float) {
        self.id = UUID()
        self.code = code
        self.startTime = max(timestamp - code.leadingTime, 0)
        self.endTime = timestamp + code.trailingTime
    }
    
    init(code: ProjectCode, startTime: Float, endTime: Float) {
        self.id = UUID()
        self.code = code
        self.startTime = startTime
        self.endTime = endTime
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.code = try container.decode(ProjectCode.self, forKey: .code)
        self.startTime = try container.decode(Float.self, forKey: .startTime)
        self.endTime = try container.decode(Float.self, forKey: .endTime)
    }

}
