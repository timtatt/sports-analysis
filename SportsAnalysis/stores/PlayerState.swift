//
//  PlayerState.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 24/5/2023.
//

import Foundation
import AVFoundation
import Combine
import SwiftUI

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
                // TODO with animation not working :(
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
