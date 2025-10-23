//
//  ViewController.swift
//  Timer_Chapter2
//
//  Created by Admin on 10/3/25.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var btnReset: UIButton!
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    var timer: Timer?
    
    @IBOutlet weak var btnStart: UIButton!
    
    // so giay ban dau
    var orgSe  = 25*60
    var progressLayer = CAShapeLayer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnReset.layer.borderWidth = 1.5
        btnReset.layer.borderColor = UIColor.white.cgColor
        
        let center = CGPoint(x: circleView.bounds.midX, y: circleView.bounds.midY)
        let radius = circleView.bounds.width / 2
        
        // ve vien tron
        progressLayer.path = UIBezierPath(arcCenter: center,
                                          radius: radius,
                                          startAngle: -CGFloat.pi / 2,
                                          endAngle: 1.5 * CGFloat.pi,
                                          clockwise:true).cgPath
        
        
        progressLayer.strokeColor = UIColor.orange.cgColor
        progressLayer.lineWidth = 4
        circleView.layer.addSublayer(progressLayer)
        circleView.bringSubviewToFront(timeLabel)
       
    }
    @IBAction func ResetTime(_ sender: Any) {
        orgSe = 25*60
        timer?.invalidate()
        timeLabel.text = "25: 00"
        btnStart.isEnabled = true
        btnStart.alpha = 1
    }
    
    
    func clickStart(){
        
        // chay 1 giay, 1 lan, voi repeat = true -> chay lap di lap lai
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        
    }
    
    @objc func updateTime(){
        
        
        if(orgSe>0) {
            orgSe-=1
            let process = 1 - CGFloat(orgSe) / CGFloat(25*60)
            progressLayer.strokeStart = process
        
            timeLabel.text = String(format: "%02d:%02d", orgSe / 60, orgSe % 60)
        } else{
            // ngung chay timer khi so giay < 0
            timer?.invalidate()
            
        }
    }
    @IBAction func btnStart(_ sender: Any) {
        
        clickStart()
        btnStart.isEnabled = false
        btnStart.alpha = 0.8
        
    }


}

