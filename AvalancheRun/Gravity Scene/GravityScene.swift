//
//  GameScene.swift
//  AvalancheRun
//
//  Created by Santiago del Castillo Gonzaga on 09/09/21.
//

import SpriteKit
import GameplayKit
import CoreMotion
import GameKit

protocol GravitySceneDelegate: AnyObject {
    func finish()
}

class GravityScene: SKScene {
    
    private let localPlayer = GKLocalPlayer.local
    private var player = SKSpriteNode(imageNamed: "Personagem")
    private var background = SKSpriteNode(imageNamed: "Cenário")
    private var avalanche = SKShapeNode(rectOf: CGSize(width: UIScreen.main.bounds.width, height: 300))
    private var cameraNode = SKCameraNode()
    private var motionManager = CMMotionManager()
    private var pointsLabel = SKLabelNode()
    private var groundsArray = [SKNode]()
    private var points: Int = 0
    private var grounds: Int = 0
    private let groundHeight = -120
    private let numberOfFutureGrounds = 10
    private let holeTranslationVariant: CGFloat = 40
    internal weak var gravitySceneDelegate: GravitySceneDelegate?
    
    override func didMove(to view: SKView) {
        createPlayer()
        configureBallMovement()
        addCamera()
        createLabel()
        createAvalanche()
        createBackground()
        
        
        for _ in 0...numberOfFutureGrounds {
            createGround()
        }
        
        physicsWorld.contactDelegate = self
    }
    
    func createBackground() {
        background.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.zPosition = -1
        addChild(background)
    }
    
    func createPlayer() {
        let playerConstraints = SKConstraint.orient(to: player, offset: SKRange(constantValue: -CGFloat.pi/2))
        player.constraints = [playerConstraints]
        player.position = CGPoint(x: (UIScreen.main.bounds.width / 2) + 50, y: 0)
        player.size = CGSize(width: 50, height: 50)
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.affectedByGravity = true
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = 0b001
        player.physicsBody?.collisionBitMask = 0b110
        player.physicsBody?.contactTestBitMask = 0b010
        player.name = "player"
        
        addChild(player)
    }
    
    func createAvalanche() {
        avalanche.position = CGPoint(x: UIScreen.main.bounds.width / 2, y: 200)
        avalanche.fillColor = SKColor.white
        avalanche.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: UIScreen.main.bounds.width, height: 300))
        avalanche.zPosition = 2
        avalanche.physicsBody?.affectedByGravity = false
        avalanche.physicsBody?.velocity = CGVector(dx: 0, dy: -100)
        avalanche.physicsBody?.applyForce(CGVector(dx: 0, dy: -20))
        avalanche.physicsBody?.categoryBitMask = 0b010
        avalanche.physicsBody?.collisionBitMask = 0b001
        avalanche.physicsBody?.contactTestBitMask = 0b001
        avalanche.name = "avalanche"
        
        addChild(avalanche)
    }
    
    func createLabel() {
        pointsLabel.fontSize = 32
        pointsLabel.fontColor = UIColor.systemPink
        pointsLabel.position.x = UIScreen.main.bounds.width / 2
        pointsLabel.position.y = 100
        pointsLabel.text = String(points)
        pointsLabel.zPosition = 3
        addChild(pointsLabel)
    }
    
    func updateLabel() {
        points += 1
        pointsLabel.text = String(points)
    }
    
    func addCamera() {
        camera = cameraNode
        cameraNode.position.x = size.width / 2
    }
    
    func createGround() {
        let translateX: CGFloat = (UIScreen.main.bounds.width / 100) * CGFloat.random(in: -1*holeTranslationVariant...holeTranslationVariant)
        let ground = SKSpriteNode(imageNamed: "Geleira1")
        ground.size = CGSize(width: 320, height: 25)
        ground.position.y = CGFloat(grounds * groundHeight)
        ground.position.x = CGFloat(360 + translateX)
        let groundPhysicBody = SKPhysicsBody(rectangleOf: ground.size)
        
        groundPhysicBody.isDynamic = false
        ground.physicsBody = groundPhysicBody
        ground.physicsBody?.categoryBitMask = 0b100
        ground.physicsBody?.collisionBitMask = 0b001
        
        let ground2 = SKSpriteNode(imageNamed: "Geleira2")
        ground2.size = CGSize(width: 320, height: 25)
        ground2.position.y = CGFloat(grounds * groundHeight)
        ground2.position.x = CGFloat(-70 + translateX)
        let ground2PhysicBody = SKPhysicsBody(rectangleOf: ground.size)
        
        ground2PhysicBody.isDynamic = false
        ground2.physicsBody = ground2PhysicBody
        ground2.physicsBody?.categoryBitMask = 0b100
        ground2.physicsBody?.collisionBitMask = 0b001
        
        addChild(ground)
        addChild(ground2)
        
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
            }
        }
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        cameraNode.position.y = player.position.y
        pointsLabel.position.y = player.position.y + 150
        background.position.y = player.position.y
        
        
        if self.player.position.x >= UIScreen.main.bounds.maxX {
            self.player.position.x = UIScreen.main.bounds.minX + 20
        }
        if self.player.position.x <= UIScreen.main.bounds.minX {
            self.player.position.x = UIScreen.main.bounds.maxX - 20
        }
        
        if Int(player.position.y) + (groundHeight * numberOfFutureGrounds) < grounds * groundHeight {
            createGround()
            updateLabel()
        }
    }
    
}

extension GravityScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        if (contact.bodyA.node?.name == "player" && contact.bodyB.node?.name == "avalanche") || (contact.bodyA.node?.name == "avalanche" && contact.bodyB.node?.name == "player") {
            print("morreu")
            
//            let score = UserDefaults.standard.integer(forKey: "highscore")
//            if score != 0 {
//                if points > score {
//                    UserDefaults.setValue(points, forKeyPath: "highscore")
//                }
//            } else {
//                UserDefaults.setValue(points, forKeyPath: "highscore")
//            }
//            
            GKLeaderboard.submitScore(points, context: 0, player: localPlayer, leaderboardIDs: ["PenguinFallRanking"], completionHandler: {[weak self]error in
                guard let self = self else { return }
                self.gravitySceneDelegate?.finish()
            })
            
        }
    }
}
