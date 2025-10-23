//
//  HomeViewmodel.swift
//  Todo_App2
//
//  Created by Admin on 10/27/25.
//
import Foundation
import RxCocoa
import RxDataSources
import RxSwift
import UIKit

class HomeViewmodel {
    private var disposeBag = DisposeBag()
    let todos = BehaviorRelay<[Todo]>(value: [])
    let errorMessage = PublishSubject<String>()
    // section: map data
    
    static let shared = HomeViewmodel()
    private init() {}

    private let service = TodoService()
    private let common = Common()

    var sections: Observable<[SectionModel<String, Todo>]> {
        todos.map { todos in

            let calendar = Calendar.current
            let now = Date()

            // Chia todo ra
            let uncompleted = todos.filter { !($0.isComplete ?? true) }
            let completed = todos.filter { $0.isComplete ?? true}

            // Gom nhóm các todo chưa hoàn thành theo thời gian
            let grouped = Dictionary(grouping: uncompleted) { todo -> String in
                guard
                    let iso = todo.time,
                    let date = self.common.isoToDate(iso)
                else {
                    return "No Date"
                }
                if date < now {
                    return "Overdue"
                }

                if calendar.isDateInToday(date) { return "Today" }
                if calendar.isDateInTomorrow(date) { return "Tomorrow" }

                if calendar.isDate(
                    date,
                    equalTo: now,
                    toGranularity: .weekOfYear
                ) {
                    return "This week"
                }

                if let nextWeek = calendar.date(
                    byAdding: .weekOfYear,
                    value: 1,
                    to: now
                ),
                    calendar.isDate(
                        date,
                        equalTo: nextWeek,
                        toGranularity: .weekOfYear
                    )
                {
                    return "Next week"
                }
                return "Later"
            }

            let order = [
                "Overdue", "Today", "Tomorrow", "This week", "Next week",
                "Later", "No Date",
            ]
            var sections: [SectionModel<String, Todo>] = []
            for title in order {
                if let items = grouped[title],
                    !items.isEmpty
                {
                    let sortedItems = items.sorted {
                        guard
                            let d1 = self.common.isoToDate($0.time ?? ""),
                            let d2 = self.common.isoToDate($1.time ?? "")
                        else {
                            return false
                        }
                        return d1 < d2
                    }
                    sections.append(
                        SectionModel(model: title, items: sortedItems)
                    )
                }
            }

            // Them phan completed rieng

            if !completed.isEmpty {
                sections.append(
                    SectionModel(model: "Completed", items: completed)
                )
            }
            return sections
        }

    }

    // get todos from api
    func fetchTodos() {
        Task {
            do {
                let data = try await service.fetchTodos()
                DispatchQueue.main.async {
                    self.todos.accept(data)
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage.onNext(
                        "Failed to load todos: \(error.localizedDescription)"
                    )
                }
            }
        }
    }
}
