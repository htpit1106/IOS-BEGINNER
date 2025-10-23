//
//  TodoCellViewController.swift
//  Todo_App2
//
//  Created by Admin on 10/27/25.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class TodoCellViewController : TableViewCell {
    @IBOutlet weak var timeLb: UILabel!
    @IBOutlet weak var titleLb: UILabel!
    @IBOutlet weak var checkBtn: UIButton!
    @IBOutlet weak var categoryImv: UIImageView!
    override func prepareForReuse() {
        // 
    }
    
    override func setupUI() {
        checkBtn.layer.cornerRadius = 0
    }
    
    override func bind(viewModel: CellViewModel) {
        let todo = viewModel.todo
        // bind

        // Assuming viewModel.title is an Observable<String?> or Driver<String?>
        viewModel.title
            .bind(to: titleLb.rx.text)
            .disposed(by: disposeBag)
    }
}
