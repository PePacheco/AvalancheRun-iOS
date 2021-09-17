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

struct Avalanche {
    static let height: CGFloat = 600
    static let initialPosition: CGFloat = 550
    static let force: CGFloat = -40
}

class GravityScene: SKScene {
    private let localPlayer = GKLocalPlayer.local
    private var player = SKSpriteNode(imageNamed: "Personagem")
    private var background = SKSpriteNode(imageNamed: "Cenário")
    private var avalancheContainer = SKNode()
    let avalancheBottom = SKSpriteNode(imageNamed: "Avalanche")
    private var avalanche = SKShapeNode(rectOf: CGSize(width: UIScreen.main.bounds.width, height: Avalanche.height))
    private var cameraNode = SKCameraNode()
    private var motionManager = CMMotionManager()
    private var pointsLabel = SKLabelNode()
    private var groundsArray = [SKNode]()
    private var points: Int = 0
    private var grounds: Int = 0
    private let groundHeight = -120
    private let numberOfFutureGrounds = 10
    private let holeTranslationVariant: CGFloat = 40
    private var oldCurrentTime: Double = -1
    internal weak var gravitySceneDelegate: GravitySceneDelegate?
    private var worldNode: SKNode = SKNode()
    
    override func didMove(to view: SKView) {
        
        
        
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(willResignActivity), name: UIScene.willDeactivateNotification, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(willResignActivity), name: UIApplication.willResignActiveNotification, object: nil)
        }
        
        //        if #available(iOS 13.0, *) {
        //            NotificationCenter.default.addObserver(self, selector: #selector(willRestartActivity), name: UIScene.willEnterForegroundNotification, object: nil)
        //        } else {
        //            NotificationCenter.default.addObserver(self, selector: #selector(willRestartActivity), name: UIApplication.willEnterForegroundNotification, object: nil)
        //        }
        
        
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
    
    @objc func willResignActivity() {
        self.gravitySceneDelegate?.finish()
    }
    
    //    @objc func willRestartActivity() {
    //
    //    }
    
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
        player.size = CGSize(width: 72 * 0.8, height: 57 * 0.8)
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
        //container
        
        avalancheContainer.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1, height: 1))
        avalancheContainer.physicsBody?.affectedByGravity = false
        avalancheContainer.physicsBody?.isDynamic = false
        avalancheContainer.physicsBody?.velocity = CGVector(dx: 0, dy: -100)
        avalancheContainer.physicsBody?.categoryBitMask = 0b1000
        avalancheContainer.physicsBody?.collisionBitMask = 0b1000
        
        //body
        avalanche.position = CGPoint(x: UIScreen.main.bounds.width / 2, y: Avalanche.initialPosition)
        avalanche.fillColor = SKColor.white
        avalanche.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: UIScreen.main.bounds.width, height: Avalanche.height))
        avalanche.zPosition = 2
        avalanche.physicsBody?.affectedByGravity = false
        avalanche.physicsBody?.isDynamic = false
        avalanche.physicsBody?.categoryBitMask = 0b010
        avalanche.physicsBody?.collisionBitMask = 0b001
        avalanche.physicsBody?.contactTestBitMask = 0b001
        avalanche.name = "avalanche"
        
        //bottom
        
        avalancheBottom.size.width = UIScreen.main.bounds.width + 50
        avalancheBottom.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: UIScreen.main.bounds.width, height: 20))
        avalancheBottom.position.y = Avalanche.initialPosition - (Avalanche.height / 2)
        avalancheBottom.position.x = UIScreen.main.bounds.width / 2
        avalancheBottom.zPosition = 3
        avalancheBottom.physicsBody?.affectedByGravity = false
        avalancheBottom.physicsBody?.isDynamic = false
        avalancheBottom.physicsBody?.categoryBitMask = 0b1000
        avalancheBottom.physicsBody?.collisionBitMask = 0b1000
        
        avalancheContainer.addChild(avalanche)
        avalancheContainer.addChild(avalancheBottom)
        addChild(avalancheContainer)
    }
    
    func createLabel() {
        pointsLabel.fontSize = 32
        pointsLabel.fontColor = UIColor.black
        pointsLabel.position.x = UIScreen.main.bounds.width / 2
        pointsLabel.position.y = 100
        pointsLabel.text = String(points)
        pointsLabel.zPosition = 4
        pointsLabel.fontName = "AvenirNext-Bold"
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
    
    private func updateAvalanchePosition(_ deltaTime: TimeInterval) {
        if avalancheContainer.position.y + CGFloat(Avalanche.height / 2) - cameraNode.position.y > UIScreen.main.bounds.height / 2 {
            avalancheContainer.position.y = cameraNode.position.y + ((UIScreen.main.bounds.height - Avalanche.height) / 2)
        }
        
        avalancheContainer.position.y -= CGFloat(deltaTime * (70 + Double(points)))
    }
    
    override func update(_ currentTime: TimeInterval) {
        if oldCurrentTime == -1 {
            oldCurrentTime = currentTime
        }
        
        let deltaTime = currentTime - oldCurrentTime
        oldCurrentTime = currentTime
        updateAvalanchePosition(deltaTime)
        
        cameraNode.position.y = player.position.y
        pointsLabel.position.y = player.position.y + 150
        background.position.y = player.position.y
        
        if self.player.position.x > UIScreen.main.bounds.maxX {
            self.player.position.x = UIScreen.main.bounds.minX + 10
        }
        if self.player.position.x < UIScreen.main.bounds.minX {
            self.player.position.x = UIScreen.main.bounds.maxX - 10
        }
        
        if Int(player.position.y) + (groundHeight * numberOfFutureGrounds) < grounds * groundHeight {
            createGround()
            updateLabel()
        }
    }
}

extension GravityScene: SKPhysicsContactDelegate {
    
    private func handleSetScore() {
        let score = UserDefaults.standard.integer(forKey: UserDefaultsValues.HIGHEST_SCORE.rawValue)
        if points > score {
            UserDefaults.standard.set(points, forKey: UserDefaultsValues.HIGHEST_SCORE.rawValue)
        }
    }
    
    private func handleGameEnd() {
        handleSetScore()
        GKLeaderboard.submitScore(
            points,
            context: 0,
            player: localPlayer,
            leaderboardIDs: ["PenguinFallRanking"],
            completionHandler: { [weak self] error in
                guard let self = self else { return }
                sleep(1)
                self.gravitySceneDelegate?.finish()
            })
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if (contact.bodyA.node?.name == "player" && contact.bodyB.node?.name == "avalanche") || (contact.bodyA.node?.name == "avalanche" && contact.bodyB.node?.name == "player") {
            handleGameEnd()
        }
    }
}
