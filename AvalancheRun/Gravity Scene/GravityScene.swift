//
//  GameScene.swift
//  AvalancheRun
//
//  Created by Pedro Gomes Rubbo Pacheco on 09/09/21.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GravityScene: SKScene {
    
    private var player = SKShapeNode(circleOfRadius: 15)
    private var cameraNode = SKCameraNode()
    private var motionManager = CMMotionManager()
    private var pointsLabel = SKLabelNode()
    private var groundsArray = [SKNode]()
    private var points: Int = 0
    private var grounds: Int = 0
    private let groundHeight = -120
    private let numberOfFutureGrounds = 10
    
    override func didMove(to view: SKView) {
        createPlayer()
        configureBallMovement()
        addCamera()
        createLabel()
        
        for _ in 0...numberOfFutureGrounds {
            createGround()
        }
    }
    
    func createPlayer() {
        player.position = CGPoint(x: 0, y: 0)
        player.strokeColor = SKColor.black
        player.glowWidth = 1.0
        player.fillColor = SKColor.orange
        player.physicsBody = SKPhysicsBody(circleOfRadius: 15)
        player.physicsBody?.affectedByGravity = true
        player.physicsBody?.isDynamic = true
        
        addChild(player)
    }
    
    func createLabel() {
        pointsLabel.fontSize = 32
        pointsLabel.fontColor = UIColor.systemPink
        pointsLabel.position.x = 0
        pointsLabel.position.y = 100
        pointsLabel.text = String(points)
    }
    
    func updateLabel() {
        pointsLabel.text = String(points)
        pointsLabel.position.y = CGFloat(100 + grounds * groundHeight)
    }
    
    func addCamera() {
        camera = cameraNode
        cameraNode.position.x = size.width / 2
    }
    
    func createGround() {
        let ground = SKShapeNode(rectOf: CGSize(width: 200, height: 25))
        ground.position.y = CGFloat(grounds * groundHeight)
        ground.position.x = 150
        ground.strokeColor = SKColor.black
        ground.glowWidth = 1.0
        ground.fillColor = SKColor.orange
        let groundPhysicBody = SKPhysicsBody(rectangleOf: ground.frame.size)
        
        groundPhysicBody.isDynamic = false
        ground.physicsBody = groundPhysicBody
        addChild(ground)
        
        grounds += 1
        groundsArray.append(ground)
        
        if groundsArray.count == 20 {
            let removedGround = groundsArray.removeFirst()
            removedGround.removeFromParent()
        }
    }
    
    private func configureBallMovement() {
        let updateRate = 1/10
        
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = TimeInterval(updateRate)
            motionManager.startAccelerometerUpdates(to: .main) { (data, error) in
                guard let validData = data else { return }
                
                self.player.position.x += CGFloat(validData.acceleration.x * 15)
                
                if self.player.position.x >= UIScreen.main.bounds.maxX {
                    self.player.position.x = UIScreen.main.bounds.minX + 10
                }
                if self.player.position.x <= UIScreen.main.bounds.minX {
                    self.player.position.x = UIScreen.main.bounds.maxX - 10
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        cameraNode.position.y = player.position.y
        
        if Int(player.position.y) + (groundHeight * numberOfFutureGrounds) < grounds * groundHeight {
            createGround()
        }
    }
}
