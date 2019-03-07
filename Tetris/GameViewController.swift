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

class GameViewController: UIViewController, TetrisDelegate, UITapGestureRecognizer {

	var scene: GameScene!
    var tetris: Tetris!
    var panPointReference: CGPoint?
	
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
        tetris.delegate = self
        tetris.beginGame()
        
		// Present the scene.
		skView.presentScene(scene)
    }
	
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func didSwipe(_ sender: UISwipeGestureRecognizer) {
        tetris.dropShape()
    }
    func gestureRecognizer() -> Bool {
        return true
    }
    func gestureRecognizer() -> Bool {
        
    }
    @IBAction func didTap(_ sender: UITapGestureRecognizer) {
        tetris.rotateShape()
    }
    
    @IBAction func didPan(_ sender: UIPanGestureRecognizer) {
        let currentPoint = sender.translationInView(self.view)
        if let originalPoint = panPointReference {
            if abs(currentPoint.x - originalPoint.x) > (BlockSize * 0.9){
                if sender.velocityInView(self.view).x > CGFloat(0){
                    tetris.moveShapeRight()
                    panPointReference = currentPoint
                }
                else{
                    tetris.moveShapeLeft()
                    panPointReference = currentPoint
                }
            }
        }
        else if sender.state == .Began{
            panPointReference = currentPoint
        }
    }
    func didTick(){
        tetris.letShapeFall()
        tetris.fallingShape?.lowerShapeByOneRow()
        scene.redrawShape(tetris.fallingShape!, {})
    }
    func nextShape(){
        let newShape = tetris.nextShape()
        guard let fallingShape = newShape.fallingShape else {
            return
        }
        self.scene.addPreviewShapeToScene(shape: newShapes.nextShape, completion: {})
        self.scene.movePreviewShape(shape: fallingShape, completion: {
            self.view.isUserInteractionEnabled = true
            self.scene.startTicking()
        })
    }
    func gameDidBegin(tetris: Tetris) {
        levelLabel.text = "\(tetris.level)"
        scoreLabel.text = "\(tetris.score)"
        scene.tickLengthMillis = TickLengthLevelOne
        if tetris.nextShape != nil && tetris.nextShape!.blocks[0].sprite == nil{
            scene.addPreviewShapeToScene(shape: tetris.nextShape!, completion: {
                self.nextShape()
            })
        }
        else {
            nextShape()
        }
    }
    func gameDidEnd(tetris: Tetris) {
        view.isUserInteractionEnabled = false
        scene.stopTicking()
        scene.playSound(sound: "Sounds/gameover.mp3")
        scene.animateCollapsingLines(linesToRemove: tetris.removeAllBlocks(), fallenBlocks: tetris.removeAllBlocks()) {
            tetris.beginGame()
        }
    }
    func gameDidLevelUp(tetris: Tetris) {
        levelLabel.text = "\(tetris.level)"
        if scene.tickLengthMillis >= 100 {
            scene.tickLengthMillis - 100
        }
        else if scene.tickLengthMillis >= 50 {
            scene.tickLengthMillis - 50
        }
        scene.playSound(sound: "Sounds/levelup.mp3")
    }
    func gameShapeDidDrop(tetris: Tetris) {
        scene.stopTicking()
        scene.redrawShape(tetris.fallingShape!, {
            tetris.letShapeFall()
        })
        scene.playSound(sound: "Sounds/drop.mp3")
    }
    func gameShapeDidLand(tetris: Tetris) {
        scene.stopTicking()
        self.view.isUserInteractionEnabled = false
        let removedLines = tetris.removeCompletedLines()
        if removedLines.linesRemoved.count > 0 {
            self.scoreLabel.text = "\(tetris.score)"
            scene.animateCollapsingLines(linesToRemove: removedLines.linesRemoved, fallenBlocks: removedLines.fallenBlocks) {
                self.gameShapeDidLand(tetris: Tetris)
            }
            scene.playSound(sound: "Sounds/bombs.mp3")
        }
        else {
            nextShape()
        }
    }
    func gameShapeDidMove(tetris: Tetris) {
        scene.redrawShape(tetris.fallingShape!, {})
    }
}

