//
//  ViewController.swift
//  Todo_App2
//
//  Created by Admin on 10/27/25.
//
import UIKit
import RxSwift
import RxCocoa
import RxDataSources
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
        
        
        
    }
    
    override func setBindItems() {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Todo>>(
                configureCell: { [weak self] ds, tv, indexPath, todo in
                    guard
                        let cell = tv.dequeueReusableCell(withIdentifier: "TodoCell") as? TodoCellViewController
                    else {
                        return UITableViewCell()
                    }
                    cell.layer.cornerRadius = 8
                    // có thể gán dữ liệu vào cell tại đây:
                    // cell.configure(with: todo)
                    return cell
                }
            )

       
        // 2️⃣ Gán title cho header section
        dataSource.titleForHeaderInSection = { ds, index in
            return ds.sectionModels[index].model
        }

        // 3️⃣ Bind dữ liệu
        homViewmodel.sections
            .observe(on: MainScheduler.instance)
            .bind(to: todoTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
    }
    
    override func setBindEvent() {
        addBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                print("Navigate to Add Task screen")
                if let vc = self?.storyboard?.instantiateViewController(withIdentifier: "AddTaskViewController") {
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            })
            .disposed(by: disposeBag)
    }
    
    
    // config Ui
    override func setupUI(){
        // todayLB
        let now = Date()        // format date
        let formatDate = DateFormatter()
        formatDate.locale = Locale(identifier: "en_US_POSIX")
        formatDate.dateFormat = "MMMM, dd yyy"
        todayLB.text = formatDate.string(from: now)
        
        // separator cell
        todoTableView.separatorColor = UIColor.lightGray.withAlphaComponent(0.05)
        
        // gan ui view cell cho table
        let nib = UINib(nibName: "TodoCell", bundle: nil)
        todoTableView.register(nib, forCellReuseIdentifier: "TodoCell")
        todoTableView.rowHeight = 70
        
    }


}

