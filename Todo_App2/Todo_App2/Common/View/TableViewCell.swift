//
//  TableViewCell.swift
//  Todo_App2
//
//  Created by Admin on 10/27/25.
//


//
//  TableViewCell.swift
//  BaseMVVM
//
//  Created by Lê Thọ Sơn on 1/4/20.
//  Copyright © 2020 thoson.it. All rights reserved.
//

import Foundation
import RxSwift
import UIKit
class TableViewCell: UITableViewCell {
    var disposeBag =  DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag =  DisposeBag()
    }
    
    func bind(viewModel: CellViewModel) {
        
    }
    func setupUI() {
        
    }
}
