//
//  GameViewController.swift
//  Tetris
//
//  Created by Braun Shedd on 9/16/18.
//  Copyright © 2018 Valley Tutoring. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

	var scene: GameScene!
    var tetris: Tetris!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Configure the view.
		let skView = view as! SKView
		skView.isMultipleTouchEnabled = false
		
		// Create and configure the scene.
		scene = GameScene(size: skView.bounds.size)
		scene.scaleMode = .aspectFill
		
        scene.tick = didTick;
        tetris = Tetris()
        tetris.beginGame()
        
		// Present the scene.
		skView.presentScene(scene)
        scene.addPreviewShapeToScene(shape: tetris.nextShape!) {
            self.tetris.nextShape?.moveTo(column: StartingColumn, row: StartingRow)
            self.scene.movePreviewShape(shape: self.tetris.nextShape!){
                let nextShape = self.tetris.newShape()
                self.scene.startTicking()
                self.scene.addPreviewShapeToScene(shape: nextShape.nextShape!, completion: {})
            }
        }
    }
	
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func didTick(){
        tetris.fallingShape?.lowerShapeByOneRow()
        scene.redrawShape(tetris.fallingShape!){}
    }
}

