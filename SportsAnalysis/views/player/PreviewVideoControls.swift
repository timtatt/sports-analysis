//
//  PreviewVideoControls.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 24/5/2023.
//

import Foundation
import SwiftUI

struct PreviewVideoControls : View {
    @ObservedObject var playerState: PlayerState
    
    var body : some View {
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
