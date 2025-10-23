//
//  ViewController.swift
//  OnboardingChapter2
//
//  Created by Admin on 10/3/25.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var bgImv: UIImageView!

    @IBOutlet weak var pageController: UIPageControl!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var describLabel: UILabel!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!

    @IBOutlet var safeArea: UIView!
    var currentPage = 0

    @IBOutlet weak var startBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // ui config
        pageController.currentPage = currentPage
        pageController.numberOfPages = 3
        nextBtn.layer.cornerRadius = 50
        nextBtn.layer.shadowOffset = CGSize(width: 0, height: 4)
        nextBtn.layer.shadowColor = UIColor.black.cgColor
        nextBtn.layer.shadowOpacity = 0.7

        startBtn.layer.shadowOffset = CGSize(width: 0, height: 4)
        startBtn.layer.shadowColor = UIColor.black.cgColor
        startBtn.layer.shadowOpacity = 0.3
        startBtn.layer.cornerRadius = 50

        pageController.currentPageIndicatorTintColor = .black
        pageController.pageIndicatorTintColor = .gray

       

        safeArea.backgroundColor = UIColor(
            red: 0xDA / 255.0,
            green: 0xD3 / 255.0,
            blue: 0xC8 / 255.0,
            alpha: 1
        )
    }

    @IBAction func onPressSkipBtn(_ sender: Any) {
        currentPage = 2
        setLayerPage2()

    }

    @IBAction func onPressNext(_ sender: Any) {
        currentPage += 1
        if currentPage == 1 {
            setLayerPage1()
        }
        if currentPage == 2 {
            setLayerPage2()

        }
    }

        // set ui page 1
    func setLayerPage1() {
        pageController.currentPage = currentPage

        bgImv.image = UIImage(named: "img2")
        titleLabel.text = "Stay organized with team"
        describLabel.text =
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."

        safeArea.backgroundColor = UIColor(
            red: 0xFF / 255.0,
            green: 0xE5 / 255.0,
            blue: 0xD5 / 255.0,
            alpha: 1
        )
    }

    
    // set ui page 2
    func setLayerPage2() {
        pageController.currentPage = currentPage
        bgImv.image = UIImage(named: "img3")

        titleLabel.text = " Get notified when work happens"
        describLabel.text =
            "Take controll of notifications collaborate live or on your own time"
        nextBtn.layer.isHidden = true
        skipBtn.layer.isHidden = true
        startBtn.isHidden = false
        safeArea.backgroundColor = UIColor(
            red: 0xDC / 255.0,
            green: 0xF6 / 255.0,
            blue: 0xE6 / 255.0,
            alpha: 1
        )
    }

}
