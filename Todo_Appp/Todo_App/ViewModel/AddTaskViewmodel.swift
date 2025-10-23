//
//  AddTaskViewmodel.swift
//  Todo_App
//
//  Created by Admin on 10/23/25.
//

import Foundation
import RxCocoa
import RxSwift

class AddTaskViewmodel {
    // ui State
    // in put
     let titleRelay = BehaviorRelay<String>(value: "")
     let notesRelay = BehaviorRelay<String>(value: "")
     let dateRelay = BehaviorRelay<Date>(value: Date())
     let timeRelay = BehaviorRelay<Date>(value: Date())
     let categoryRelay = BehaviorRelay<String>(value: "list")

    // output
    let isFormValid: Observable<Bool>
    let saveResult = PublishSubject<Event<Void>>()
    var todoUpdate: Todo?
    private let service: TodoService
    private let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [
            .withInternetDateTime, .withFractionalSeconds,
        ]
        return f
    }()
    
    private let disposeBag = DisposeBag()
    private let homeViewmodel = HomeViewmodel.shared
    init(service: TodoService = TodoService()) {
        self.service = service
        
        // form hop le khi ca title va notes due khong rong

        isFormValid =
            Observable
            .combineLatest(titleRelay, notesRelay)
            .map { title, notes in
                !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    && !notes.trimmingCharacters(in: .whitespacesAndNewlines)
                        .isEmpty
            }
            .distinctUntilChanged()
            .share(replay: 1)
    }
    
    func saveTask() {
            Observable.combineLatest(titleRelay, notesRelay, dateRelay, timeRelay, categoryRelay)
                .take(1)
                .flatMapLatest { [weak self] title, notes, datePart, timePart, category -> Observable<Event<Void>> in
                    guard let self = self else { return Observable.empty() }

                    let cal = Calendar.current
                    var dateComp = cal.dateComponents([.year, .month, .day], from: datePart)
                    let timeComp = cal.dateComponents([.hour, .minute], from: timePart)
                    dateComp.hour = timeComp.hour
                    dateComp.minute = timeComp.minute
                    guard let combined = cal.date(from: dateComp) else {
                        return Observable.just(Event.error(RxError.unknown))
                    }

                    let isoString = self.isoFormatter.string(from: combined)

                    if var existing = self.todoUpdate {
                        existing.title = title
                        existing.content = notes
                        existing.time = isoString
                        existing.category = category

                        return self.homeViewmodel.updateTodoRx(existing)
                            .andThen(Observable.just(()))
                            .materialize()
                    } else {
                        let newTodo = Todo(
                            id: UUID().uuidString,
                            title: title,
                            category: category,
                            created_at: Date(),
                            content: notes,
                            time: isoString,
                            isCompleted: false
                        )
                        return self.homeViewmodel.addTodoRx(newTodo)
                            .andThen(Observable.just(()))
                            .materialize()
                    }
                }
                .bind(to: saveResult)
                .disposed(by: disposeBag)
        }

}
