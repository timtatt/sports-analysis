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
import CursorKit

class PlayerState : ObservableObject {
    @Published var isPlaying = false
    @Published var playbackTime: Float = 0.0
    @Published var playerItem: AVPlayerItem? = nil
    
    
    private var cancellables = Set<AnyCancellable>()
    private(set) var player: AVPlayer = AVPlayer()
    
    
    
    private(set) var isScrubbing = false
    private var wasPlaying = false
    
    var duration: Float {
        get { Float(playerItem?.duration.seconds ?? 0) }
    }
    
    var fps : Int {
        24
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
    
    func seek(frames: Int) {
        seek(seconds: playbackTime + Float(frames) / Float(fps))
    }
    
    func seekPlayerOnly(seconds: Float) {
        self.player.seek(to: CMTime(value: Int64(seconds * 1000), timescale: 1000),
                          toleranceBefore: CMTime.zero,
                          toleranceAfter: CMTime.zero)
    }
    
    func startScrubbing() {
        wasPlaying = isPlaying
        isPlaying = false
        isScrubbing = true
    }
    
    func stopScrubbing() {
        isPlaying = wasPlaying
        isScrubbing = false
    }
}


class PreviewWindowPlayerView : NSView {
    private let playerLayer = AVPlayerLayer()
    var player: AVPlayer?
    
    let parent: PreviewWindowPlayer;
    
    override var acceptsFirstResponder: Bool {
        true
    }
        
    init(frame: CGRect, previewWindowPlayer: PreviewWindowPlayer) {
        self.parent = previewWindowPlayer
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
    
    override func keyDown(with event: NSEvent) {
        let keyCodeCharacter = Character(event.characters!)
        let keyEquivalent = KeyEquivalent(keyCodeCharacter)
        
        switch (keyCodeCharacter) {
        case KeyEquivalent.leftArrow.character,
            KeyEquivalent.rightArrow.character:
            parent.keyDown(keyEquivalent)
        default:
            super.keyDown(with: event)
        }
    }
}

struct PreviewWindowPlayer : NSViewRepresentable {
    @ObservedObject var playerState: PlayerState
            
    func updateNSView(_ nsView: PreviewWindowPlayerView, context: NSViewRepresentableContext<PreviewWindowPlayer>) {
        playerState.isPlaying ? nsView.player?.play() : nsView.player?.pause()
        
    }
    func makeNSView(context: Context) -> PreviewWindowPlayerView {
        
        let view = PreviewWindowPlayerView(frame: .zero, previewWindowPlayer: self)
        
        view.window?.makeFirstResponder(view)
                
        return view
    }
    
    func keyDown(_ key: KeyEquivalent) {
        switch (key.character) {
        case KeyEquivalent.rightArrow.character:
            if (!playerState.isPlaying) {
                playerState.seek(frames: 1)
            }
        case KeyEquivalent.leftArrow.character:
            if (!playerState.isPlaying) {
                playerState.seek(frames: -1)
            }
        default:
            return
        }
    }
}

struct PreviewWindowView : View {
    
    @ObservedObject var playerState = PlayerState()
    
    // TODO add shortcuts for skipping, playing and pausing
    var body : some View {
        VStack {
            PreviewWindowPlayer(playerState: playerState)
                .aspectRatio(CGSize(width: 720, height: 576), contentMode: .fit)
                .frame(maxWidth: .infinity)
            HStack {
                Spacer().overlay(
                    Text(TimeFormatter.toTimecode(seconds: playerState.playbackTime))
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                )
                Group {
                    Button(action: {
                        playerState.playbackTime -= 5
                    }) {
                        Image(systemName: "gobackward.5")
                            .font(.system(size: 16))
                            .padding(8)
                            .background(Color("WidgetBackground"))
                            .clipShape(Circle())
                    }
                    .cursor(.pointingHand)
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        playerState.isPlaying.toggle()
                    }) {
                        Image(systemName: playerState.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 20))
                            .padding(15)
                            .background(Color("WidgetBackground"))
                            .clipShape(Circle())
                    }
                    .cursor(.pointingHand)
                    .buttonStyle(.plain)
                    .keyboardShortcut(.space, modifiers: [])
                    
                    
                    Button(action: {
                        playerState.playbackTime += 5
                    }) {
                        Image(systemName: "goforward.5")
                            .font(.system(size: 16))
                            .padding(8)
                            .background(Color("WidgetBackground"))
                            .clipShape(Circle())
                    }
                    .cursor(.pointingHand)
                    .buttonStyle(.plain)
                }
                .frame(alignment: .center)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct PreviewWindow_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWindowView()
            .frame(width: 720.0, height: 640.0, alignment: .top)
    }
}
