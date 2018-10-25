//
//  GameScene.swift
//  Tetris
//
//  Created by Braun Shedd on 9/16/18.
//  Copyright © 2018 Valley Tutoring. All rights reserved.
//

import SpriteKit

let TickLengthLevelOne = TimeInterval(600)
let BlockSize:CGFloat = 20.0

class GameScene: SKScene {
	
    let gameLayer = SKNode ()
    let shapeLayer = SKNode ()
    let layerPosition = CGPoint (x: 6, y: -6)
    
	var tick:(() -> ())?
	var tickLengthMillis = TickLengthLevelOne
	var lastTick:NSDate?
    var textureCache = Dictionary <String, SKTexture> ()
	
	required init(coder aDecoder: NSCoder) {
		fatalError("NSCoder not supported")
	}
	
	override init(size: CGSize) {
		super.init(size: size)
		
		anchorPoint = CGPoint(x: 0, y: 1.0)
		
		let background = SKSpriteNode(imageNamed: "background")
		background.position = CGPoint(x: 0, y: 0)
		background.anchorPoint = CGPoint(x: 0, y: 1.0)
		addChild(background)
        
        addChild(gameLayer)
        let gameboardTexture = SKTexture (imageNamed: "gameboard")
        let gameboard = SKSpriteNode (texture: gameboardTexture, size: CGSizeMake (BlockSize * CGFloat(NumColumns), BlockSize * CGFloat(NumRows)) )
        
    }
	
    override func update(_ currentTime: TimeInterval) {
		guard let lastTick = lastTick else {
			return
		}
		let timePassed = lastTick.timeIntervalSinceNow * -1000.0
		if timePassed > tickLengthMillis {
			self.lastTick = NSDate()
			tick?()
		}
    }
	
	func startTicking() {
		lastTick = NSDate()
	}
	
	func stopTicking() {
		lastTick = nil
	}
}
