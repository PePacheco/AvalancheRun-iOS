//
//  GameViewController.swift
//  AvalancheRun
//
//  Created by Pedro Gomes Rubbo Pacheco on 09/09/21.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            let scene = GravityScene(size: view.bounds.size)
            scene.scaleMode = .resizeFill
            scene.gravitySceneDelegate = self
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
        }
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
}

extension GameViewController: GravitySceneDelegate {
    func finish() {
        navigationController?.popViewController(animated: true)
    }
}
