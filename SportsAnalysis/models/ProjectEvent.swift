//
//  ProjectVideoEvent.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 28/4/2023.
//

import Foundation

struct ProjectEventSerialised : Decodable {
    var id: UUID
    var code: UUID
    var startTime: Float
    var endTime: Float
}

class ProjectEvent : Encodable, Identifiable, ObservableObject {
    
    var id: UUID
    
    var code: ProjectCode
    @Published var startTime: Float
    @Published var endTime: Float
    
    var duration: Float { endTime - startTime }
        
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
    
    init(serialised: ProjectEventSerialised, code: ProjectCode) {
        self.id = serialised.id
        self.code = code
        self.startTime = serialised.startTime
        self.endTime = serialised.endTime
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.code.id, forKey: .code)
        try container.encode(self.startTime, forKey: .startTime)
        try container.encode(self.endTime, forKey: .endTime)
    }

}
