//
//  Project.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 27/4/2023.
//

import Foundation
import AVFoundation

class Project: ObservableObject, Codable {
    @Published var name: String
    @Published var videos: [ProjectVideo]
    @Published var codes: [ProjectCode]
    @Published var events: [ProjectEvent]
    
    init(name: String = "My New Project",
         videos: [ProjectVideo] = [],
         events: [ProjectEvent] = []) {
        self.name = name
        self.videos = videos
        self.events = events
        self.codes = [
            ProjectCode(name: "Inside 50 (SB)", shortcut: "A"),
            ProjectCode(name: "Inside 50 (OP)", shortcut: "B"),
            ProjectCode(name: "Centre Bounce", shortcut: "C"),
            ProjectCode(name: "Stoppage", shortcut: "C"),
            ProjectCode(name: "Defensive Pressure", shortcut: "C"),
            ProjectCode(name: "Goal (SB)", shortcut: "C"),
            ProjectCode(name: "Goal (OP)", shortcut: "C")
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
        events = try values.decode([ProjectEvent].self, forKey: .events)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(videos, forKey: .videos)
        try container.encode(codes, forKey: .codes)
        try container.encode(events, forKey: .events)
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
