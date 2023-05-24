//
//  PreviewVideoPlayer.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 24/5/2023.
//

import Foundation
import AppKit
import SwiftUI
import AVFoundation

class NSPreviewVideoPlayer : NSView {
    private let playerLayer = AVPlayerLayer()
    var player: AVPlayer?
    
    let parent: PreviewVideoPlayer;
    
    override var acceptsFirstResponder: Bool {
        true
    }
        
    init(frame: CGRect, previewWindowPlayer: PreviewVideoPlayer) {
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

struct PreviewVideoPlayer : NSViewRepresentable {
    @ObservedObject var playerState: PlayerState
            
    func updateNSView(_ nsView: NSPreviewVideoPlayer, context: NSViewRepresentableContext<PreviewVideoPlayer>) {
        playerState.isPlaying ? nsView.player?.play() : nsView.player?.pause()
        
    }
    func makeNSView(context: Context) -> NSPreviewVideoPlayer {
        
        let view = NSPreviewVideoPlayer(frame: .zero, previewWindowPlayer: self)
        
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
