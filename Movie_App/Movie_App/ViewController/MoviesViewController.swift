//
//  ViewController.swift
//  Movie_App
//
//  Created by Admin on 10/6/25.
//

import UIKit

class MoviesViewController: UIViewController, UITableViewDataSource,
    UITableViewDelegate
{
    @IBOutlet weak var filmTableView: UITableView!
    var responseFilm: FilmResponse!
    var listFilm: [Film] = []
    var isLoading: Bool = false
    var currentPage: Int = 1
    var totalPage: Int = 7
    var canLoadMore = false
    
    // spinner loadmore
    let spinner = UIActivityIndicatorView(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Movie List"

        // draw spinner
        spinner.frame = CGRect(
            x: 0,
            y: 0,
            width: filmTableView.bounds.width,
            height: 44
        )
        spinner.startAnimating()
        
    
        
        // spinner refresh
        let refreshControl = UIRefreshControl()
        filmTableView.refreshControl = refreshControl
        
        // change icon refresh
        let image = UIImage(systemName: "arrow.2.circlepath.circle")!
        
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        refreshControl.addSubview(imageView)
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        loadFilm(page: 1)
        filmTableView.dataSource = self
        filmTableView.delegate = self
        
       
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 36/255, green: 42/255, blue: 50/255, alpha: 1)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .white
    }

    @objc func refreshData() {
        print("reload")
        self.listFilm.removeAll()
        self.currentPage = 1
        self.loadFilm(page: 1)
    }
    
    
    func loadFilm(page: Int) {
        self.filmTableView.refreshControl?.endRefreshing()

        guard !isLoading else {
            return
        }
        isLoading = true
        Task {
            do {
                responseFilm = try await DataService.instance.getFilmList(
                    page: page
                )
                DispatchQueue.main.async {
                    if page == 1 {
                        self.listFilm = self.responseFilm.results
                        self.filmTableView.reloadData()
                    } else {
                        let startIndex = self.listFilm.count
                        self.listFilm.append(
                            contentsOf: self.responseFilm.results
                        )
                        // map: anhxa tung ptu tu startIndex -> cuoi danh sach
                        // return indexpaths array ...
                        
                        let indexPaths = (startIndex..<self.listFilm.count).map
                        { IndexPath(row: $0, section: 0) }
                        
                        // them vao tableView
                        self.filmTableView.performBatchUpdates({
                            self.filmTableView.insertRows(at: indexPaths, with: .fade)
                        })
                    }

                    self.filmTableView.tableFooterView = nil
                    self.isLoading = false
                }

            } catch {
                print("Api error: ", error.localizedDescription)
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        return listFilm.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: "MovieCellViewController"
        ) as? MovieCellViewController {
            var film = listFilm[indexPath.row]

            cell.onHeartTapped = {
                [weak self] in
                guard let self = self else { return }
                film.setFavourited(!(film.favourited ?? false))
                self.listFilm[indexPath.row] = film

                self.filmTableView.reloadRows(at: [indexPath], with: .automatic)
            }
          
    
            

            cell.updateViewCell(film: listFilm[indexPath.row])

            return cell
        } else {
            return MovieCellViewController()

        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }

    // scrollview add spinner when reload
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height

        if offsetY > contentHeight - frameHeight - 100 {
            guard !isLoading && currentPage < totalPage else { return }
            currentPage += 1
            filmTableView.tableFooterView = spinner
            loadFilm(page: currentPage)
        }
    }
    
    
 
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        filmTableView.deselectRow(at: indexPath, animated: false)
        let film = listFilm[indexPath.row]

        //
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let detailVC = storyboard.instantiateViewController(
            withIdentifier: "FilmViewController"
        ) as? FilmDetailViewController {
            detailVC.film = film
            detailVC.index = indexPath.row

            detailVC.onFavouriteChanged = { [weak self] updatedFilm, index in
                guard let self = self else { return }
                self.listFilm[index] = updatedFilm
                let indexPath = IndexPath(row: index, section: 0)
                self.filmTableView.reloadRows(at: [indexPath], with: .automatic)

            }

            navigationController?.pushViewController(detailVC, animated: true)
        }
    }

}
