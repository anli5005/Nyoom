//
//  EventTableCellView.swift
//  Nyoom
//
//  Created by Anthony Li on 11/13/20.
//

import Foundation
import AppKit

func formatMeetingID(_ id: String) -> String {
    var result = ""
    var i = 0
    for c in id {
        result.append(c)
        if i == 2 || i == id.count - 5 {
            result += " "
        }
        i += 1
    }
    return result
}

class EventTableCellView: NSTableCellView {
    var event: MeetingEvent? {
        didSet {
            updateData()
        }
    }
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    @IBOutlet weak var titleLabel: NSTextField?
    @IBOutlet weak var timeLabel: NSTextField?
    @IBOutlet weak var meetingIDLabel: NSTextField?
    @IBOutlet weak var joinButton: NSButton?
    @IBOutlet var joinButtonConstraint: NSLayoutConstraint?
    
    lazy var temporaryConstraint = titleLabel.map { NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: $0, attribute: .trailing, multiplier: 1, constant: 8) }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        changeButtonAppearance()
    }
    
    override func viewDidChangeEffectiveAppearance() {
        if #available(macOS 10.14, *) {
            super.viewDidChangeEffectiveAppearance()
        }
        changeButtonAppearance()
    }
    
    func changeButtonAppearance() {
        var appearance = NSAppearance(named: .aqua)
        if #available(macOS 10.14, *) {
            if effectiveAppearance.name == .darkAqua || effectiveAppearance.name == .vibrantDark {
                appearance = NSAppearance(named: .darkAqua)
            }
        }
        joinButton?.appearance = appearance
    }
    
    func updateData() {
        titleLabel?.stringValue = event?.name ?? "(null)"
        alphaValue = 1.0
        if let event = event {
            if event.allDay {
                timeLabel?.stringValue = "All-Day"
            } else {
                timeLabel?.stringValue = "\(Self.timeFormatter.string(from: event.startDate)) - \(Self.timeFormatter.string(from: event.endDate))"
            }
            let now = Date()
            if !event.allDay && DataManager.shared.calendar.isDate(DataManager.shared.dateRelay.value, inSameDayAs: now) && event.endDate < Date() {
                alphaValue = 0.5
            }
        } else {
            timeLabel?.stringValue = "(null)"
        }
        if let id = event?.meeting?.id {
            meetingIDLabel?.stringValue = formatMeetingID(id)
            meetingIDLabel?.alphaValue = 1.0
            if let nickname = event!.meeting!.nickname {
                meetingIDLabel?.stringValue += " • \(nickname)"
            }
            temporaryConstraint.map { removeConstraint($0) }
            joinButtonConstraint.map { addConstraint($0) }
            joinButton?.isHidden = false
        } else {
            meetingIDLabel?.stringValue = "Not a Zoom meeting"
            meetingIDLabel?.alphaValue = 0.5
            joinButton?.isHidden = true
            joinButtonConstraint.map { removeConstraint($0) }
            temporaryConstraint.map { addConstraint($0) }
        }
    }
    
    @IBAction func join(sender: Any?) {
        if let meeting = event?.meeting {
            var shouldOpenInBrowser = true
            if let url = meeting.zoomURL {
                shouldOpenInBrowser = !NSWorkspace.shared.open(url)
            }
            if shouldOpenInBrowser {
                NSWorkspace.shared.open(meeting.url)
            }
        }
    }
}
