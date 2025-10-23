//
//  ViewController.swift
//  SecondSample
//
//  Created by Admin on 9/30/25.
//

import UIKit


import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var ship: UIImageView!
    var player: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let path  = Bundle.main.path(forResource: "spaceshipfly", ofType: "wav")
        let url = URL(fileURLWithPath: path!)
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
        } catch let error as NSError {
            print(error.description)
        }
    }
    
    
  
    @IBAction func onButtonPress(_ sender: Any) {
        self.player.play()
        self.ship.isHidden = false
        UIView.animate(withDuration: 3, animations: {
            self.ship.frame = CGRect(x: 50, y: 300, width: 200, height: 200)
        })
    }
    
}

