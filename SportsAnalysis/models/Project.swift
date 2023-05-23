//
//  Project.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 27/4/2023.
//

import Foundation
import AVFoundation
import OrderedCollections

class Project: ObservableObject, Codable {
    @Published var name: String
    @Published var videos: [ProjectVideo]
    @Published var codes: [ProjectCode]
    @Published var events: OrderedDictionary<UUID, ProjectEvent>
    
    static let defaultCodes = [
        ProjectCode(name: "Inside 50 (SB)", colorName: "Red", shortcut: "a"),
        ProjectCode(name: "Inside 50 (OP)", colorName: "Orange", shortcut: "b"),
        ProjectCode(name: "Centre Bounce", colorName: "Yellow", shortcut: "c"),
        ProjectCode(name: "Stoppage", colorName: "Green", shortcut: "d"),
        ProjectCode(name: "Defensive Pressure", colorName: "Blue", shortcut: "e"),
        ProjectCode(name: "Goal (SB)", colorName: "Purple", shortcut: "f"),
        ProjectCode(name: "Goal (OP)", colorName: "Pink", shortcut: "g")
    ]
    
    
    init(name: String = "My New Project",
         videos: [ProjectVideo] = [],
         events: [ProjectEvent] = []) {
        self.name = name
        self.videos = videos
        self.events = OrderedDictionary(uniqueKeysWithValues: events.map({ ($0.id, $0) }))
        
        self.codes = Project.defaultCodes
    }
    
    enum CodingKeys: String, CodingKey {
        case name, videos, codes, events
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        videos = try values.decode([ProjectVideo].self, forKey: .videos)

        let projectCodes = try values.decode([UUID: ProjectCode].self, forKey: .codes)
        codes = Array(projectCodes.values)
        
        let eventsSerialised = try values.decode([ProjectEvent.Serialised].self, forKey: .events)
        let unknownCode = ProjectCode(name: "Unknown")
        var orphanEventNum: Int = 0
        events = OrderedDictionary(uniqueKeysWithValues: eventsSerialised
            .map({ serialisedEvent in
                var code = projectCodes[serialisedEvent.code]
                
                if (code == nil) {
                    code = unknownCode
                    orphanEventNum += 1
                }
                
                return (serialisedEvent.id, ProjectEvent(serialised: serialisedEvent, code: code!))
            }))
        
        if (orphanEventNum > 0) {
            codes.append(unknownCode)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(videos, forKey: .videos)
        
        let serialisedCodes: [UUID: ProjectCode] = Dictionary(uniqueKeysWithValues: codes.map({ ($0.id, $0) }))
        try container.encode(serialisedCodes, forKey: .codes)
        
        try container.encode(events.values.elements, forKey: .events)
    }
    
    func getVideoPlayerItem() async throws -> AVPlayerItem {
        let composition = AVMutableComposition()
    
        let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            
        do {
            let videos = ["M2U01222", "M2U01223"]
            
            for videoName in videos {
                logger.info("Loading video with name \(videoName)")
                
                let videoUrl = Bundle.main.url(forResource: videoName, withExtension: "MPG")!
                let asset = AVAsset(url: videoUrl)
                let assetDuration = try await asset.load(.duration)
                let assetVideoTrack = try await asset.loadTracks(withMediaType: .video).first!
                let assetAudioTrack = try await asset.loadTracks(withMediaType: .audio).first!
                
                try videoTrack!.insertTimeRange(
                    CMTimeRange(start: .zero, duration: assetDuration),
                    of: assetVideoTrack,
                    at: .zero)
                
                try audioTrack!.insertTimeRange(
                    CMTimeRange(start: .zero, duration: assetDuration),
                    of: assetAudioTrack,
                    at: .zero)
            }
        } catch {
            logger.error("Unable to load videos: \(error.localizedDescription)")
            throw error
        }
        
        return AVPlayerItem(asset: composition)
    }
}


extension ProjectEvent : Encodable {
    struct Serialised : Codable {
        var id: UUID
        var code: UUID
        var startTime: Float
        var endTime: Float
    }
    
    enum CodingKeys: String, CodingKey {
        case id, code, startTime, endTime
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.code.id, forKey: .code)
        try container.encode(self.startTime, forKey: .startTime)
        try container.encode(self.endTime, forKey: .endTime)
    }
    
    convenience init(serialised: Serialised, code: ProjectCode) {
        self.init(id: serialised.id, code: code, startTime: serialised.startTime, endTime: serialised.endTime)
    }
}
