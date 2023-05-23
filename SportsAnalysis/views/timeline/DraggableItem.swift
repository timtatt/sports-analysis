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
    
    let parentWidth: CGFloat
    let minOverlayWidth: CGFloat
    let color: Color
    let title: String
    
    
    init(parentWidth: CGFloat, overlayWidth: Binding<CGFloat>, overlayStart: Binding<CGFloat>, minOverlayWidth: CGFloat, color: Color = .white, title: String = "") {
        self.parentWidth = parentWidth
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
        Group {
            // TODO prevent title from wrapping
            Text(title)
                .frame(maxHeight: .infinity)
                .frame(width: max(0, overlayWidth - handleWidth * 2))
                .background(color.opacity(overlayHovering ? 0.6 : 0.4))
                .cursor(.openHand)
                .onHover { isHovering in overlayHovering = isHovering}
                .offset(x: overlayStart + handleWidth)
                .gesture(DragGesture()
                    .onChanged { gesture in
                        if (!isDragging) {
                            isDragging = true
                            startingPoint = overlayStart
                            NSCursor.closedHand.push()
                        }
                        
                        overlayStart = BoundsChecker.minmax(minBound: 0, value: startingPoint + gesture.translation.width, maxBound: parentWidth - overlayWidth)
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
                .cursor(.resizeLeftRight)
                .onHover { isHovering in startHandleHovering = isHovering }
                .offset(x: overlayStart)
                .gesture(DragGesture()
                    .onChanged { gesture in
                        if (!isDragging) {
                            isDragging = true
                            startingPoint = overlayStart
                            startingWidth = overlayWidth
                        }
                        
                        overlayStart = BoundsChecker.minmax(minBound: 0, value: startingPoint + gesture.translation.width, maxBound: overlayStart + overlayWidth - minOverlayWidth)
                        overlayWidth = BoundsChecker.minmax(minBound: minOverlayWidth, value: startingWidth - gesture.translation.width, maxBound: parentWidth - startingPoint - startingWidth)
                    }
                    .onEnded { _ in isDragging = false }
                )
                            
            Rectangle()
                .fill(color.opacity(endHandleHovering ? 1 : 0.8))
                .cornerRadius(2, corners: [.topRight, .bottomRight])
                .frame(width: handleWidth)
                .cursor(.resizeLeftRight)
                .onHover { isHovering in endHandleHovering = isHovering }
                .offset(x: overlayStart + overlayWidth - handleWidth)
                .gesture(DragGesture()
                    .onChanged { gesture in
                        if (!isDragging) {
                            isDragging = true
                            startingWidth = overlayWidth
                        }
                        
                        overlayWidth = BoundsChecker.minmax(minBound: minOverlayWidth, value: startingWidth + gesture.translation.width, maxBound: parentWidth - overlayStart)
                    }
                    .onEnded { _ in isDragging = false }
                )
        }
    }
}
