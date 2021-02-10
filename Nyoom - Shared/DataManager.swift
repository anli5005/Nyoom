//
//  DataManager.swift
//  Nyoom
//
//  Created by Anthony Li on 11/13/20.
//

import Foundation
import EventKit
import RxSwift
import RxRelay

func isZoomURL(_ url: URL) -> Bool {
    if url.host?.hasSuffix(".zoom.us") == true || url.host == "zoom.us" {
        if url.pathComponents.count == 3 && url.pathComponents.starts(with: ["/", "j"]) {
            return true
        }
    }
    
    return false
}

func today(using calendar: Calendar) -> Date? {
    let now = Date()
    return calendar.date(from: calendar.dateComponents([.day, .month, .year], from: now))
}

class DataManager {
    static let shared = DataManager()
    let store = EKEventStore()
    
    var disposeBag = DisposeBag()
    
    let eventsRelay = BehaviorRelay<[MeetingEvent]>(value: [])
    var events: Observable<[MeetingEvent]> { eventsRelay.asObservable() }
    
    let calendar = Calendar.autoupdatingCurrent
    
    let dateRelay = BehaviorRelay<Date>(value: today(using: .current)!)
    var date: Observable<Date> { dateRelay.asObservable() }
    
    init() {
        date.subscribe { [self] event in
            self.load(date: event.element!, using: calendar)
        }.disposed(by: disposeBag)
    }
    
    func load(date: Date, using calendar: Calendar) {
        let tomorrow = calendar.date(byAdding: DateComponents(day: 1), to: date)!
        let foundEvents = store.events(matching: store.predicateForEvents(withStart: date, end: tomorrow, calendars: nil))
        eventsRelay.accept(foundEvents.compactMap { data in
            var meeting: Meeting?
            if data.hasNotes, let notes = data.notes {
                do {
                    let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
                    let matches = detector.matches(in: notes, options: [], range: NSRange(location: 0, length: notes.count))
                    if let url = matches.lazy.compactMap({ match -> URL? in
                        if let url = match.url {
                            if isZoomURL(url) {
                                return url
                            }
                        }
                        return nil
                    }).first {
                        meeting = Meeting(url: url)
                    }
                } catch let e {
                    print(e)
                }
            }
            return MeetingEvent(startDate: data.startDate, endDate: data.endDate, allDay: data.isAllDay, name: data.title, meeting: meeting, ekEvent: data)
        })
    }
    
    func load() {
        load(date: dateRelay.value, using: calendar)
    }
    
    func setupListeners() {
        NotificationCenter.default.rx.notification(NSNotification.Name.EKEventStoreChanged).subscribe( { [self] _ in
            self.load()
        }).disposed(by: disposeBag)
    }
}
