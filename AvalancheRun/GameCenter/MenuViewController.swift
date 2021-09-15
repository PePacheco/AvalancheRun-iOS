//
//  MenuViewController.swift
//  AvalancheRun
//
//  Created by Matheus Homrich on 13/09/21.
//

import UIKit
import GameKit

class MenuViewController: UIViewController {
    
    @IBOutlet var menu: UIView!
    @IBOutlet var countLabel: UILabel!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var leaderboardButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authenticateUser()
        configureStyle()
        // Do any additional setup after loading the view.
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
