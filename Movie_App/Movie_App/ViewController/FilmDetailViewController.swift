//
//  FilmViewController.swift
//  Movie_App
//
//  Created by Admin on 10/8/25.
//
import UIKit

class FilmDetailViewController : UIViewController {
    @IBOutlet weak var imgThumb: UIImageView!
    @IBOutlet weak var imgbg: UIImageView!
    
    @IBOutlet weak var lbDescription: UILabel!
    @IBOutlet var lbType: UILabel!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var lbCalendar: UILabel!
    @IBOutlet weak var lbName: UILabel!
    
    var film: Film!
    var index: Int!
    var onFavouriteChanged: ((Film, Int) -> Void)?
    var isBookmarked: Bool!
    override func viewDidLoad() {
        super.viewDidLoad()
        imgbg.layer.cornerRadius = 16
        imgThumb.layer.cornerRadius = 16
        
        
        
      
        // bookmark button
        isBookmarked = film.favourited ?? false
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: isBookmarked ? UIImage(systemName: "bookmark.fill") : UIImage(systemName: "bookmark"),
            style: .plain,
            target: self,
            action: #selector(bookmarkTapped)
        )
    
    
    // Load data on screen
        loadDt()
    }
    
    

    @objc func bookmarkTapped(_ sender: UIBarButtonItem) {
        isBookmarked.toggle()
        let imageName = isBookmarked ? "bookmark.fill" : "bookmark"
        sender.image = UIImage(systemName: imageName)
        var updatedFilm = film!
        updatedFilm.setFavourited(isBookmarked)
        film = updatedFilm
        
        // call back on FravouriteChange perform code in <didSelected delegate>
        
        onFavouriteChanged?(film, index)
    }

    func loadDt(){
        
        lbName?.text = film?.title
        lbTime?.text = "139 minute"
        lbType?.text = "Action"
        lbDescription?.text = film?.overview

        if let date = film?.release_date {
            let year = String(date.prefix(4))
            lbCalendar?.text = year
        }
        
        if let imgbgpath = film?.poster_path,
           let url = URL(string: "https://image.tmdb.org/t/p/w500\(imgbgpath)") {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async {
                        self.imgbg?.image = UIImage(data: data)
                    }
                }
            }.resume()
        } else {
            imgbg.image = UIImage(named: "placeholder")
        }
        
        
        if let imgthumb = film?.backdrop_path,
           let url = URL(string: "https://image.tmdb.org/t/p/w500\(imgthumb)") {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async {
                        self.imgThumb?.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
    }
}
