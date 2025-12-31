//
//  GameScene.swift
//  FlyingFrogs
//
//  Created by Alexandru Indrei on 12/31/25.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    // MARK: - Properties

    private var frog: FrogSprite!
    private var ground: SKSpriteNode!
    private var ceiling: SKSpriteNode!

    private var isGameActive = false
    private var isGameOver = false

    // MARK: - Scene Lifecycle

    override func didMove(to view: SKView) {
        setupPhysicsWorld()
        setupBoundaries()
        setupFrog()
        setupInstructions()
    }

    // MARK: - Setup

    private func setupPhysicsWorld() {
        physicsWorld.gravity = CGVector(dx: 0, dy: -12)
        physicsWorld.contactDelegate = self
    }

    private func setupBoundaries() {
        let boundaryHeight: CGFloat = 20

        // Ground
        ground = SKSpriteNode(color: SKColor(red: 0.4, green: 0.25, blue: 0.1, alpha: 1.0),
                              size: CGSize(width: size.width, height: boundaryHeight))
        ground.position = CGPoint(x: size.width / 2, y: boundaryHeight / 2)
        ground.zPosition = 10

        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = PhysicsCategory.ground
        ground.physicsBody?.contactTestBitMask = PhysicsCategory.frog

        addChild(ground)

        // Ceiling (invisible)
        ceiling = SKSpriteNode(color: .clear,
                               size: CGSize(width: size.width, height: boundaryHeight))
        ceiling.position = CGPoint(x: size.width / 2, y: size.height - boundaryHeight / 2)

        ceiling.physicsBody = SKPhysicsBody(rectangleOf: ceiling.size)
        ceiling.physicsBody?.isDynamic = false
        ceiling.physicsBody?.categoryBitMask = PhysicsCategory.ground  // Same as ground for collision
        ceiling.physicsBody?.contactTestBitMask = PhysicsCategory.frog

        addChild(ceiling)
    }

    private func setupFrog() {
        frog = FrogSprite()
        frog.position = CGPoint(x: size.width * 0.3, y: size.height / 2)
        frog.zPosition = 5
        addChild(frog)

        // Start frozen until player taps
        frog.reset(at: frog.position)
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
        // Handle restart first
        if canRestart {
            restartGame()
            return
        }

        // Ignore input during game over
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

        // Remove instructions
        if let instructions = childNode(withName: "instructions") {
            instructions.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.3),
                SKAction.removeFromParent()
            ]))
        }
    }

    private func gameOver() {
        isGameActive = false
        isGameOver = true
        frog.physicsBody?.isDynamic = false

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

        // Show game over and restart prompt
        let gameOverLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 40
        gameOverLabel.fontColor = .white
        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 30)
        gameOverLabel.zPosition = 20
        gameOverLabel.name = "gameOver"
        addChild(gameOverLabel)

        let restartLabel = SKLabelNode(fontNamed: "Helvetica")
        restartLabel.text = "Tap to Restart"
        restartLabel.fontSize = 22
        restartLabel.fontColor = .white
        restartLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 20)
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

    private var canRestart = false

    private func allowRestart() {
        canRestart = true
    }

    private func restartGame() {
        canRestart = false
        isGameOver = false

        // Remove game over labels
        enumerateChildNodes(withName: "gameOver") { node, _ in
            node.removeFromParent()
        }

        // Reset frog
        frog.reset(at: CGPoint(x: size.width * 0.3, y: size.height / 2))

        // Show instructions again
        setupInstructions()
    }

    // MARK: - Physics Contact

    func didBegin(_ contact: SKPhysicsContact) {
        guard isGameActive else { return }

        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        // Frog hit ground or ceiling
        if collision & PhysicsCategory.frog != 0 && collision & PhysicsCategory.ground != 0 {
            gameOver()
        }
    }

    // MARK: - Game Loop

    override func update(_ currentTime: TimeInterval) {
        if isGameActive {
            frog.updateRotation()
        }
    }
}
