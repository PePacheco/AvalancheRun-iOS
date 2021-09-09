//
//  GameScene.swift
//  AvalancheRun
//
//  Created by Pedro Gomes Rubbo Pacheco on 09/09/21.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene2: SKScene {
    
    private var ball = SKShapeNode(circleOfRadius: 10)
    private var ground: SKShapeNode = SKShapeNode(rectOf: CGSize(width: UIScreen.main.bounds.width*2, height: 100))
    private var motionManager = CMMotionManager()
    
    override func didMove(to view: SKView) {
        anchorPoint = .zero
        
        configureBall()
        configureGround()
        configurePhysics()
        configureBallMovement()
        
    }
    
    private func configureBall() {
        ball.zPosition = 1
        ball.position = CGPoint(x: frame.width/2, y: frame.height*0.16)
        self.addChild(ball)
    }
    
    private func configureGround() {
        ground.fillColor = .clear
        ground.position = CGPoint(x: 10, y: 0)
        self.addChild(ground)
        
    }
    
    private func configureBallMovement() {
        let updateRate = 1/10
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = TimeInterval(updateRate)
            motionManager.startAccelerometerUpdates(to: .main) { (data, error) in
                guard let validData = data else { return }
                
                self.ball.position.x += CGFloat(validData.acceleration.x)

                if self.ball.position.x >= UIScreen.main.bounds.maxX {
                    self.ball.position.x = UIScreen.main.bounds.minX + 10
                    print("b")
                }
                if self.ball.position.x <= UIScreen.main.bounds.minX {
                    self.ball.position.x = UIScreen.main.bounds.maxX - 10
                    print("a")
                }
            }
        }
    }
    
    private func configurePhysics() {
        let ballPhysicsBody = SKPhysicsBody(circleOfRadius: 10)
        ballPhysicsBody.affectedByGravity = true
        ball.physicsBody = ballPhysicsBody
        
        let groundPhysicsBody = SKPhysicsBody(rectangleOf: CGSize(width: ground.frame.width, height: ground.frame.height))
        groundPhysicsBody.isDynamic = false
        ground.physicsBody = groundPhysicsBody
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
