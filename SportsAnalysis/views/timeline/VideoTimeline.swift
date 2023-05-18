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
    @State var startingScrubberPosition: Float = 0
   
    func getMouseLocation(_ geometry: GeometryProxy) -> CGPoint {
        let frame = geometry.frame(in: .global)
        let mouseScreenLocation = NSApp.keyWindow?.mouseLocationOutsideOfEventStream ?? .zero
        return CGPoint(x: mouseScreenLocation.x - frame.origin.x, y: mouseScreenLocation.y - frame.origin.y)
    }
    
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
                                Color("WidgetBackground").ignoresSafeArea()
                                VStack(spacing: 0) {
                                    TimecodeBar(
                                        videoDuration: playerState.duration,
                                        zoomLevel: zoomLevel,
                                        scrollOffset: scrollPosition.x,
                                        timelineWrapperWidth: outerScrollGeometry.size.width)
                                    .onTapGesture {
                                        let offsetPosition = scrollPosition.x + getMouseLocation(geometry).x
                                        let playbackPosition = offsetPosition / CGFloat(zoomLevel)
                                        playerState.seek(seconds: Float(playbackPosition))
                                    }
                                    .gesture(DragGesture(minimumDistance: 5, coordinateSpace: .local)
                                        .onChanged { gesture in
                                            let mouseLocation = getMouseLocation(geometry)
                                            let offsetPosition = scrollPosition.x + mouseLocation.x
                                            let playbackPosition = BoundsChecker.minmax(minBound: 0, value: Float(offsetPosition) / zoomLevel, maxBound: playerState.duration)
                                                                                        
                                            if (mouseLocation.x > geometry.size.width) {
                                                scrollPosition.x = BoundsChecker.minmax(minBound: 0, value: scrollPosition.x + mouseLocation.x - geometry.size.width, maxBound: timelineWidth - geometry.size.width)
                                            } else if (mouseLocation.x < 0) {
                                                scrollPosition.x = BoundsChecker.minmax(minBound: 0, value: scrollPosition.x + mouseLocation.x, maxBound: timelineWidth - geometry.size.width)
                                            }
                                            
                                            if (!playerState.isScrubbing) {
                                                NSCursor.closedHand.push()
                                                playerState.startScrubbing()
                                            }
                                            
                                            playerState.playbackTime = BoundsChecker.minmax(minBound: 0, value: playbackPosition, maxBound: playerState.duration)
                                        }
                                        .onEnded { _ in
                                            playerState.stopScrubbing()
                                            NSCursor.pop()
                                        })
                                    
                                    // TODO not updating when events are added
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
                                            if (!playerState.isScrubbing) {
                                                NSCursor.closedHand.push()
                                                playerState.startScrubbing()
                                                startingScrubberPosition = playerState.playbackTime
                                            }
                                            playerState.playbackTime = BoundsChecker.minmax(minBound: 0, value: startingScrubberPosition + (Float(gesture.translation.width) / zoomLevel), maxBound: playerState.duration)
                                        }
                                        .onEnded { _ in
                                            playerState.stopScrubbing()
                                            NSCursor.pop()
                                        })
                            }
                            .frame(width: timelineWidth, height: outerScrollGeometry.size.height)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .gesture(MagnificationGesture()
                            .onChanged { scale in
                                if (!isZooming) {
                                    isZooming = true
                                    startingZoomLevel = zoomLevel
                                }
                                let newZoomLevel = BoundsChecker.minmax(minBound: Float(minZoomLevel), value: startingZoomLevel * Float(scale.magnitude), maxBound: maxZoomLevel)
                                
                                let mouseLocation = getMouseLocation(geometry)
                                let newScrollPosition = (CGFloat(newZoomLevel) * (scrollPosition.x + mouseLocation.x) / CGFloat(zoomLevel)) - mouseLocation.x
                                
                                scrollPosition.x = BoundsChecker.minmax(minBound: 0, value: newScrollPosition, maxBound: CGFloat(playerState.duration * newZoomLevel) - geometry.size.width)
                                zoomLevel = newZoomLevel
                            }
                            .onEnded { _ in isZooming = false }
                        )
                    }
                }
                .cornerRadius(8)
                .frame(height: 66)
                TimelineScrollbar(
                    scrollPosition: $scrollPosition.x,
                    zoomLevel: $zoomLevel,
                    events: events.values.elements,
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
