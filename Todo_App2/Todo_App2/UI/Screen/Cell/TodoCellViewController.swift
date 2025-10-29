//
//  TodoCellViewController.swift
//  Todo_App2
//
//  Created by Admin on 10/27/25.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit

import Foundation
import RxCocoa
import RxSwift
import UIKit

class TodoCellViewController: TableViewCell {
    @IBOutlet weak var timeLb: UILabel!
    @IBOutlet weak var titleLb: UILabel!
    @IBOutlet weak var checkBtn: UIButton!
    @IBOutlet weak var categoryImv: UIImageView!

    // Giữ reference mạnh tới viewModel để nó không bị giải phóng
    var cellViewModel: TodoCellViewmodel?

    override func awakeFromNib() {
        super.awakeFromNib()
        checkBtn.layer.cornerRadius = 0
        categoryImv.alpha = 1.0
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // Huỷ các binding cũ
        disposeBag = DisposeBag()

        // Huỷ reference viewModel (nếu muốn) hoặc giữ tuỳ logic của bạn.
        // Nếu muốn viewModel bị giải phóng khi reuse, uncomment dòng dưới:
        // cellViewModel = nil

        titleLb.attributedText = nil
        titleLb.text = nil
        timeLb.attributedText = nil
        timeLb.text = nil
        checkBtn.setImage(UIImage(named: "uncheck"), for: .normal)
        categoryImv.alpha = 1.0
    }

    override func bind(viewModel: CellViewModel) {
        guard let viewModel = viewModel as? TodoCellViewmodel else { return }

        // Lưu reference mạnh để viewModel không bị deinit sớm
        self.cellViewModel = viewModel

        viewModel.title.bind(to: titleLb.rx.text)
            .disposed(by: disposeBag)
        viewModel.time.bind(to: timeLb.rx.text)
            .disposed(by: disposeBag)
        viewModel.category
            .map { category -> UIImage? in
                switch category {
                case .list: return UIImage(named: "list")
                case .cup: return UIImage(named: "cup")
                case .calendar: return UIImage(named: "calendar")
                }
            }
            .bind(to: categoryImv.rx.image)
            .disposed(by: disposeBag)

       
        checkBtn.rx.tap
            .bind(to: viewModel.checkTapped)
            .disposed(by: disposeBag)

        // Khi viewModel phát didToggleCompleted -> gọi update service
        viewModel.didToggleCompleted
            .subscribe(onNext: { updatedTodo in
                HomeViewmodel.shared.toggleCheckUpdate(todo: updatedTodo)
            })
            .disposed(by: disposeBag)

        // Update UI theo trạng thái completed
        viewModel.isCompleted
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] completed in
                guard let self = self else { return }
                if completed {
                    let attrs: [NSAttributedString.Key: Any] = [
                        .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                        .foregroundColor: UIColor.lightGray,
                    ]
                    let titleText = viewModel.title.value ?? self.titleLb.text ?? ""
                    let timeText = viewModel.time.value ?? self.timeLb.text ?? ""

                    self.titleLb.attributedText = NSAttributedString(string: titleText, attributes: attrs)
                    self.timeLb.attributedText = NSAttributedString(string: timeText, attributes: attrs)
                    self.checkBtn.setImage(UIImage(named: "check"), for: .normal)
                    self.categoryImv.alpha = 0.7
                } else {
                    self.titleLb.attributedText = nil
                    self.titleLb.text = viewModel.title.value ?? self.titleLb.text

                    self.timeLb.attributedText = nil
                    self.timeLb.text = viewModel.time.value ?? self.timeLb.text
                    self.timeLb.textColor = .darkGray

                    self.checkBtn.setImage(UIImage(named: "uncheck"), for: .normal)
                    self.categoryImv.alpha = 1.0
                }
            })
            .disposed(by: disposeBag)
    }
    
    
}
