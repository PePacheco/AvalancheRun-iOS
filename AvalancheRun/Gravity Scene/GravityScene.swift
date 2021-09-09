//
//  GameScene.swift
//  AvalancheRun
//
//  Created by Pedro Gomes Rubbo Pacheco on 09/09/21.
//

import SpriteKit
import GameplayKit

class GravityScene: SKScene {
    
    private var player = SKShapeNode(circleOfRadius: 30)
    private var cameraNode = SKCameraNode()
    private var ground = SKShapeNode(rectOf: CGSize(width: 1000, height: 100))
    
    
    override func didMove(to view: SKView) {
        // Get label node from scene and store it for use later=
        createPlayer()
        addCamera()
        createGround()
    }
    
    func createPlayer() {
        player.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        player.strokeColor = SKColor.black
        player.glowWidth = 1.0
        player.fillColor = SKColor.orange
        player.physicsBody = SKPhysicsBody(circleOfRadius: 30)
//        player.physicsBody?.applyForce(CGVector(dx: 0, dy: -20))
        player.physicsBody?.affectedByGravity = true
        player.physicsBody?.isDynamic = true
        
        addChild(player)
    }
    
    func addCamera() {
        camera = cameraNode
//        cameraNode.position.x = size.width / 2
    }
    
    func createGround() {
        ground.position.y = -1300
        ground.position.x = 150
        ground.strokeColor = SKColor.black
        ground.glowWidth = 1.0
        ground.fillColor = SKColor.orange
        let groundPhysicBody = SKPhysicsBody(rectangleOf: self.ground.frame.size)
      
        groundPhysicBody.isDynamic = false
        ground.physicsBody = groundPhysicBody
        addChild(ground)
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        cameraNode.position = player.position
        
    }
}
