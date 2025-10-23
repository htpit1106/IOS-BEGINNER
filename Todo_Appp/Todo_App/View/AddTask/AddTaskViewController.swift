import RxCocoa
import RxSwift
import UIKit

class AddTaskViewController: UIViewController {

    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var cupBtn: UIButton!
    @IBOutlet weak var calendarBtn: UIButton!
    @IBOutlet weak var listBtn: UIButton!
    @IBOutlet weak var notesTV: UITextView!
    @IBOutlet weak var timeTF: UITextField!
    @IBOutlet weak var dateTF: UITextField!
    @IBOutlet weak var saveBtn: UIButton!

    var todoUpdate: Todo?

    private let datePicker = UIDatePicker()
    private let timePicker = UIDatePicker()

    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df
    }()
    private let timeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .none
        df.timeStyle = .short
        return df
    }()

    private let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [
            .withInternetDateTime, .withFractionalSeconds,
        ]
        return f
    }()

    private let disposeBag = DisposeBag()

   
    let appearance = UINavigationBarAppearance()

    private let viewModel = HomeViewmodel.shared
    private let addViewmodel = AddTaskViewmodel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // nav bar appearance
        appearance.configureWithOpaqueBackground()
        appearance.backgroundImage = UIImage(named: "header")
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .white

        notesTV.layer.backgroundColor = UIColor.white.cgColor
        setupCategoryButtons()
        setIconTextField(dateTF, iconName: "calendar")
        setIconTextField(timeTF, iconName: "clock")
        setupPickers()

        titleTF.attributedPlaceholder = NSAttributedString(
            string: "Task Title",
            attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.systemGray2
            ]
        )

        if let todo = todoUpdate {
            UIUpdateTask(todo: todo)
            print(todo.time)
        } else {
            UIAddTask()
        }

        bindUI()
        bindSave()
    }

    // MARK: - Bindings

    private func bindUI() {
        // Inputs -> Relays
        titleTF.rx.text.orEmpty
            .bind(to: addViewmodel.titleRelay)
            .disposed(by: disposeBag)

        notesTV.rx.text.orEmpty
            .bind(to: addViewmodel.notesRelay)
            .disposed(by: disposeBag)

        datePicker.rx.date
            .bind(to: addViewmodel.dateRelay)
            .disposed(by: disposeBag)

        timePicker.rx.date
            .bind(to: addViewmodel.timeRelay)
            .disposed(by: disposeBag)

        // Category button UI updates when relay changes
        addViewmodel.categoryRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.setupCategoryButtons()
            })
            .disposed(by: disposeBag)
        
        addViewmodel.dateRelay
            .map { [weak self] in self?.dateFormatter.string(from: $0) ?? "" }
            .bind(to: dateTF.rx.text)
            .disposed(by: disposeBag)

        addViewmodel.timeRelay
            .map { [weak self] in self?.timeFormatter.string(from: $0) ?? "" }
            .bind(to: timeTF.rx.text)
            .disposed(by: disposeBag)

        
        addViewmodel.isFormValid
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] valid in
                    guard let self = self else { return }
                    let red = UIColor.red.cgColor
                    let clear = UIColor.clear.cgColor

                    self.titleTF.layer.borderWidth = valid || !self.titleTF.text!.isEmpty ? 0 : 1
                    self.titleTF.layer.borderColor = valid || !self.titleTF.text!.isEmpty ? clear : red

                    self.notesTV.layer.borderWidth = valid || !self.notesTV.text!.isEmpty ? 0 : 1
                    self.notesTV.layer.borderColor = valid || !self.notesTV.text!.isEmpty ? clear : red
                })
                .disposed(by: disposeBag)
//
    }

    // nut save
    private func bindSave() {
        
        saveBtn.rx.tap
            .withLatestFrom(addViewmodel.isFormValid)
            .filter { $0 }
            .bind {
                [weak self] _ in
                self?.addViewmodel.saveTask()
            }
            .disposed(by: disposeBag)
      
            // Lắng nghe kết quả lưu
            addViewmodel.saveResult
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] event in
                    switch event {
                    case .next:
                        self?.navigationController?.popViewController(animated: true)
                    case .error(let e):
                        self?.showAlert(message: "Operation failed: \(e.localizedDescription)")
                    case .completed:
                        break
                    }
                })
                .disposed(by: disposeBag)
    }

    // MARK: - UI setup for Add / Update

    func UIAddTask() {
        let now = Date()

        datePicker.date = now
        timePicker.date = now

        addViewmodel.categoryRelay.accept("list")
    }

    func UIUpdateTask(todo: Todo) {
        titleTF.text = todo.title
        notesTV.text = todo.content

        self.title = "Edit Task"

        if let isoString = todo.time, let d = isoFormatter.date(from: isoString)
        {
            datePicker.date = d
            timePicker.date = d
        } else {
            // fallback: keep pickers on current date/time or set to now
            let now = Date()
            datePicker.date = now
            timePicker.date = now

        }

        addViewmodel.categoryRelay.accept(todo.category ?? "list")
    }

    // MARK: - Pickers, toolbar, helpers

    func setIconTextField(_ textField: UITextField, iconName: String) {
        let icon = UIImageView(image: UIImage(systemName: iconName))
        icon.tintColor = UIColor(
            red: 74 / 255.0,
            green: 55 / 255.0,
            blue: 128 / 255.0,
            alpha: 1.0
        )
        icon.contentMode = .scaleAspectFit
        let iconContainer = UIView(
            frame: CGRect(x: 0, y: 0, width: 35, height: 20)
        )
        icon.frame = CGRect(x: 5, y: 0, width: 20, height: 20)
        iconContainer.addSubview(icon)
        textField.rightView = iconContainer
        textField.rightViewMode = .always
    }

    private func setupPickers() {

        // ngăn sử dụng phím để nhập
        dateTF.tintColor = .clear  // ẩn con trỏ nháy
        dateTF.autocorrectionType = .no  // tắt gợi ý
        dateTF.spellCheckingType = .no  // tắt kiểm tra chính tả
        dateTF.isUserInteractionEnabled = true  // vẫn tap được

        timeTF.tintColor = .clear
        timeTF.autocorrectionType = .no
        timeTF.spellCheckingType = .no
        timeTF.isUserInteractionEnabled = true

        // set style for picker
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) { datePicker.locale = Locale.current }
        datePicker.minimumDate = Calendar.current.startOfDay(for: Date())

        dateTF.inputView = datePicker
        dateTF.inputAccessoryView = makeToolbarPicker(
            doneSelector: #selector(doneDate),
            cancelSelector: #selector(cancelEditing)
        )

        timePicker.preferredDatePickerStyle = .wheels
        timePicker.datePickerMode = .time
        if #available(iOS 13.4, *) { timePicker.locale = Locale.current }

        timeTF.inputView = timePicker
        timeTF.inputAccessoryView = makeToolbarPicker(
            doneSelector: #selector(doneTime),
            cancelSelector: #selector(cancelEditing)
        )
    }

    private func makeToolbarPicker(
        doneSelector: Selector,
        cancelSelector: Selector
    ) -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let cancel = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: cancelSelector
        )
        let flex = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        let done = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: doneSelector
        )
        toolbar.items = [cancel, flex, done]
        return toolbar
    }

    @objc private func doneDate() {
        dateTF.resignFirstResponder()
    }

    @objc private func doneTime() {
        timeTF.resignFirstResponder()
    }

    @objc private func cancelEditing() {
        view.endEditing(true)
    }

    @objc private func dateChanged(_ sender: UIDatePicker) {
        dateTF.text = dateFormatter.string(from: sender.date)
    }

    @objc private func timeChanged(_ sender: UIDatePicker) {
        timeTF.text = timeFormatter.string(from: sender.date)
    }

    // MARK: - Category buttons

    @IBAction func onListCategory(_ sender: Any) {
        addViewmodel.categoryRelay.accept("list")
    }

    @IBAction func onCalendarCategory(_ sender: Any) {
        addViewmodel.categoryRelay.accept("calendar")
    }

    @IBAction func onCupCategory(_ sender: Any) {
        addViewmodel.categoryRelay.accept("cup")
    }

    private func setupCategoryButtons() {
        let buttons: [(UIButton?, String)] = [
            (listBtn, "list"),
            (calendarBtn, "calendar"),
            (cupBtn, "cup"),
        ]

        buttons.forEach { (button, category) in
            guard let button = button else { return }
            var config = button.configuration ?? .filled()
            config.cornerStyle = .capsule

            //  Kiểm tra xem có được chọn không
            let selected = addViewmodel.categoryRelay.value == category
            config.baseBackgroundColor = selected ? .black : .white
            config.baseForegroundColor = selected ? .white : .black
            button.configuration = config
        }
    }

    // MARK: - Helpers

    func showAlert(message: String) {
        let alert = UIAlertController(
            title: "Missing Information",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
}
