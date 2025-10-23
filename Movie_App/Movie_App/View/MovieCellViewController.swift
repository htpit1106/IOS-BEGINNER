
//  ViewCellController.swift
//  Movie_App
//
//  Created by Admin on 10/8/25.
//
 
import UIKit
 
class MovieCellViewController: UITableViewCell {
 
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var imgPoster: UIImageView!
    @IBOutlet weak var lbRating: UILabel!
    @IBOutlet weak var lbType: UILabel!
    @IBOutlet weak var lbCalendar: UILabel!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var imgHeart: UIImageView!
    private var currentTask: URLSessionDataTask?
    private var currentPosterURL: String?
 
    override func prepareForReuse() {
        super.prepareForReuse()
        currentTask?.cancel()
        imgPoster.image = nil
        currentPosterURL = nil
    }
    var onHeartTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        imgHeart.tintColor = UIColor.systemPink
        imgHeart.backgroundColor = .clear
        imgPoster.layer.cornerRadius = 16.0
        
        // Cho phép UIImageView nhận sự kiện
        imgHeart.isUserInteractionEnabled = true
        
        
        
        // Gắn UITapGestureRecognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(heartTapped))
        imgHeart.addGestureRecognizer(tapGesture)
    }


    @objc func heartTapped() {
        // Báo ngược về ViewController khi nhấn
        onHeartTapped?()
    }

    
    
 
    func updateViewCell(film: Film) {
        lbName?.text = film.title
        lbCalendar?.text = film.release_date
        lbRating?.text = String(format: "%.1f", film.vote_average ?? 0)
        lbType?.text = "Action"
        
        
        
        imgHeart.isHidden = !(film.favourited ?? false)


        guard let posterPath = film.poster_path else {
            imgPoster.image = UIImage(named: "placeholder")  // Ảnh mẫu để ở đây
            return
        }
 
        let fullURL = "https://image.tmdb.org/t/p/w500\(posterPath)"
        currentPosterURL = fullURL
 
        guard let url = URL(string: fullURL) else { return }
 
        currentTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self, let data = data else { return }
 
            // tranh tai sai anh
            guard self.currentPosterURL == fullURL else { return }
 
            DispatchQueue.main.async {
                self.imgPoster.image = UIImage(data: data)
            }
        }
        currentTask?.resume()
    }
 
}


