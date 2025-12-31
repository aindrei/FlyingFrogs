//
//  GameScene.swift
//  FlyingFrogs
//
//  Created by Alexandru Indrei on 12/31/25.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    // MARK: - Constants

    private let scrollSpeed: CGFloat = 150        // Points per second
    private let obstacleSpawnInterval: TimeInterval = 2.0
    private let groundHeight: CGFloat = 60
    private let highScoreKey = "FlyingFrogsHighScore"

    // Parallax speeds (multiplier of base scroll speed)
    private let cloudsParallaxSpeed: CGFloat = 0.1
    private let hillsParallaxSpeed: CGFloat = 0.3

    // MARK: - Properties

    private var frog: FrogSprite!
    private var groundPair: (SKSpriteNode, SKSpriteNode)!
    private var ceiling: SKSpriteNode!
    private var scoreLabel: SKLabelNode!

    // Parallax background layers
    private var cloudsPair: (SKSpriteNode, SKSpriteNode)!
    private var hillsPair: (SKSpriteNode, SKSpriteNode)!

    private var isGameActive = false
    private var isGameOver = false
    private var canRestart = false

    private var score = 0
    private var highScore: Int {
        get { UserDefaults.standard.integer(forKey: highScoreKey) }
        set { UserDefaults.standard.set(newValue, forKey: highScoreKey) }
    }

    // MARK: - Scene Lifecycle

    override func didMove(to view: SKView) {
        setupPhysicsWorld()
        setupBackground()
        setupScrollingGround()
        setupCeiling()
        setupFrog()
        setupScoreLabel()
        setupInstructions()
    }

    // MARK: - Setup

    private func setupPhysicsWorld() {
        physicsWorld.gravity = CGVector(dx: 0, dy: -12)
        physicsWorld.contactDelegate = self
    }

    private func setupBackground() {
        // Sky gradient background (static)
        let skyTexture = SKTexture(imageNamed: "BackgroundSky")
        let sky = SKSpriteNode(texture: skyTexture, size: size)
        sky.position = CGPoint(x: size.width / 2, y: size.height / 2)
        sky.zPosition = -10
        addChild(sky)

        // Clouds layer (slow parallax)
        let cloudsTexture = SKTexture(imageNamed: "BackgroundClouds")
        let cloudsHeight = size.height * 0.5
        let cloudsWidth = size.width * 1.5  // Wider for seamless scrolling

        let clouds1 = SKSpriteNode(texture: cloudsTexture,
                                    size: CGSize(width: cloudsWidth, height: cloudsHeight))
        clouds1.anchorPoint = CGPoint(x: 0, y: 0)
        clouds1.position = CGPoint(x: 0, y: size.height * 0.4)
        clouds1.zPosition = -8

        let clouds2 = SKSpriteNode(texture: cloudsTexture,
                                    size: CGSize(width: cloudsWidth, height: cloudsHeight))
        clouds2.anchorPoint = CGPoint(x: 0, y: 0)
        clouds2.position = CGPoint(x: cloudsWidth, y: size.height * 0.4)
        clouds2.zPosition = -8

        addChild(clouds1)
        addChild(clouds2)
        cloudsPair = (clouds1, clouds2)

        // Hills layer (medium parallax)
        let hillsTexture = SKTexture(imageNamed: "BackgroundHills")
        let hillsHeight: CGFloat = 150
        let hillsWidth = size.width * 1.5

        let hills1 = SKSpriteNode(texture: hillsTexture,
                                   size: CGSize(width: hillsWidth, height: hillsHeight))
        hills1.anchorPoint = CGPoint(x: 0, y: 0)
        hills1.position = CGPoint(x: 0, y: groundHeight)
        hills1.zPosition = -5

        let hills2 = SKSpriteNode(texture: hillsTexture,
                                   size: CGSize(width: hillsWidth, height: hillsHeight))
        hills2.anchorPoint = CGPoint(x: 0, y: 0)
        hills2.position = CGPoint(x: hillsWidth, y: groundHeight)
        hills2.zPosition = -5

        addChild(hills1)
        addChild(hills2)
        hillsPair = (hills1, hills2)
    }

    private func setupScrollingGround() {
        // Create two ground sprites for seamless scrolling with texture
        let groundTexture = SKTexture(imageNamed: "GroundTexture")

        let ground1 = SKSpriteNode(texture: groundTexture,
                                   size: CGSize(width: size.width, height: groundHeight))
        ground1.anchorPoint = CGPoint(x: 0, y: 0)
        ground1.position = CGPoint(x: 0, y: 0)
        ground1.zPosition = 10
        ground1.name = "ground"

        let ground2 = SKSpriteNode(texture: groundTexture,
                                   size: CGSize(width: size.width, height: groundHeight))
        ground2.anchorPoint = CGPoint(x: 0, y: 0)
        ground2.position = CGPoint(x: size.width, y: 0)
        ground2.zPosition = 10
        ground2.name = "ground"

        addChild(ground1)
        addChild(ground2)

        groundPair = (ground1, ground2)

        // Add physics to ground (single body spanning screen)
        let groundBody = SKNode()
        groundBody.position = CGPoint(x: size.width / 2, y: groundHeight / 2)
        groundBody.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: groundHeight))
        groundBody.physicsBody?.isDynamic = false
        groundBody.physicsBody?.categoryBitMask = PhysicsCategory.ground
        groundBody.physicsBody?.contactTestBitMask = PhysicsCategory.frog
        addChild(groundBody)
    }

    private func setupCeiling() {
        let ceilingHeight: CGFloat = 20
        ceiling = SKSpriteNode(color: .clear,
                               size: CGSize(width: size.width, height: ceilingHeight))
        ceiling.position = CGPoint(x: size.width / 2, y: size.height - ceilingHeight / 2)

        ceiling.physicsBody = SKPhysicsBody(rectangleOf: ceiling.size)
        ceiling.physicsBody?.isDynamic = false
        ceiling.physicsBody?.categoryBitMask = PhysicsCategory.ground
        ceiling.physicsBody?.contactTestBitMask = PhysicsCategory.frog

        addChild(ceiling)
    }

    private func setupFrog() {
        frog = FrogSprite()
        frog.position = CGPoint(x: size.width * 0.3, y: size.height / 2)
        frog.zPosition = 5
        addChild(frog)

        frog.reset(at: frog.position)
    }

    private func setupScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        scoreLabel.text = "0"
        scoreLabel.fontSize = 48
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 80)
        scoreLabel.zPosition = 20
        scoreLabel.alpha = 0  // Hidden until game starts
        addChild(scoreLabel)
    }

    private func setupInstructions() {
        let label = SKLabelNode(fontNamed: "Helvetica-Bold")
        label.text = "Tap to Flap!"
        label.fontSize = 28
        label.fontColor = .white
        label.position = CGPoint(x: size.width / 2, y: size.height * 0.7)
        label.zPosition = 20
        label.name = "instructions"
        addChild(label)
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if canRestart {
            restartGame()
            return
        }

        if isGameOver {
            return
        }

        if !isGameActive {
            startGame()
        }
        frog.flap()
    }

    // MARK: - Game State

    private func startGame() {
        isGameActive = true
        frog.startPlaying()

        // Show score label
        scoreLabel.alpha = 1

        // Remove instructions
        if let instructions = childNode(withName: "instructions") {
            instructions.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.3),
                SKAction.removeFromParent()
            ]))
        }

        // Start spawning obstacles
        startSpawningObstacles()
    }

    private func startSpawningObstacles() {
        let spawn = SKAction.run { [weak self] in
            self?.spawnObstacle()
        }
        let wait = SKAction.wait(forDuration: obstacleSpawnInterval)
        let sequence = SKAction.sequence([spawn, wait])
        let repeatForever = SKAction.repeatForever(sequence)

        run(repeatForever, withKey: "spawnObstacles")
    }

    private func spawnObstacle() {
        // Calculate safe gap range (avoid ground and ceiling)
        let minGapY = groundHeight + 120
        let maxGapY = size.height - 120

        // Random gap center position
        let gapCenterY = CGFloat.random(in: minGapY...maxGapY)

        let obstacle = ObstaclePair(sceneHeight: size.height, gapCenterY: gapCenterY)
        obstacle.position = CGPoint(x: size.width + 30, y: 0)
        obstacle.zPosition = 3
        obstacle.name = "obstacle"
        addChild(obstacle)

        // Move obstacle left and remove when off-screen
        let moveDistance = size.width + 100
        let moveDuration = moveDistance / scrollSpeed

        let moveAction = SKAction.moveBy(x: -moveDistance, y: 0, duration: moveDuration)
        let removeAction = SKAction.removeFromParent()
        obstacle.run(SKAction.sequence([moveAction, removeAction]))
    }

    private func stopSpawningObstacles() {
        removeAction(forKey: "spawnObstacles")
    }

    private func removeAllObstacles() {
        enumerateChildNodes(withName: "obstacle") { node, _ in
            node.removeFromParent()
        }
    }

    private func gameOver() {
        isGameActive = false
        isGameOver = true
        frog.physicsBody?.isDynamic = false

        stopSpawningObstacles()

        // Stop all obstacle movement
        enumerateChildNodes(withName: "obstacle") { node, _ in
            node.removeAllActions()
        }

        // Update high score if needed
        let isNewHighScore = score > highScore
        if isNewHighScore {
            highScore = score
        }

        // Flash screen red briefly
        let flash = SKSpriteNode(color: .red, size: size)
        flash.position = CGPoint(x: size.width / 2, y: size.height / 2)
        flash.zPosition = 100
        flash.alpha = 0.4
        addChild(flash)

        flash.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ]))

        // Show game over and score
        let gameOverLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 40
        gameOverLabel.fontColor = .white
        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 60)
        gameOverLabel.zPosition = 20
        gameOverLabel.name = "gameOver"
        addChild(gameOverLabel)

        let scoreResultLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        scoreResultLabel.text = "Score: \(score)"
        scoreResultLabel.fontSize = 28
        scoreResultLabel.fontColor = .white
        scoreResultLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 15)
        scoreResultLabel.zPosition = 20
        scoreResultLabel.name = "gameOver"
        addChild(scoreResultLabel)

        let highScoreLabel = SKLabelNode(fontNamed: "Helvetica")
        highScoreLabel.text = isNewHighScore ? "New Best: \(highScore)!" : "Best: \(highScore)"
        highScoreLabel.fontSize = 22
        highScoreLabel.fontColor = isNewHighScore ? SKColor.yellow : SKColor.white
        highScoreLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 20)
        highScoreLabel.zPosition = 20
        highScoreLabel.name = "gameOver"
        addChild(highScoreLabel)

        let restartLabel = SKLabelNode(fontNamed: "Helvetica")
        restartLabel.text = "Tap to Restart"
        restartLabel.fontSize = 22
        restartLabel.fontColor = .white
        restartLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 60)
        restartLabel.zPosition = 20
        restartLabel.name = "gameOver"
        addChild(restartLabel)

        // Wait then allow restart
        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.run { [weak self] in
                self?.allowRestart()
            }
        ]))
    }

    private func allowRestart() {
        canRestart = true
    }

    private func restartGame() {
        canRestart = false
        isGameOver = false

        // Reset score
        score = 0
        scoreLabel.text = "0"
        scoreLabel.alpha = 0  // Hide until game starts

        // Remove game over labels
        enumerateChildNodes(withName: "gameOver") { node, _ in
            node.removeFromParent()
        }

        // Remove all obstacles
        removeAllObstacles()

        // Reset ground positions
        groundPair.0.position = CGPoint(x: 0, y: 0)
        groundPair.1.position = CGPoint(x: size.width, y: 0)

        // Reset parallax layers
        let cloudsWidth = cloudsPair.0.size.width
        cloudsPair.0.position.x = 0
        cloudsPair.1.position.x = cloudsWidth

        let hillsWidth = hillsPair.0.size.width
        hillsPair.0.position.x = 0
        hillsPair.1.position.x = hillsWidth

        // Reset frog
        frog.reset(at: CGPoint(x: size.width * 0.3, y: size.height / 2))

        // Show instructions again
        setupInstructions()
    }

    // MARK: - Physics Contact

    func didBegin(_ contact: SKPhysicsContact) {
        guard isGameActive else { return }

        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        // Frog hit ground, ceiling, or obstacle
        if collision & PhysicsCategory.frog != 0 {
            if collision & PhysicsCategory.ground != 0 || collision & PhysicsCategory.obstacle != 0 {
                gameOver()
            } else if collision & PhysicsCategory.scoreZone != 0 {
                // Find the obstacle pair and mark as passed
                let scoreZoneNode = contact.bodyA.categoryBitMask == PhysicsCategory.scoreZone
                    ? contact.bodyA.node : contact.bodyB.node

                if let obstaclePair = scoreZoneNode?.parent as? ObstaclePair, !obstaclePair.passed {
                    obstaclePair.markAsPassed()
                    incrementScore()
                }
            }
        }
    }

    // MARK: - Scoring

    private func incrementScore() {
        score += 1
        scoreLabel.text = "\(score)"

        // Brief scale animation for feedback
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        scoreLabel.run(SKAction.sequence([scaleUp, scaleDown]))
    }

    // MARK: - Game Loop

    override func update(_ currentTime: TimeInterval) {
        guard isGameActive else { return }

        frog.updateRotation()
        updateScrollingGround()
        updateParallaxLayers()
    }

    private func updateScrollingGround() {
        let deltaX = scrollSpeed / 60.0  // Approximate for 60 FPS

        // Move both ground sprites
        groundPair.0.position.x -= deltaX
        groundPair.1.position.x -= deltaX

        // Wrap around when off-screen
        if groundPair.0.position.x <= -size.width {
            groundPair.0.position.x = groundPair.1.position.x + size.width
        }
        if groundPair.1.position.x <= -size.width {
            groundPair.1.position.x = groundPair.0.position.x + size.width
        }
    }

    private func updateParallaxLayers() {
        let baseSpeed = scrollSpeed / 60.0

        // Scroll clouds (slowest)
        let cloudsSpeed = baseSpeed * cloudsParallaxSpeed
        let cloudsWidth = cloudsPair.0.size.width

        cloudsPair.0.position.x -= cloudsSpeed
        cloudsPair.1.position.x -= cloudsSpeed

        if cloudsPair.0.position.x <= -cloudsWidth {
            cloudsPair.0.position.x = cloudsPair.1.position.x + cloudsWidth
        }
        if cloudsPair.1.position.x <= -cloudsWidth {
            cloudsPair.1.position.x = cloudsPair.0.position.x + cloudsWidth
        }

        // Scroll hills (medium speed)
        let hillsSpeed = baseSpeed * hillsParallaxSpeed
        let hillsWidth = hillsPair.0.size.width

        hillsPair.0.position.x -= hillsSpeed
        hillsPair.1.position.x -= hillsSpeed

        if hillsPair.0.position.x <= -hillsWidth {
            hillsPair.0.position.x = hillsPair.1.position.x + hillsWidth
        }
        if hillsPair.1.position.x <= -hillsWidth {
            hillsPair.1.position.x = hillsPair.0.position.x + hillsWidth
        }
    }
}
