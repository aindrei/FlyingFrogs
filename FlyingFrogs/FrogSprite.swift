//
//  FrogSprite.swift
//  FlyingFrogs
//
//  Created by Claude on 12/31/25.
//

import SpriteKit

class FrogSprite: SKSpriteNode {

    // MARK: - Constants

    private let flapImpulse: CGFloat = 30
    private let maxUpwardRotation: CGFloat = .pi / 6      // 30 degrees up
    private let maxDownwardRotation: CGFloat = -.pi / 2   // 90 degrees down

    // MARK: - Initialization

    init() {
        let texture = SKTexture(imageNamed: "Frog")
        let size = CGSize(width: 50, height: 38)  // Scaled from 80x60 SVG

        super.init(texture: texture, color: .clear, size: size)

        setupPhysics()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupPhysics()
    }

    // MARK: - Setup

    private func setupPhysics() {
        // Create physics body matching sprite size
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.allowsRotation = false  // We control rotation manually
        physicsBody?.restitution = 0         // No bounce
        physicsBody?.friction = 0

        // Category bitmasks (from dev_plan.md)
        physicsBody?.categoryBitMask = PhysicsCategory.frog
        physicsBody?.contactTestBitMask = PhysicsCategory.obstacle | PhysicsCategory.ground | PhysicsCategory.scoreZone
        physicsBody?.collisionBitMask = PhysicsCategory.ground  // Only physically collide with ground
    }

    // MARK: - Actions

    func flap() {
        // Reset vertical velocity and apply upward impulse
        physicsBody?.velocity.dy = 0
        physicsBody?.applyImpulse(CGVector(dx: 0, dy: flapImpulse))
    }

    func updateRotation() {
        guard let velocity = physicsBody?.velocity else { return }

        // Map velocity to rotation
        // Rising (positive dy) = rotate up, Falling (negative dy) = rotate down
        let velocityRange: CGFloat = 600  // velocity at which we reach max rotation
        let normalizedVelocity = max(-1, min(1, velocity.dy / velocityRange))

        // Interpolate between max downward and max upward rotation
        let targetRotation: CGFloat
        if normalizedVelocity >= 0 {
            targetRotation = normalizedVelocity * maxUpwardRotation
        } else {
            targetRotation = -normalizedVelocity * maxDownwardRotation
        }

        // Smooth rotation transition
        let rotationSpeed: CGFloat = 0.15
        zRotation += (targetRotation - zRotation) * rotationSpeed
    }

    func reset(at position: CGPoint) {
        self.position = position
        zRotation = 0
        physicsBody?.velocity = .zero
        physicsBody?.isDynamic = false  // Freeze until game starts
    }

    func startPlaying() {
        physicsBody?.isDynamic = true
    }
}

// MARK: - Physics Categories

struct PhysicsCategory {
    static let frog: UInt32       = 0x1 << 0  // 1
    static let obstacle: UInt32   = 0x1 << 1  // 2
    static let ground: UInt32     = 0x1 << 2  // 4
    static let scoreZone: UInt32  = 0x1 << 3  // 8
}
