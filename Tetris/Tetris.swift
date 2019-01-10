//
//  Tetris.swift
//  Tetris
//
//  Created by user911883 on 10/3/18.
//  Copyright © 2018 Valley Tutoring. All rights reserved.
//

let NumColumns = 10
let NumRows = 20
let StartingColumn = 4
let StartingRow = 0
let PreviewColumn = 12
let PreviewRow = 1

protocol TetrisDelegate {
    func gameDidEnd (tetris: Tetris)
    func gameDidBegin (tetris: Tetris)
    func gameShapeDidLand (tetris: Tetris)
    func gameShapeDidMove (tetris: Tetris)
    func gameShapeDidDrop (tetris: Tetris)
    func gameDidLevelUp (tetris: Tetris)
}

class Tetris {
    var blockArray: Array2D <Block>
    var nextShape: Shape?
    var fallingShape: Shape?
    var delegate: TetrisDelegate?
    init (){
        fallingShape = nil
        nextShape = nil
        blockArray = Array2D <Block>(columns: NumColumns, rows: NumRows)
    }
    func beginGame () {
        if (nextShape == nil) {
            nextShape = Shape.random (startingColumn: PreviewColumn, startingRow: PreviewRow)
        }
        delegate?.gameDidBegin(tetris: self)
    }
    func newShape() -> (fallingShape: Shape?, nextShape: Shape?) {
        fallingShape = nextShape
        nextShape = Shape.random(startingColumn: PreviewColumn, startingRow: PreviewRow)
        fallingShape?.moveTo(column: StartingColumn, row: StartingRow)
        guard detectIllegalPlacement() == false else {
            nextShape = fallingShape
            nextShape!.moveTo(column: PreviewColumn, row: PreviewRow)
            endGame ()
            return (nil, nil)
        }
        return (fallingShape, nextShape)
        
    }
    func detectIllegalPlaement () -> Bool {
        guard let shape = fallingShape else {
            return false
        }
        for block in shape.blocks {
            if block.column < 0 || block.column >= NumColumns
                || block.row < 0 || block.row >= NumRows {
                return true
            }
            else if blockArray [block.column, block.row] != nil {
                return true
            }
        }
        return false
    }
    func dropShape(){
        guard let shape = fallingShape else {
            return
        }
        while detectIllegalPlaement() == false {
            shape.lowerShapeByOneRow()
        }
        shape.raiseShapeByOneRow()
        delegate?.gameShapeDidDrop(tetris: self)
    }
    func letShapeFall(){
        guard let shape = fallingShape else {
            return
        }
        shape.lowerShapeByOneRow()
        if detectIllegalPlaement() {
            shape.raiseShapeByOneRow()
            if detectIllegalPlaement(){
                endGame ()
            }
            else {
                settleShape ()
            }
        }
        else {
            delegate?.gameShapeDidMove(tetris: self)
            if detectTouch() {
                settleShape ()
            }
        }
    }
    func rotateShape() {
        guard let shape = fallingShape else {
            return
        }
        shape.rotateClockwise()
        guard detectIllegalPlaement() == false else {
            shape.rotateCounterClockwise()
            return
        }
        delegate?.gameShapeDidMove(tetris: self)
    }
}
