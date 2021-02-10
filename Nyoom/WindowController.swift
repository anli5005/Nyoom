//
//  WindowController.swift
//  Nyoom
//
//  Created by Anthony Li on 12/28/20.
//

import AppKit
import RxSwift

class WindowController: NSWindowController {
    @IBOutlet weak var dateMenu: NSPopUpButton!
    lazy var datePicker = NSDatePicker()
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = DataManager.shared.calendar
        formatter.dateStyle = .medium
        formatter.doesRelativeDateFormatting = true
        formatter.timeStyle = .none
        return formatter
    }()
    var disposeBag = DisposeBag()
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        let menuItem = NSMenuItem()
        datePicker.datePickerElements = .yearMonthDay
        datePicker.datePickerStyle = .clockAndCalendar
        datePicker.datePickerMode = .single
        datePicker.isBordered = false
        datePicker.backgroundColor = .clear
        
        DataManager.shared.date.observeOn(MainScheduler.instance).subscribe { event in
            if self.datePicker.dateValue != event.element! {
                self.datePicker.dateValue = event.element!
            }
            
            self.dateMenu?.menu?.items.first?.title = self.dateFormatter.string(from: event.element!)
        }.disposed(by: disposeBag)
        
        datePicker.target = self
        datePicker.action = #selector(datePickerAction(sender:))
        
        let containerView = NSView(frame: NSRect(x: 0, y: 0, width: 150, height: 150))
        containerView.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        containerView.addConstraints([
            NSLayoutConstraint(item: datePicker, attribute: .centerX, relatedBy: .equal, toItem: containerView, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: datePicker, attribute: .centerY, relatedBy: .equal, toItem: containerView, attribute: .centerY, multiplier: 1, constant: 0)
        ])
        menuItem.view = containerView
        
        dateMenu.menu!.addItem(menuItem)
        dateMenu.addConstraint(NSLayoutConstraint(item: dateMenu!, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .width, multiplier: 1, constant: 128))
    }
    
    @objc func datePickerAction(sender: NSDatePicker) {
        if DataManager.shared.dateRelay.value != sender.dateValue {
            DataManager.shared.dateRelay.accept(sender.dateValue)
        }
    }
    
    @IBAction func previous(sender: Any?) {
        DataManager.shared.dateRelay.accept(DataManager.shared.calendar.date(byAdding: DateComponents(day: -1), to: DataManager.shared.dateRelay.value)!)
    }
    
    @IBAction func next(sender: Any?) {
        DataManager.shared.dateRelay.accept(DataManager.shared.calendar.date(byAdding: DateComponents(day: 1), to: DataManager.shared.dateRelay.value)!)
    }
}
