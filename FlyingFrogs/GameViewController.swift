//
//  GameViewController.swift
//  FlyingFrogs
//
//  Created by Alexandru Indrei on 12/31/25.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.view as! SKView? {
            // Create scene programmatically with view size
            let scene = GameScene(size: view.bounds.size)
            scene.scaleMode = .aspectFill
            scene.backgroundColor = SKColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0)  // Sky blue

            // Present the scene
            view.presentScene(scene)

            view.ignoresSiblingOrder = true

            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
