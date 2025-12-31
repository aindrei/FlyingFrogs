//
//  ObstaclePair.swift
//  FlyingFrogs
//
//  Created by Claude on 12/31/25.
//

import SpriteKit

class ObstaclePair: SKNode {

    // MARK: - Constants

    private let obstacleWidth: CGFloat = 60
    private let gapHeight: CGFloat = 180

    // MARK: - Properties

    let topObstacle: SKSpriteNode
    let bottomObstacle: SKSpriteNode
    let scoreZone: SKNode

    private(set) var passed = false

    // MARK: - Initialization

    init(sceneHeight: CGFloat, gapCenterY: CGFloat) {
        // Calculate obstacle heights based on gap position
        let bottomHeight = gapCenterY - gapHeight / 2
        let topHeight = sceneHeight - (gapCenterY + gapHeight / 2)

        // Create bottom obstacle with texture
        let bottomTexture = SKTexture(imageNamed: "ObstacleBottom")
        bottomObstacle = SKSpriteNode(texture: bottomTexture,
                                       size: CGSize(width: obstacleWidth, height: bottomHeight))
        bottomObstacle.anchorPoint = CGPoint(x: 0.5, y: 0)
        bottomObstacle.position = CGPoint(x: 0, y: 0)

        // Create top obstacle with texture
        let topTexture = SKTexture(imageNamed: "ObstacleTop")
        topObstacle = SKSpriteNode(texture: topTexture,
                                    size: CGSize(width: obstacleWidth, height: topHeight))
        topObstacle.anchorPoint = CGPoint(x: 0.5, y: 1)
        topObstacle.position = CGPoint(x: 0, y: sceneHeight)

        // Create invisible score zone in the gap
        scoreZone = SKNode()
        scoreZone.position = CGPoint(x: 0, y: gapCenterY)

        super.init()

        addChild(bottomObstacle)
        addChild(topObstacle)
        addChild(scoreZone)

        setupPhysics(sceneHeight: sceneHeight, bottomHeight: bottomHeight, topHeight: topHeight)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupPhysics(sceneHeight: CGFloat, bottomHeight: CGFloat, topHeight: CGFloat) {
        // Bottom obstacle physics
        bottomObstacle.physicsBody = SKPhysicsBody(rectangleOf: bottomObstacle.size,
                                                    center: CGPoint(x: 0, y: bottomHeight / 2))
        bottomObstacle.physicsBody?.isDynamic = false
        bottomObstacle.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        bottomObstacle.physicsBody?.contactTestBitMask = PhysicsCategory.frog

        // Top obstacle physics
        topObstacle.physicsBody = SKPhysicsBody(rectangleOf: topObstacle.size,
                                                 center: CGPoint(x: 0, y: -topHeight / 2))
        topObstacle.physicsBody?.isDynamic = false
        topObstacle.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        topObstacle.physicsBody?.contactTestBitMask = PhysicsCategory.frog

        // Score zone physics (thin vertical line in the gap)
        let scoreZoneSize = CGSize(width: 2, height: gapHeight)
        scoreZone.physicsBody = SKPhysicsBody(rectangleOf: scoreZoneSize)
        scoreZone.physicsBody?.isDynamic = false
        scoreZone.physicsBody?.categoryBitMask = PhysicsCategory.scoreZone
        scoreZone.physicsBody?.contactTestBitMask = PhysicsCategory.frog
    }

    // MARK: - Methods

    func markAsPassed() {
        passed = true
    }
}
