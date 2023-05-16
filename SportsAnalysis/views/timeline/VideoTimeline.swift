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
    
    @State var zoomLevel: Float = 12
    
    var timelineWidth: CGFloat {
        CGFloat(playerState.duration * zoomLevel)
    }
    
    let maxZoomLevel: Float = 18
    @State var isZooming: Bool = false
    @State var startingZoomLevel: Float = 0
   
    
    var body : some View {
        GeometryReader { geometry in
            var minZoomLevel : CGFloat {
                geometry.size.width / CGFloat(playerState.duration)
            }
            
            VStack {
                var zoomLevelScale: ClosedRange<Float> {
                    let minZoomLevel = Float(minZoomLevel)
                    
                    return (minZoomLevel > 24 ? 1 : minZoomLevel)...maxZoomLevel
                }

                ZStack {
                    GeometryReader { outerScrollGeometry in
                        TrackableScrollView(scrollPosition: $scrollPosition) {
                            ZStack(alignment: .bottomLeading) {
                                Color.red.ignoresSafeArea()
                                VStack(spacing: 0) {
                                    TimecodeBar(
                                        videoDuration: playerState.duration,
                                        zoomLevel: zoomLevel,
                                        scrollOffset: scrollPosition.x,
                                        timelineWrapperWidth: outerScrollGeometry.size.width)
                                    
                                    EventBar(
                                        videoDuration: playerState.duration,
                                        zoomLevel: zoomLevel,
                                        scrollOffset: scrollPosition.x,
                                        timelineWrapperWidth: outerScrollGeometry.size.width,
                                        events: events)
                                }
                                
                                // Scrubber
                                Rectangle()
                                    .fill(.yellow)
                                    .frame(width: 1)
                                    .offset(x: CGFloat(playerState.playbackTime * zoomLevel), y: 0)
                            }
                            .gesture(MagnificationGesture()
                                .onChanged { scale in
                                    if (!isZooming) {
                                        isZooming = true
                                        startingZoomLevel = zoomLevel
                                    }
                                    zoomLevel = BoundsChecker.minmax(minBound: Float(minZoomLevel), value: startingZoomLevel * Float(scale.magnitude), maxBound: maxZoomLevel)
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
                    zoomLevel: $zoomLevel,
                    maxZoomLevel: CGFloat(maxZoomLevel),
                    minZoomLevel: minZoomLevel
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
