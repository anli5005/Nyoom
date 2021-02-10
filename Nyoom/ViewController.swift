//
//  ViewController.swift
//  Nyoom
//
//  Created by Anthony Li on 11/13/20.
//

import Cocoa
import RxSwift
import RxCocoa

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSPopoverDelegate {
    
    static let rowIdentifier = NSUserInterfaceItemIdentifier(rawValue: "oohitsarowidentifier")
    
    let disposeBag = DisposeBag()
    lazy var popover = NSPopover()
    var eventEditorViewController: EventEditorViewController?
    
    var events: [MeetingEvent] = []
    var pendingEditing: MeetingEvent?
        
    @IBOutlet weak var tableView: NSTableView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView?.register(NSNib(nibNamed: "EventTableCellView", bundle: nil), forIdentifier: Self.rowIdentifier)
        tableView?.target = self
        // tableView?.doubleAction = #selector(ViewController.doubleClick(sender:))

        tableView?.usesAutomaticRowHeights = true
        
        DataManager.shared.events.observeOn(MainScheduler.instance).subscribe { [self] events in
            self.events = events.element!
            self.tableView?.reloadData()
        }.disposed(by: disposeBag)
        
        let storyboard = NSStoryboard(name: "EventEditor", bundle: nil)
        eventEditorViewController = (storyboard.instantiateInitialController() as! EventEditorViewController)
        popover.contentViewController = eventEditorViewController!
        popover.delegate = self
        popover.behavior = .semitransient
        
        // Do any additional setup after loading the view.
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let result: EventTableCellView
        if let view = tableView.makeView(withIdentifier: Self.rowIdentifier, owner: self) as? EventTableCellView {
            result = view
        } else {
            fatalError("Unable to reuse row")
        }
        
        result.event = events[row]
        return result
    }
    
    @objc func doubleClick(sender: NSTableView) {
        if let row = tableView?.selectedRow, row >= 0 {
            pendingEditing = events[row]
            tableView!.scrollRowToVisible(row)
            if let view = tableView!.view(atColumn: 0, row: row, makeIfNecessary: true) {
                popover.show(relativeTo: view.bounds, of: view, preferredEdge: .maxX)
            }
        } else {
            popover.close()
        }
    }
    
    func popoverWillShow(_ notification: Notification) {
        eventEditorViewController!.event = pendingEditing
        eventEditorViewController!.editorWillOpen()
        pendingEditing = nil
    }
    
    func popoverShouldClose(_ popover: NSPopover) -> Bool {
        return true
    }
    
    func popoverDidClose(_ notification: Notification) {
        if eventEditorViewController?.isDirty == true {
            try! eventEditorViewController!.commitEdits()
        }
    }


}

