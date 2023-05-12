//
//  VideoTimeline.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 3/5/2023.
//

import Foundation
import SwiftUI
import OrderedCollections

struct VideoTimeline : View {
    
    var events: OrderedDictionary<UUID, ProjectEvent>
    
    @ObservedObject var playerState: PlayerState
    
    @State var scrollPosition: CGPoint = CGPoint(x: 0, y: 0)
    
    @State var pixelsPerSecond: Float = 12
    @State var isMouseOver: Bool = false
    
    var timelineWidth: CGFloat {
        CGFloat(playerState.duration * pixelsPerSecond)
    }
    
    func pixelsPerSecondScale(width: CGFloat) -> ClosedRange<Float> {
        let minPixelsPerSecond = Float(width) / playerState.duration
        
        return (minPixelsPerSecond > 24 ? 1 : minPixelsPerSecond)...24
    }
   
    
    var body : some View {
        GeometryReader { geometry in
            VStack {
                Slider(value: $pixelsPerSecond, in: pixelsPerSecondScale(width: geometry.size.width))
                ZStack {
                    GeometryReader { outerScrollGeometry in
                        TrackableScrollView(scrollPosition: $scrollPosition) {
                            ZStack(alignment: .bottomLeading) {
                                Color.red.ignoresSafeArea()
                                VStack(spacing: 0) {
                                    TimecodeBar(videoDuration: playerState.duration, pixelsPerSecond: pixelsPerSecond, scrollOffset: scrollPosition.x, timelineWrapperWidth: outerScrollGeometry.size.width)
                                    EventBar(videoDuration: playerState.duration, pixelsPerSecond: pixelsPerSecond, scrollOffset: scrollPosition.x, timelineWrapperWidth: outerScrollGeometry.size.width, events: events)
                                }
                                
                                // Scrubber
                                Rectangle()
                                    .fill(.yellow)
                                    .frame(width: 1)
                                    .offset(x: CGFloat(playerState.playbackTime * pixelsPerSecond), y: 0)
                            }
                            
                            .frame(width: timelineWidth, height: outerScrollGeometry.size.height)
                        }
                        .frame(width: outerScrollGeometry.size.width, height: outerScrollGeometry.size.height)
                    }
                }
                .frame(height: 66)
                TimelineScrollbar(overlayStart: $scrollPosition.x)
            }
        }
    }
}

struct VideoTimeline_Previews : PreviewProvider {
    static var previews: some View {
        let state = PlayerState()
        HStack {
            VideoTimeline(events: OrderedDictionary(), playerState: state)
        }
        .onAppear {
            state.playbackTime = 11.2
        }
        .frame(width: 900, height: 80)
        
    }
}
