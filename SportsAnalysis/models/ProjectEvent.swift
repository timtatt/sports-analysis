//
//  ProjectVideoEvent.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 28/4/2023.
//

import Foundation

// ProjectCodedEvent - an event with a start and end time to capture a small piece of the video
// ProjectMarker - a point in time to allow labelling of milestones

struct ProjectEventDecodeConfiguration {
    var codes: [UUID: ProjectCode]
    var unknownCode: ProjectCode
}

enum ProjectEventType : String, Codable {
    case marker, codedEvent, unknown
}

class DecodableProjectEvent : DecodableWithConfiguration {
    let data: ProjectEvent?
    
    enum CodingKeys : CodingKey {
        case type
    }
    
    required init(from decoder: Decoder, configuration: ProjectEventDecodeConfiguration) throws {
        
        let event = try decoder.container(keyedBy: CodingKeys.self)
        let eventType = (try? event.decode(ProjectEventType.self, forKey: .type)) ?? .codedEvent

        switch (eventType) {
        case .marker:
            data = try ProjectMarker(from: decoder, configuration: configuration)
        case .codedEvent:
            data = try ProjectCodedEvent(from: decoder, configuration: configuration)
        default:
            data = nil
        }
    }
}

class ProjectEvent : ObservableObject, Encodable, DecodableWithConfiguration, Identifiable, Equatable {
    
    var id: UUID
    @Published var startTime: Float
    
    var type: ProjectEventType {
        .unknown
    }
    
    static func == (lhs: ProjectEvent, rhs: ProjectEvent) -> Bool {
        lhs.id == rhs.id
    }
    
    enum CodingKeys : CodingKey {
        case id, startTime, type
    }
    
    init(id: UUID, startTime: Float) {
        self.id = id
        self.startTime = startTime
    }
    
    required init(from decoder: Decoder, configuration: ProjectEventDecodeConfiguration) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        startTime = try values.decode(Float.self, forKey: .startTime)
    }
    
        
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(type, forKey: .type)
    }
}

class ProjectMarker : ProjectEvent {
    var title: String
    override var type: ProjectEventType {
        .marker
    }
    
    enum CodingKeys : CodingKey {
        case id, title, startTime
    }
    
    init(id: UUID = UUID(), title: String, startTime: Float) {
        self.title = title
        super.init(id: id, startTime: startTime)
    }
        
    required init(from decoder: Decoder, configuration: ProjectEventDecodeConfiguration) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try values.decode(String.self, forKey: .title)
        try super.init(from: decoder, configuration: configuration)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try super.encode(to: encoder)
    }
}

class ProjectCodedEvent : ProjectEvent {
    
    var code: ProjectCode
    @Published var endTime: Float
    override var type: ProjectEventType {
        .codedEvent
    }
    
    var duration: Float { endTime - startTime }
    
    enum CodingKeys : CodingKey {
        case id, code, startTime, endTime
    }
    
    init(id: UUID = UUID(), code: ProjectCode, timestamp: Float) {
        self.code = code
        self.endTime = timestamp + code.trailingTime
        super.init(id: id, startTime: max(timestamp - code.leadingTime, 0))
    }
    
    init(id: UUID = UUID(), code: ProjectCode, startTime: Float, endTime: Float) {
        self.code = code
        self.endTime = endTime
        super.init(id: id, startTime: startTime)
    }
    
    required init(from decoder: Decoder, configuration: ProjectEventDecodeConfiguration) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
            
        let codeId = try values.decode(UUID.self, forKey: .code)
        code = configuration.codes[codeId] ?? configuration.unknownCode
        
        self.endTime = try values.decode(Float.self, forKey: .endTime)
        try super.init(from: decoder, configuration: configuration)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(code.id, forKey: .code)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(endTime, forKey: .endTime)
        try super.encode(to: encoder)
    }
}
