//
//  BoundsChecker.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 10/5/2023.
//

import Foundation

struct BoundsChecker {
    static func minmax<T : Numeric & Comparable>(minBound: T, value: T, maxBound: T) -> T {
        let minCheckedValue = max(minBound, value)
        let boundsCheckedValue = min(minCheckedValue, maxBound)
        
        return boundsCheckedValue
    }
}
