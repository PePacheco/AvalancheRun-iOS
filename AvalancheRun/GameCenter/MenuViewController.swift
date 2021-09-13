//
//  MenuViewController.swift
//  AvalancheRun
//
//  Created by Matheus Homrich on 13/09/21.
//

import UIKit
import GameKit

class MenuViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authenticateUser()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func leaderboard(_ sender: Any) {
        let vc = GKGameCenterViewController(leaderboardID: "PenguinFallRanking", playerScope: .global, timeScope: .allTime)
        vc.gameCenterDelegate = self
        present(vc, animated: true, completion: nil)
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
