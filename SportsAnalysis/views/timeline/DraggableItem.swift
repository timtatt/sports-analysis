//
//  DraggableItem.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 22/5/2023.
//

import Foundation
import SwiftUI

struct DraggableItem : View {
    
    let handleWidth: CGFloat = 4
    
    @Binding var overlayWidth: CGFloat
    @Binding var overlayStart: CGFloat
    
    let minOverlayWidth: CGFloat
    let color: Color
    let title: String
    
    init(overlayWidth: Binding<CGFloat>, overlayStart: Binding<CGFloat>, minOverlayWidth: CGFloat, color: Color = .white, title: String = "") {
        self._overlayWidth = overlayWidth
        self._overlayStart = overlayStart
        self.minOverlayWidth = minOverlayWidth
        self.color = color
        self.title = title
    }
    
    
    @State var startHandleHovering: Bool = false
    @State var endHandleHovering: Bool = false
    @State var overlayHovering: Bool = false
    
    @State var startingPoint: CGFloat = 0
    @State var startingWidth: CGFloat = 0
    
    @State var isDragging: Bool = false    
    
    var body : some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // TODO prevent title from wrapping
                Text(title)
                    .frame(width: max(0, overlayWidth - handleWidth * 2), height: geometry.size.height)
                    .background(color.opacity(overlayHovering ? 0.6 : 0.4))
                    .offset(x: overlayStart + handleWidth)
                    .cursor(.openHand)
                    .onHover { isHovering in overlayHovering = isHovering}
                    .gesture(DragGesture()
                        .onChanged { gesture in
                            if (!isDragging) {
                                isDragging = true
                                startingPoint = overlayStart
                                NSCursor.closedHand.push()
                            }
                            
                            overlayStart = BoundsChecker.minmax(minBound: 0, value: startingPoint + gesture.translation.width, maxBound: geometry.size.width - overlayWidth)
                        }
                        .onEnded { _ in
                            isDragging = false
                            NSCursor.pop()
                        }
                    )
                
                Rectangle()
                    .fill(color.opacity(startHandleHovering ? 1 : 0.8))
                    .cornerRadius(2, corners: [.topLeft, .bottomLeft])
                    .frame(width: handleWidth)
                    .offset(x: overlayStart)
                    .gesture(DragGesture()
                        .onChanged { gesture in
                            if (!isDragging) {
                                isDragging = true
                                startingPoint = overlayStart
                                startingWidth = overlayWidth
                            }
                            
                            overlayStart = BoundsChecker.minmax(minBound: 0, value: startingPoint + gesture.translation.width, maxBound: overlayStart + overlayWidth - minOverlayWidth)
                            overlayWidth = BoundsChecker.minmax(minBound: minOverlayWidth, value: startingWidth - gesture.translation.width, maxBound: geometry.size.width - startingPoint - startingWidth)
                        }
                        .onEnded { _ in isDragging = false }
                    )
                    .cursor(.resizeLeftRight)
                    .onHover { isHovering in startHandleHovering = isHovering }
                
                
                
                Rectangle()
                    .fill(color.opacity(endHandleHovering ? 1 : 0.8))
                    .cornerRadius(2, corners: [.topRight, .bottomRight])
                    .frame(width: handleWidth)
                    .offset(x: overlayStart + overlayWidth - handleWidth)
                    .gesture(DragGesture()
                        .onChanged { gesture in
                            if (!isDragging) {
                                isDragging = true
                                startingWidth = overlayWidth
                            }
                            
                            overlayWidth = BoundsChecker.minmax(minBound: minOverlayWidth, value: startingWidth + gesture.translation.width, maxBound: geometry.size.width - overlayStart)
                        }
                        .onEnded { _ in isDragging = false }
                    )
                    .cursor(.resizeLeftRight)
                    .onHover { isHovering in endHandleHovering = isHovering }
            }
        }
    }
}
