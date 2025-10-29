import RxCocoa
import RxDataSources
import RxSwift
//
//  ViewController.swift
//  Todo_App2
//
//  Created by Admin on 10/27/25.
//
import UIKit

class HomeViewController: ViewController {
    @IBOutlet weak var todayLB: UILabel!
    @IBOutlet weak var titleAppLB: UILabel!
    @IBOutlet weak var todoTableView: UITableView!
    @IBOutlet weak var addBtn: UIButton!
    let homViewmodel = HomeViewmodel.shared
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()

        //load du lieu tu supabase
        homViewmodel.fetchTodos()
        setupEmptyView()
    }
    
    // setup "no task" when todoTable is empty
    private func setupEmptyView() {
        let label = UILabel()
        label.text = "No Tasks"
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        todoTableView.backgroundView = label
    }

    override func setBindItems() {
        let dataSource = RxTableViewSectionedReloadDataSource<
            SectionModel<String, Todo>
        >(
            configureCell: { ds, tv, indexPath, todo in
                guard
                    let cell = tv.dequeueReusableCell(
                        withIdentifier: "TodoCellViewController"
                    ) as? TodoCellViewController
                else {
                    return UITableViewCell()
                }
                cell.layer.cornerRadius = 8
                let cellViewModel = TodoCellViewmodel(todo: todo)
                cell.bind(viewModel: cellViewModel)

                return cell
            },
            titleForHeaderInSection: { ds, index in
                return ds.sectionModels[index].model
            }
        )

        // Bind data sections → tableView
        homViewmodel.sections
            .bind(to: todoTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        homViewmodel.sections
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] sections in
                guard let self = self else { return }
                let isEmpty =
                    sections.isEmpty || sections.allSatisfy { $0.items.isEmpty }
                self.todoTableView.backgroundView?.isHidden = !isEmpty
            })
            .disposed(by: disposeBag)
        // show error
        homViewmodel.errorMessage
            .subscribe(onNext: { [weak self] message in
                let alert = UIAlertController(
                    title: "Error",
                    message: message,
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            })
            .disposed(by: disposeBag)
    }

    override func setBindEvent() {
        addBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                print("Navigate to Add Task screen")
                if let vc = self?.storyboard?.instantiateViewController(
                    withIdentifier: "AddTaskViewController"
                ) {
                    self?.navigationController?.pushViewController(
                        vc,
                        animated: true
                    )
                }
            })
            .disposed(by: disposeBag)

        todoTableView.rx.modelSelected(Todo.self)
            .subscribe(onNext: { [weak self] todo in
                guard let self = self else { return }
                if todo.isCompleted == true { return }
                if let vc = self.storyboard?.instantiateViewController(
                    withIdentifier: "AddTaskViewController"
                ) as? AddTaskViewController {
                    vc.todoUpdate = todo
                    self.navigationController?.pushViewController(
                        vc,
                        animated: true
                    )
                }
            })
            .disposed(by: disposeBag)

        todoTableView.rx.modelDeleted(Todo.self)
            .subscribe(onNext: { [weak self] todo in
                guard let self = self else { return }
                Task {
                    do {
                        try await self.homViewmodel.deleteTodo(todo)
                        // Cập nhật local list
                        var list = self.homViewmodel.todos.value
                        list.removeAll { $0.id == todo.id }
                        self.homViewmodel.todos.accept(list)
                    } catch {
                        self.homViewmodel.errorMessage.onNext(
                            "Failed to delete: \(error.localizedDescription)"
                        )
                    }
                }
            })
            .disposed(by: disposeBag)
    }

    // config Ui
    override func setupUI() {
        // todayLB
        let now = Date()  // format date
        let formatDate = DateFormatter()
        formatDate.locale = Locale(identifier: "en_US_POSIX")
        formatDate.dateFormat = "MMMM, dd yyy"
        todayLB.text = formatDate.string(from: now)

        // separator cell
        todoTableView.separatorColor = UIColor.lightGray.withAlphaComponent(
            0.05
        )
        // gan ui view cell cho table
        let nib = UINib(nibName: "TodoCell", bundle: nil)
        todoTableView.register(
            nib,
            forCellReuseIdentifier: "TodoCellViewController"
        )
        todoTableView.separatorStyle = .singleLine
        todoTableView.backgroundColor = .clear
        todoTableView.rowHeight = 70
        todoTableView.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        willDisplayHeaderView view: UIView,
        forSection section: Int
    ) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        let title = header.textLabel?.text ?? ""
        header.textLabel?.textColor = .black
    }
}
