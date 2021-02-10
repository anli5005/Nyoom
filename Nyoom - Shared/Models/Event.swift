//
//  Event.swift
//  Nyoom
//
//  Created by Anthony Li on 11/13/20.
//

import Foundation
import EventKit

struct Meeting {
    var url: URL
}

struct MeetingEvent {
    var startDate: Date
    var endDate: Date
    var allDay: Bool
    var name: String
    var meeting: Meeting?
    var ekEvent: EKEvent?
}

extension Meeting {
    var id: String {
        return String(url.pathComponents[2].prefix(while: { CharacterSet.decimalDigits.contains($0.unicodeScalars.first!) }))
    }
    
    var nickname: String? {
        return URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.first(where: { $0.name == "uname" })?.value?.replacingOccurrences(of: "+", with: " ")
    }
    
    var zoomURL: URL? {
        let prevComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        
        var components = URLComponents()
        components.scheme = "zoommtg"
        components.host = url.host
        components.path = "/join"
        components.queryItems = [URLQueryItem(name: "confno", value: id)] + (prevComponents?.queryItems ?? [])
        if let nickname = nickname {
            components.queryItems!.append(URLQueryItem(name: "uname", value: nickname))
        }
        return components.url
    }
}
