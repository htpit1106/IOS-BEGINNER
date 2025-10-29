//
//  CellViewModel.swift
//  Todo_App2
//
//  Created by Admin on 10/28/25.
//

import Foundation
import RxSwift
import RxCocoa

class CellViewModel {
    var disposeBag = DisposeBag()
    
    let title = BehaviorRelay<String?> (value: nil)
    let detail = BehaviorRelay<String?> (value: nil)
    let imagUrl = BehaviorRelay<String?> (value: nil)
}
