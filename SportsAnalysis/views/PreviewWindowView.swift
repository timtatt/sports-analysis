//
//  PreviewWindow.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 26/4/2023.
//

import SwiftUI
import AppKit
import AVKit

class PlayerState : ObservableObject {
    @Published var isPlaying = false
    @Published var wasPlaying = false
    @Published var playbackTime = 0.0
    @Published var isScrubbing = false
    @Published var duration = 0.0
}


class PreviewWindowPlayerView : NSView {
    private let playerLayer = AVPlayerLayer()
    var player: AVPlayer?
    var playerState: PlayerState
    let composition: AVMutableComposition
    
    private var playerItemContext = 0
    
    func seek(ms: Double) {
        self.player?.seek(to: CMTime(value: Int64(ms), timescale: 1000),
                          toleranceBefore: CMTime.zero,
                          toleranceAfter: CMTime.zero)
    }
    
        
    init(frame: CGRect, previewWindowPlayer: PreviewWindowPlayer, playerState: PlayerState) {
        self.playerState = playerState
        self.composition = AVMutableComposition()
        super.init(frame: frame)
        
        self.wantsLayer = true
        
        composition.naturalSize.width = 720
        composition.naturalSize.height = 576
        
        let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        
        player = AVPlayer()
        
        Task {
            await loadVideo(videoTrack: videoTrack!, audioTrack: audioTrack!)
        }
        
        player!.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 24), queue: .main) {
            [weak self] time in
            if (!self!.playerState.isScrubbing) {
                previewWindowPlayer.playerState.playbackTime = time.seconds
            }
        }
        
        playerLayer.player = player!
        
        playerLayer.backgroundColor = CGColor(red: 0, green: 0, blue: 1, alpha: 1)
        
        layer?.addSublayer(playerLayer)
        
        playerLayer.videoGravity = .resize
    }
    
    func loadVideo(videoTrack: AVMutableCompositionTrack, audioTrack: AVMutableCompositionTrack) async {
        
        do {
            let videos = ["M2U01222", "M2U01223"]
            for videoName in videos {
                print(videoName)
                let videoUrl = Bundle.main.url(forResource: videoName, withExtension: "MPG")!
                let asset = AVAsset(url: videoUrl)
                let assetDuration = try await asset.load(.duration)
                let assetVideoTrack = try await asset.loadTracks(withMediaType: .video).first!
                let assetAudioTrack = try await asset.loadTracks(withMediaType: .audio).first!
                
                try videoTrack.insertTimeRange(
                    CMTimeRange(start: .zero, duration: assetDuration),
                    of: assetVideoTrack,
                    at: .zero)
                
                try audioTrack.insertTimeRange(
                    CMTimeRange(start: .zero, duration: assetDuration),
                    of: assetAudioTrack,
                    at: .zero)
            }
        } catch {
            fatalError("Unable to load videos")
        }
        
        updateComposition()
    }
    
    func updateComposition() {
        let playerItem = AVPlayerItem(asset: composition)
        player?.replaceCurrentItem(with: playerItem)
        playerState.duration = playerItem.duration.seconds
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layout() {
        super.layout()
        playerLayer.frame = bounds
    }
}

struct PreviewWindowPlayer : NSViewRepresentable {
    @ObservedObject var playerState: PlayerState
        
    func updateNSView(_ nsView: PreviewWindowPlayerView, context: NSViewRepresentableContext<PreviewWindowPlayer>) {
        nsView.playerState = playerState
        
        playerState.isPlaying ? nsView.player?.play() : nsView.player?.pause()

        if (playerState.isScrubbing) {
            nsView.seek(ms: playerState.playbackTime * 1000)
        }
    }
    func makeNSView(context: Context) -> PreviewWindowPlayerView {
        let view = PreviewWindowPlayerView(frame: .zero, previewWindowPlayer: self, playerState: playerState)
        return view
    }
}

struct PreviewWindowView : View {
    
    @ObservedObject var playerState = PlayerState()
    
    var body : some View {
        
        return VStack {
            PreviewWindowPlayer(playerState: playerState)
            Button("Play/Pause") {
                playerState.isPlaying.toggle()
            }
            Slider(
                value: $playerState.playbackTime,
                in: 0...playerState.duration) { isEditing in
                    if (isEditing) {
                        playerState.wasPlaying = playerState.isPlaying
                        playerState.isPlaying = false
                    } else {
                        playerState.isPlaying = playerState.wasPlaying
                    }
                    playerState.isScrubbing = isEditing
                }
            Text("\(playerState.playbackTime)")
                .foregroundColor(.blue)
            
        }
    }
}

struct PreviewWindow_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWindowView()
            .frame(width: 720.0, height: 576.0)
    }
}
