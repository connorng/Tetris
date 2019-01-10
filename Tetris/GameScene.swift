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
    let LayerPosition = CGPoint (x: 6, y: -6)
    
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
        gameboard.anchorPoint = CGPoint(x: 0, y: 1)
        gameboard.position = LayerPosition
        shapeLayer.position = LayerPosition
        shapeLayer.addChild(gameboard)
        gameLayer.addChild(shapeLayer)
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
    
    func pointForColumn(column: Int, row: Int) -> CGPoint {
        let x = LayerPosition.x + (column * BlockSize) + (BlockSize / 2)
        let y = LayerPosition.y - (column * BlockSize) + (BlockSize / 2)
        return CGPoint (x: x, y: y)
    }
    
    func addPreviewShapeToScene(shape: Shape, completion: ()->()){
        for block in shape.Blocks {
            var texture = textureCache [block.spriteName]
            if texture == nil {
                texture = SKTexture(imageNamed: block.spriteName)
                textureCache [block.spriteName] = texture
            }
            let sprite = SKSpriteNode (texture: texture)
            sprite.position = pointForColumn (block.column, block.row - 2)
            shapeLayer.addChild(sprite)
            block.sprite = sprite
            sprite.alpha = 0
            let moveAction = SKAction.moveTo(x: pointForColumn(block.column, block.row), duration: TimeInterval(0.2))
            moveAction.timingMode = SKActionTimingMode.easeOut
            let fadeInAction = SKAction.fadeAlpha(by: 0.7, duration: 0.4)
            sprite.runAction (SKAction.group([moveAction,fadeInAction]))
        }
        runAction(SKAction.wait(forDuration: 0.4), completion: completion)
    }
    
    func movePreviewShape(shape: Shape, completion: ()->()) {
        for block in shape.blocks {
            let sprite = block.sprite!
            let moveTo = pointForColumn(block.column, block.row)
            let moveToAction = SKAction.moveTo(x: moveTo, duration: 0.05)
            moveToAction.timingMode = .easeOut
            if block == shape.blocks.last{
                sprite.runAction(moveToAction, completion)
            }
            else {
                sprite.runAction(moveToAction)
            }
        }
    }
    
    final func rotateBlocks(orientation: Orientation) {
        guard let blockRowColumnTranslation = blockRowColumnPositions [orientation] else{
            return
        }
        for (idx,diff) in blockRowColumnTranslation.enumerate() {
            block[idx].column = column + diff.columnDiff
            block[idx].row = row + diff.rowDiff
        }
    }
    
    final func moveTo (column: Int, row: Int) {
        self.column = column
        self.row = row
        rotateBlocks(orientation)
    }
    
    final func lowerShapeByOneRow() {
        shiftBy(columns: 0, rows: 1)
    }
    
    final func shiftBy(columns: Int, rows: Int) {
        self.column += columns
        self.row += rows
        for block in blocks {
            block.columns += columns
            block.rows += rows
        }
    }
    
    func random (startingColumn: Int, startingRow: Int) -> Shape {
        switch Int(arc4random_uniform(NumShapeTypes)) {
        case 0:
            return SquareShape(startingColumn: Int, startingRow: Int)
        case 1:
            return LineShape(startingColumn: Int, startingRow: Int)
        case 2:
            return TShape(startingColumn: Int, startingRow: Int)
        case 3:
            return LShape(startingColumn: Int, startingRow: Int)
        case 4:
            return JShape(startingColumn: Int, startingRow: Int)
        case 5:
            return SShape(startingColumn: Int, startingRow: Int)
        default:
            return ZShape(startingColumn: Int, startingRow: Int)
        }
    }
}
