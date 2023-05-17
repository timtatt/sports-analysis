//
//  VideoTimeline.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 3/5/2023.
//

import Foundation
import SwiftUI
import OrderedCollections
import AVKit

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
    
    @State var isScrubbing: Bool = false
    @State var startingScrubberPosition: Float = 0
   
    
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
                                    .onTapGesture {
                                        let frame = geometry.frame(in: .global)
                                        let mouseScreenLocation = NSApp.keyWindow?.mouseLocationOutsideOfEventStream ?? .zero
                                        let mouseLocation = CGPoint(x: mouseScreenLocation.x - frame.origin.x, y: mouseScreenLocation.y - frame.origin.y)
                                        
                                        let offsetPosition = scrollPosition.x + mouseLocation.x
                                        let playbackPosition = offsetPosition / CGFloat(zoomLevel)
                                        playerState.seek(seconds: Float(playbackPosition))
                                    }
                                    
                                    EventBar(
                                        videoDuration: playerState.duration,
                                        zoomLevel: zoomLevel,
                                        scrollOffset: scrollPosition.x,
                                        timelineWrapperWidth: outerScrollGeometry.size.width,
                                        events: events)
                                }
                                
                                // Scrubber
                                TimelineScrubber(height: 40)
                                    .offset(x: CGFloat(playerState.playbackTime * zoomLevel) - 6, y: 0)
                                    .cursor(.openHand)
                                    .gesture(DragGesture()
                                        .onChanged { gesture in
                                            if (!isScrubbing) {
                                                isScrubbing = true
                                                NSCursor.closedHand.push()
                                                startingScrubberPosition = playerState.playbackTime
                                            }
                                            playerState.playbackTime = BoundsChecker.minmax(minBound: 0, value: startingScrubberPosition + Float(gesture.translation.width) / zoomLevel, maxBound: playerState.duration)
                                        }
                                        .onEnded { _ in
                                            isScrubbing = false
                                            NSCursor.pop()
                                        })
                            }
                            .frame(width: timelineWidth, height: outerScrollGeometry.size.height)
                        }
                        .gesture(MagnificationGesture()
                            .onChanged { scale in
                                if (!isZooming) {
                                    print("started zooming")
                                    isZooming = true
                                    startingZoomLevel = zoomLevel
                                }
                                zoomLevel = BoundsChecker.minmax(minBound: Float(minZoomLevel), value: startingZoomLevel * Float(scale.magnitude), maxBound: maxZoomLevel)
                            }
                            .onEnded { _ in
                                isZooming = false
                                print("finished zooming")
                            }
                        )
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

class MockAVPlayerItem : AVPlayerItem {
    public override var duration: CMTime {
        CMTime(value: 3000, timescale: 1)
    }
}

struct VideoTimeline_Previews : PreviewProvider {
    
    
    static var previews: some View {
        let state: PlayerState = {
            let state = PlayerState()
            let composition = AVMutableComposition()
            state.playerItem = MockAVPlayerItem(asset: composition)
            state.playbackTime = 11.2
            return state
        }()
        
        VStack {
            VideoTimeline(events: OrderedDictionary(), playerState: state)
        }
        .frame(width: 900, height: 160)
        
    }
}
