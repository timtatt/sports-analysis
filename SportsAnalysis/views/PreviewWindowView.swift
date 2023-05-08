//
//  PreviewWindow.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 26/4/2023.
//

import SwiftUI
import AppKit
import AVKit
import Combine

class PlayerState : ObservableObject {
    @Published var isPlaying = false
    @Published var playbackTime: Float = 0.0
    @Published var playerItem: AVPlayerItem? = nil
    
    
    private var cancellables = Set<AnyCancellable>()
    private(set) var player: AVPlayer = AVPlayer()
    
    
    
    private var isScrubbing = false
    private var wasPlaying = false
    
    var duration: Float {
        get { Float(playerItem?.duration.seconds ?? 0) }
    }
    
    init() {
        player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 2), queue: .main) {
            [weak self] time in
            if (self?.player.timeControlStatus == .playing) {
                withAnimation(.linear(duration: 0.5)) {
                    self?.playbackTime = Float(time.seconds)
                }
            }
        }
        
        
        cancellables.insert($playerItem.sink { playerItem in
            self.player.replaceCurrentItem(with: playerItem)
        })
        
        cancellables.insert($playbackTime.sink { time in
            if (self.player.timeControlStatus == .paused) {
                self.seekPlayerOnly(seconds: time)
            }
        })
    }
    
    func seek(seconds: Float) {
        let wasPlaying = isPlaying
        player.pause()
        playbackTime = seconds
        seekPlayerOnly(seconds: seconds)
        
        if (wasPlaying) {
            player.play()
        }
    }
    
    func seekPlayerOnly(seconds: Float) {
        self.player.seek(to: CMTime(value: Int64(seconds * 1000), timescale: 1000),
                          toleranceBefore: CMTime.zero,
                          toleranceAfter: CMTime.zero)
    }
    
    func startScrubbing() {
        wasPlaying = isPlaying
        isPlaying = false
    }
    
    func stopScrubbing() {
        isPlaying = wasPlaying
        isScrubbing = false
    }
}


class PreviewWindowPlayerView : NSView {
    private let playerLayer = AVPlayerLayer()
    var player: AVPlayer?
        
    init(frame: CGRect, previewWindowPlayer: PreviewWindowPlayer) {
        super.init(frame: frame)
        
        self.wantsLayer = true
        
        player = previewWindowPlayer.playerState.player
        
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
        playerState.isPlaying ? nsView.player?.play() : nsView.player?.pause()
        
    }
    func makeNSView(context: Context) -> PreviewWindowPlayerView {
        
        let view = PreviewWindowPlayerView(frame: .zero, previewWindowPlayer: self)
        
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
                    isEditing ? playerState.startScrubbing() : playerState.stopScrubbing()
                }
            Text(TimeFormatter.toTimecode(seconds: playerState.playbackTime))
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
