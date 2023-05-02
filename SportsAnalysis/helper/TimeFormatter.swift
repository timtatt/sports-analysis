//
//  TimeFormatter.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 30/4/2023.
//

import Foundation

struct TimeFormatter {
    static func toTimecode(seconds: Float) -> String {
        
        let SS = Int(seconds.truncatingRemainder(dividingBy: 60))
        let MM = Int(seconds.truncatingRemainder(dividingBy: 3600) / 60)
        let HH = Int(seconds / 3600)
        
        return [HH, MM, SS]
            .map({ val in String(format: "%02d", val) })
            .joined(separator: ":")
    }
    
    static func toGeotime(seconds: Float) -> String {
        
        let SS = Int(seconds.truncatingRemainder(dividingBy: 60))
        let MM = Int(seconds / 60)
        
        var timecode = ""
        
        if (MM > 0) {
            timecode.append(String(format: "%02d'", MM))
        }
                            
        timecode.append(String(format: "%02d\"", SS))

        return timecode
    }
}
