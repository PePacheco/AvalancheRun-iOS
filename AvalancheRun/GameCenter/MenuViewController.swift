//
//  MenuViewController.swift
//  AvalancheRun
//
//  Created by Matheus Homrich on 13/09/21.
//
// AD ID: ca-app-pub-8306533236766828~2513855494
// AD BANNER: ca-app-pub-8306533236766828/6137884667

import UIKit
import GameKit
import GoogleMobileAds

class MenuViewController: UIViewController {
    
    @IBOutlet var menu: UIView!
    @IBOutlet var countLabel: UILabel!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var leaderboardButton: UIButton!
    
    var banner: GADBannerView = {
        let banner = GADBannerView()
        banner.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        banner.load(GADRequest())
        banner.backgroundColor = .gray
        return banner
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authenticateUser()
        configureStyle()

        banner.rootViewController = self
        view.addSubview(banner)
        
        //banner.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        banner.frame = CGRect(x: view.frame.midX - 160, y: view.frame.size.height - 200, width: 320, height: 100).integral
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let highestScore =  UserDefaults.standard.integer(forKey: UserDefaultsValues.HIGHEST_SCORE.rawValue)
        countLabel.text = "\(highestScore)"
    }
    
    @IBAction func leaderboard(_ sender: Any) {
        let vc = GKGameCenterViewController(leaderboardID: "PenguinFallRanking", playerScope: .global, timeScope: .allTime)
        vc.gameCenterDelegate = self
        present(vc, animated: true, completion: nil)
    }
    
    func configureStyle() {
        //menu container
        self.menu.layer.cornerRadius = 8
        
        //play button
        self.playButton.layer.cornerRadius = 8
        
        //leaderboard button
        self.leaderboardButton.layer.cornerRadius = 8
    }
    
//    private func addBannerViewToView(_ bannerView: GADBannerView) {
//        bannerView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(bannerView)
//        view.addConstraints(
//            [NSLayoutConstraint(item: bannerView,
//                                attribute: .bottom,
//                                relatedBy: .equal,
//                                toItem: view.safeAreaLayoutGuide.bottomAnchor,
//                                attribute: .top,
//                                multiplier: 1,
//                                constant: 0),
//             NSLayoutConstraint(item: bannerView,
//                                attribute: .centerX,
//                                relatedBy: .equal,
//                                toItem: view,
//                                attribute: .centerX,
//                                multiplier: 1,
//                                constant: 0)
//            ])
//    }
    
    private func authenticateUser() {
        let player = GKLocalPlayer.local
        
        player.authenticateHandler = {vc, error in
            guard error == nil else {
                print(error?.localizedDescription ?? "error")
                return
            }
            
            if let vc = vc {
                self.present(vc, animated: true, completion: nil)
                
            }
        }
    }
}

extension MenuViewController: GKGameCenterControllerDelegate {
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}

//extension MenuViewController: GADBannerViewDelegate {
//    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
//        addBannerViewToView(bannerView)
//        print("aparecer")
//    }
//
//    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
//        print(error)
//    }
//}
