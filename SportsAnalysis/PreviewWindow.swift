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
}


class PreviewWindowPlayerView : NSView {
    private let playerLayer = AVPlayerLayer()
    var player: AVPlayer?
    var playerState: PlayerState
    
    func seek(ms: Double) {
        self.player?.seek(to: CMTime(value: Int64(ms), timescale: 1000),
                          toleranceBefore: CMTime.zero,
                          toleranceAfter: CMTime.zero)
    }
    
        
    init(frame: CGRect, previewWindowPlayer: PreviewWindowPlayer, playerState: PlayerState) {
        self.playerState = playerState
        super.init(frame: frame)
        
        self.wantsLayer = true
        
        let testVideo = Bundle.main.url(forResource: "M2U01222", withExtension: "MPG")!
        
        player = AVPlayer(url: testVideo)
        
        player!.play()
        
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

struct PreviewWindow : View {
    
    @StateObject var playerState = PlayerState()
    
    
    var body : some View {
        
        return VStack {
            PreviewWindowPlayer(playerState: playerState)
            Button("Play/Pause") {
                playerState.isPlaying.toggle()
            }
            Slider(
                value: $playerState.playbackTime,
                in: 0...200) { isEditing in
                    print("editing changed")
                    print(isEditing)
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
        PreviewWindow()
            .frame(width: 720.0, height: 576.0)
    }
}
