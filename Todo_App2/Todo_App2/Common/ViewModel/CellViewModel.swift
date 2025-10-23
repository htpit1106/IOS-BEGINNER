//
//  CellViewModel.swift
//  Todo_App2
//
//  Created by Admin on 10/27/25.
//

import Foundation
import RxSwift
import RxCocoa

class CellViewModel {
    var disposeBag = DisposeBag()
    var todo: Todo
    let title = BehaviorRelay<String?>(value: nil)
    let detail = BehaviorRelay<String?>(value: nil)
    let imageUrl = BehaviorRelay<Category?>(value: .cup)
    let isSelected: BehaviorRelay<Bool> = .init(value: false)
    let isCompleted: BehaviorRelay<Bool> = .init(value: false)
    
    init(todo: Todo) {
        self.todo = todo
        setupCell()
    }
    
    func toggleIsCompleted() {
        isCompleted.accept(!isCompleted.value) 
    }
    func setupCell(){
        title.accept(todo.title)
        detail.accept(todo.content)
        imageUrl.accept(todo.category)
        isCompleted.accept(todo.isComplete ?? true)
    }
}

