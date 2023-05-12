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
    
    
    init(name: String = "My New Project",
         videos: [ProjectVideo] = [],
         events: [ProjectEvent] = []) {
        self.name = name
        self.videos = videos
        self.events = OrderedDictionary(uniqueKeysWithValues: events.map({ ($0.id, $0) }))
        
        self.codes = [
            ProjectCode(name: "Inside 50 (SB)", color: ProjectCodeColor(.red), shortcut: "A"),
            ProjectCode(name: "Inside 50 (OP)", color: ProjectCodeColor(.orange), shortcut: "B"),
            ProjectCode(name: "Centre Bounce", color: ProjectCodeColor(.yellow), shortcut: "C"),
            ProjectCode(name: "Stoppage", color: ProjectCodeColor(.green), shortcut: "C"),
            ProjectCode(name: "Defensive Pressure", color: ProjectCodeColor(.blue), shortcut: "C"),
            ProjectCode(name: "Goal (SB)", color: ProjectCodeColor(.purple), shortcut: "C"),
            ProjectCode(name: "Goal (OP)", color: ProjectCodeColor(.systemPink), shortcut: "C")
        ]
    }
    
    enum CodingKeys: String, CodingKey {
        case name, videos, codes, events
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        videos = try values.decode([ProjectVideo].self, forKey: .videos)
        codes = try values.decode([ProjectCode].self, forKey: .codes)
        
        let events = try values.decode([ProjectEvent].self, forKey: .events)
        self.events = OrderedDictionary(uniqueKeysWithValues: events.map({ ($0.id, $0) }))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(videos, forKey: .videos)
        try container.encode(codes, forKey: .codes)
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
