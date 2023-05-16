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
    
    let maxPixelsPerSecond: Float = 24
    
    @GestureState var magnifyBy = 1.0
    @State var isZooming: Bool = false
    @State var startingPixelsPerSecond: Float = 0
   
    
    var body : some View {
        GeometryReader { geometry in
            var minPixelsPerSecond : CGFloat {
                geometry.size.width / CGFloat(playerState.duration)
            }
            
            VStack {
                var pixelsPerSecondScale: ClosedRange<Float> {
                    let minPixelsPerSecond = Float(minPixelsPerSecond)
                    
                    return (minPixelsPerSecond > 24 ? 1 : minPixelsPerSecond)...maxPixelsPerSecond
                }

                ZStack {
                    GeometryReader { outerScrollGeometry in
                        TrackableScrollView(scrollPosition: $scrollPosition) {
                            ZStack(alignment: .bottomLeading) {
                                Color.red.ignoresSafeArea()
                                VStack(spacing: 0) {
                                    TimecodeBar(
                                        videoDuration: playerState.duration,
                                        pixelsPerSecond: pixelsPerSecond,
                                        scrollOffset: scrollPosition.x,
                                        timelineWrapperWidth: outerScrollGeometry.size.width)
                                    
                                    EventBar(
                                        videoDuration: playerState.duration,
                                        pixelsPerSecond: pixelsPerSecond,
                                        scrollOffset: scrollPosition.x,
                                        timelineWrapperWidth: outerScrollGeometry.size.width,
                                        events: events)
                                }
                                
                                // Scrubber
                                Rectangle()
                                    .fill(.yellow)
                                    .frame(width: 1)
                                    .offset(x: CGFloat(playerState.playbackTime * pixelsPerSecond), y: 0)
                            }
                            .gesture(MagnificationGesture()
                                .onChanged { scale in
                                    if (!isZooming) {
                                        isZooming = true
                                        startingPixelsPerSecond = pixelsPerSecond
                                    }
                                    pixelsPerSecond = BoundsChecker.minmax(minBound: Float(minPixelsPerSecond), value: startingPixelsPerSecond * Float(scale.magnitude), maxBound: maxPixelsPerSecond)
                                }
                                .onEnded { _ in isZooming = false }
                            )
                            .frame(width: timelineWidth, height: outerScrollGeometry.size.height)
                        }
                        .frame(width: outerScrollGeometry.size.width, height: outerScrollGeometry.size.height)
                    }
                }
                .frame(height: 66)
                TimelineScrollbar(
                    scrollPosition: $scrollPosition.x,
                    pixelsPerSecond: $pixelsPerSecond,
                    maxPixelsPerSecond: CGFloat(maxPixelsPerSecond),
                    minPixelsPerSecond: minPixelsPerSecond
                )
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
