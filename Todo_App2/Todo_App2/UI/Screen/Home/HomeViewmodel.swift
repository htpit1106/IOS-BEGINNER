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
            let uncompleted = todos.filter { !($0.isCompleted ?? true) }
            let completed = todos.filter { $0.isCompleted ?? true }

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
    
    //add new tasks
    func addTodoRx(_ todo: Todo) -> Completable {
        Completable.create { completable in
            Task {
                do {
                    try await self.service.addTodo(todo)
                    var list = self.todos.value
                    list.append(todo)
                    self.todos.accept(list)
                    completable(.completed)
                } catch {
                    self.errorMessage.onNext(
                        "Failed to add todo: \(error.localizedDescription)"
                    )
                    completable(.error(error))
                }
            }
            return Disposables.create()
        }
    }

    // update toggle check
    func toggleCheckUpdate(todo: Todo) {
        Task {
            do {
                // Gửi chính xác trạng thái hiện tại của todo (không negate)
                try await service.updateCompleted(
                    id: todo.id ?? "",
                    isCompleted: todo.isCompleted ?? false
                )

                DispatchQueue.main.async {
                    var list = self.todos.value
                    if let index = list.firstIndex(where: { $0.id == todo.id }) {
                        
                        list[index] = todo
                        self.todos.accept(list)
                    }
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
    
    func updateTodoRx(_ todo: Todo) -> Completable {
        Completable.create { completable in
            Task {
                do {
                    try await self.service.updateTodo(todo)
                    var list = self.todos.value
                    if let index = list.firstIndex(where: { $0.id == todo.id })
                    {
                        list[index] = todo
                        self.todos.accept(list)
                    }
                    completable(.completed)
                } catch {
                    self.errorMessage.onNext(
                        "Failed to update todo: \(error.localizedDescription)"
                    )
                    completable(.error(error))
                }
            }
            return Disposables.create()
        }
    }
    
    
    func deleteTodo (_ todo: Todo) {
        guard let id = todo.id else {
            return
        }
        
        Task {
            do {
                try await service.deleteTodo(id: id)
                var list = todos.value
                list.removeAll() { $0.id == id }
                self.todos.accept(list)
            } catch {
                errorMessage.onNext("Fail to delete \(error.localizedDescription)")
            }
        }
    }

}
