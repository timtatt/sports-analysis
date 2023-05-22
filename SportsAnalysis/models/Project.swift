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
        let projectCodes = try values.decode(Dictionary<UUID, ProjectCode>.self, forKey: .codes)
        
        codes = Project.defaultCodes
        
        let eventsSerialised = try values.decode([ProjectEventSerialised].self, forKey: .events)
        
        self.events = OrderedDictionary(uniqueKeysWithValues: eventsSerialised
            .filter({ projectCodes[$0.id] != nil })
            .map({
                ($0.id, ProjectEvent(serialised: $0, code: projectCodes[$0.code]!))
            }))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(videos, forKey: .videos)
        try container.encode(Dictionary(uniqueKeysWithValues: codes.map({ ($0.id, $0) })), forKey: .codes)
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
