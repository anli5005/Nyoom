//
//  EventEditorViewController.swift
//  Nyoom
//
//  Created by Anthony Li on 12/28/20.
//

import AppKit
import EventKit

class EventEditorViewController: NSViewController {
    var event: MeetingEvent? {
        didSet {
            if event != nil {
                configureView()
            }
        }
    }
    
    var isDirty: Bool {
        if let event = event {
            return event.name != nameField.stringValue
        } else {
            return false
        }
    }
    
    @IBOutlet weak var nameField: NSTextField!
    @IBOutlet weak var allDayCheckbox: NSButton!
    @IBOutlet weak var startPicker: NSDatePicker!
    @IBOutlet weak var endPicker: NSDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    func configureView() {
        if isViewLoaded {
            if let event = event {
                nameField.stringValue = event.name
                startPicker.dateValue = event.startDate
                endPicker.dateValue = event.endDate
                allDayCheckbox.state = event.allDay ? .on : .off
            }
        }
    }
    
    func commitEdits() throws {
        if let event = event, let data = event.ekEvent {
            data.title = nameField.stringValue
            try DataManager.shared.store.save(data, span: .thisEvent, commit: true)
        }
    }
    
    func editorWillOpen() {
        
    }
}
