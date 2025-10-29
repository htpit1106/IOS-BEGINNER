//
//  TodoCellViewmodel.swift
//  Todo_App2
//
//  Created by Admin on 10/28/25.
//
import Foundation
import RxSwift
import RxCocoa

class TodoCellViewmodel: CellViewModel {
    let todo: Todo
    let time = BehaviorRelay<String?>(value: nil)
    let category = BehaviorRelay<Category>(value: .list)
    let isCompleted = BehaviorRelay<Bool>(value: false)
    let checkTapped = PublishRelay<Void>()
    let didToggleCompleted = PublishRelay<Todo>()

    override init() {
        fatalError("Use init(todo:)")
    }

    init (todo: Todo) {
        self.todo = todo
        super.init()
        title.accept(todo.title)
        category.accept(todo.category ?? .list)
        isCompleted.accept(todo.isCompleted ?? false)

        if let timeString = todo.time,
           let date = Common().isoToDate(timeString) {
            let df = DateFormatter()
            df.locale = Locale(identifier: "en_US_POSIX")
            df.dateFormat = "hh:mm a"
            time.accept(df.string(from: date))
        }

        checkTapped
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let newCompleted = !self.isCompleted.value
                self.isCompleted.accept(newCompleted)

                // Tạo Todo mới với trạng thái cập nhật
                var updatedTodo = self.todo
                updatedTodo.isCompleted = newCompleted

                // Phát ra event cho ViewController
                self.didToggleCompleted.accept(updatedTodo)
            })
            .disposed(by: disposeBag)
    }

   
}
