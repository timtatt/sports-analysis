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

struct PreviewWindowView : View {
    
    @ObservedObject var playerState = PlayerState()
    
    // TODO add shortcuts for skipping
    var body : some View {
        VStack {
            PreviewVideoPlayer(playerState: playerState)
                .aspectRatio(CGSize(width: 720, height: 576), contentMode: .fit)
                .frame(maxWidth: .infinity)
            PreviewVideoControls(playerState: playerState)
        }
    }
}

struct PreviewWindow_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWindowView()
            .frame(width: 720.0, height: 640.0, alignment: .top)
    }
}
