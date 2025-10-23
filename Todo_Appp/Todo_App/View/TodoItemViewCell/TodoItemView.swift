//
//  TodoItemView.swift
//  Todo_App
//
//  Created by Admin on 10/13/25.
//

import UIKit

class TodoItemView: UITableViewCell {
    @IBOutlet weak var timeLB: UILabel!
    @IBOutlet weak var categoryImv: UIImageView!
    @IBOutlet weak var titleLB: UILabel!
    @IBOutlet weak var checkBtn: UIButton!

    // Callback khi nhấn nút check
    var onCheckBtn: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        checkBtn.layer.cornerRadius = 0

        categoryImv.alpha = 1.0

        backgroundColor = .white
        contentView.backgroundColor = .white
        selectionStyle = .none
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        titleLB.attributedText = nil
        titleLB.text = nil
        titleLB.textColor = .black

        timeLB.attributedText = nil
        timeLB.text = nil
        timeLB.textColor = .darkGray

        checkBtn.setImage(UIImage(named: "uncheck"), for: .normal)
        checkBtn.isEnabled = true

        backgroundColor = .white
        contentView.backgroundColor = .white
    }

    @IBAction func pressBtnCheck(_ sender: Any) {
        onCheckBtn?()
    }

    func configView(todo: Todo) {

        titleLB.text = todo.title ?? ""
        if let timeString = todo.time,
            let date = parseISODate(timeString)
        {

            let df = DateFormatter()

            df.locale = Locale(identifier: "en_US_POSIX")
            df.dateFormat = "hh:mm a"
            timeLB.text = df.string(from: date)
        } else {
            timeLB.text = nil
        }

        let attributes: [NSAttributedString.Key: Any] = [
            .strikethroughStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor.lightGray,
        ]

        // Kiểm tra trạng thái completed
        if todo.isCompleted {
            checkBtn.setImage(UIImage(named: "check"), for: .normal)

            // Gạch ngang và đổi màu text

            titleLB.attributedText = NSAttributedString(
                string: todo.title ?? "",
                attributes: attributes
            )
            timeLB.attributedText =
                NSAttributedString(
                    string: timeLB.text ?? "",
                    attributes: attributes
                )

            categoryImv.alpha = 0.7

        }

        switch todo.category {
        case "cup":
            categoryImv.image = UIImage(named: "cup")
        case "list":
            categoryImv.image = UIImage(named: "list")
        case "calendar":
            categoryImv.image = UIImage(named: "calendar")
        default:
            categoryImv.image = UIImage(systemName: "questionmark.circle")
        }
    }
    private func parseISODate(_ s: String) -> Date? {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f.date(from: s)
    }

}
