//
//  Remider.swift
//  Today
//
//  Created by Admin on 10/2/25.
//

import Foundation

struct Reminder {
    private(set) var title: String
    private(set) var dueDate: Date
    private(set) var notes: String? = nil
    private(set) var isComplete: Bool = false
    private(set) var status: String
    
    
}

#if DEBUG
extension Reminder {
    static var sampleData = [
              Reminder(
                   title: "Submit reimbursement report", dueDate: Date().addingTimeInterval(800.0),
                   notes: "Don't forget about taxi receipts", isComplete: true, status: "success"),
               Reminder(
                   title: "Code review", dueDate: Date().addingTimeInterval(14000.0),
                   notes: "Check tech specs in shared folder", isComplete: true, status: "warnning"),
               Reminder(
                   title: "Pick up new contacts", dueDate: Date().addingTimeInterval(24000.0),
                   notes: "Optometrist closes at 6:00PM", status: "error"),
               Reminder(
                   title: "Add notes to retrospective", dueDate: Date().addingTimeInterval(3200.0),
                   notes: "Collaborate with project manager", isComplete: true,  status: "error"),
               Reminder(
                   title: "Interview new project manager candidate",
                   dueDate: Date().addingTimeInterval(60000.0), notes: "Review portfolio", status: "warnning"),
               Reminder(
                   title: "Mock up onboarding experience", dueDate: Date().addingTimeInterval(72000.0),
                   notes: "Think different",  status: "error"),
               Reminder(
                   title: "Review usage analytics", dueDate: Date().addingTimeInterval(83000.0),
                   notes: "Discuss trends with management", status: "warnning"),
               Reminder(
                   title: "Confirm group reservation", dueDate: Date().addingTimeInterval(92500.0),
                   notes: "Ask about space heaters",  status: "error"),
               Reminder(
                   title: "Add beta testers to TestFlight", dueDate: Date().addingTimeInterval(101000.0),
                   notes: "v0.9 out on Friday",  status: "error")
    ]
    
}

#endif

