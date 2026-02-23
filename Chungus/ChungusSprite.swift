//
//  ChungusSprite.swift
//  Chungus
//
//  Created by Anto Z on 2/23/26.
//

import SpriteKit

class ChungusScene: SKScene {
    
    var mouseOffset: CGPoint?
    var currentSprite: SKSpriteNode!
    var idleSprite: SKSpriteNode!
    var walkingSprite: [SKSpriteNode]!
    var jumpRopeSprite: [SKSpriteNode]!
    var walkingAnimationIndex: Int = 0
    var dizzySprite: SKSpriteNode!
    var sleepingSprite: SKSpriteNode!
    var studyingSprite: SKSpriteNode!
    var isMovingLeft: Bool = false
    var isDragged: Bool = false
    var preDragSprite: SKSpriteNode?
    
    var prevX: Double = 0
    var prevY: Double = 0
    var x: Double = 0
    var y: Double = 0
    
    func loadSprite(name: String, width: Double, height: Double, x: Double, y: Double) -> SKSpriteNode {
        let sprite = SKSpriteNode(imageNamed: name)
        sprite.size = CGSize(width: width, height: height)
        sprite.name = name
        sprite.position = CGPoint(x: self.x, y: self.y)
        return sprite
    }
    
    override func didMove(to view: SKView) {
        self.backgroundColor = .clear
        
        self.x = size.width / 2
        self.y = size.height / 2
        
        self.idleSprite = loadSprite(
            name: "ChungusIdle",
            width: SpriteConstant.width,
            height: SpriteConstant.height,
            x: self.x, y: self.y)

        
        self.dizzySprite = loadSprite(
            name: "ChungusDizzy",
            width: SpriteConstant.width,
            height: SpriteConstant.height,
            x: self.x, y: self.y)
        
        self.sleepingSprite = loadSprite(
            name: "ChungusSleeping",
            width: SpriteConstant.width,
            height: SpriteConstant.height,
            x: self.x, y: self.y)
        
        self.studyingSprite = loadSprite(
            name: "ChungusStudying",
            width: SpriteConstant.width,
            height: SpriteConstant.height,
            x: self.x, y: self.y)
        
        let walkingSprite1 = loadSprite(
            name: "ChungusWalk1",
            width: SpriteConstant.width,
            height: SpriteConstant.height,
            x: self.x, y: self.y)
        
        let walkingSprite2 = loadSprite(
            name: "ChungusWalk2",
            width: SpriteConstant.width,
            height: SpriteConstant.height,
            x: self.x, y: self.y)
        
        let jumpRopeSprite1 = loadSprite(
            name: "ChungusJumpRope1",
            width: SpriteConstant.width,
            height: SpriteConstant.height,
            x: self.x, y: self.y)
        
        let jumpRopeSprite2 = loadSprite(
            name: "ChungusJumpRope2",
            width: SpriteConstant.width,
            height: SpriteConstant.height,
            x: self.x, y: self.y)
        
        let jumpRopeSprite3 = loadSprite(
            name: "ChungusJumpRope3",
            width: SpriteConstant.width,
            height: SpriteConstant.height,
            x: self.x, y: self.y)
        
        self.jumpRopeSprite = [jumpRopeSprite1, jumpRopeSprite2, jumpRopeSprite3]
        
        self.walkingSprite = [walkingSprite1, walkingSprite2]
        
        self.currentSprite = idleSprite
        
        addChild(currentSprite)
        
        self.spriteLoop(lowerDuration: 3, upperDuration: 10, lowerDelay: 2, upperDelay: 5)
    }
    
    override func mouseDown(with event: NSEvent) {
        //        let location = event.location(in: self)
        // var clickedNode = atPoint(location)
        
        //        if clickedNode.name == "Chungus" {
        mouseOffset = event.locationInWindow
        //        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        
        guard self.view?.window != nil, let offset = mouseOffset else { return }
        
        if !self.isDragged {
            self.preDragSprite = self.currentSprite
            self.isDragged = true
        }
        
        let mouseInScreen = NSEvent.mouseLocation
        
        self.x = mouseInScreen.x - offset.x
        self.y = mouseInScreen.y - offset.y
        // This is so we set it back to idle
        self.prevX = self.x
        self.prevY = self.y
        
        self.renderSprite()
    }
    
    override func mouseUp(with event: NSEvent) {
        mouseOffset = nil
        self.isDragged = false
        
        if let previousSprite = self.preDragSprite {
            self.renderSprite(replaceSprite: previousSprite)
            self.preDragSprite = nil
        } else {
            self.renderSprite()
        }
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 49: // Space bar
            if RuneTimeConstant.spriteDebug {
                print("Space Pressed")
            }
        default:
            
            if RuneTimeConstant.spriteDebug {
                print("Key code: \(event.keyCode)")
            }
        }
    }
    
    func renderSprite(replaceSprite: SKSpriteNode? = nil){
        if RuneTimeConstant.spriteDebug { print("Sprite Coordinates: \(self.x), \(self.y)") }
        
        guard let window = self.view?.window else { return }
        
        self.currentSprite.removeFromParent()
        
        if let newSprite = replaceSprite {
            // 1. If we passed a specific sprite (sleeping/studying), use it.
            self.currentSprite = newSprite
        } else {
            // 2. Otherwise, calculate movement for walking/idle.
            let dx = self.x - self.prevX
            
            if dx == 0 {
                self.currentSprite = self.idleSprite
            } else {
                self.currentSprite = self.walkingSprite[self.walkingAnimationIndex]
                self.walkingAnimationIndex = Int(CACurrentMediaTime() * 10) % self.walkingSprite.count
                
                self.currentSprite.xScale = dx < 0 ? -1 : 1
            }
        }
        
        // Dragging overrides everything
        if self.isDragged {
            self.dizzySprite.xScale = Int(CACurrentMediaTime() * 10) % 2 == 0 ? 1 : -1
            self.currentSprite = self.dizzySprite
        }
        
        addChild(self.currentSprite)
        window.setFrameOrigin(CGPoint(x: self.x, y: self.y))
    }
    
    func walk(dx: Double, dy: Double) {
        
        if self.isDragged { return }
        
        self.prevX = self.x
        self.prevY = self.y
        
        self.x = dx + self.x > ScreenConstant.width ? self.x : dx + self.x
        self.y = dy + self.y > ScreenConstant.height ? self.y : dy + self.y
        
        self.renderSprite()
    }
    
    func isOutOfBound(x: Double, y: Double) -> Bool {
        return x < 0 || x + SpriteConstant.width > ScreenConstant.width || y < 0 || y + SpriteConstant.height > ScreenConstant.height
    }
    
    func getWalkingAction(config: [String: Any]) -> SKAction {
        
        let lowerDuration = config["lowerDuration"] as? Double ?? 2.0
        let upperDuration = config["upperDuration"] as? Double ?? 5.0
        let step = config["step"] as? Int ?? 2
        
        let walkDuration = Double.random(in: lowerDuration...upperDuration)
        let frameDuration = 0.02
        let iterations = Int(walkDuration / frameDuration)
        
        let direction = [-1.0, 1.0].randomElement() ?? 1.0
        let step_size = direction * Double(step)
        
        var stepActions: [SKAction] = []
        
        for _ in 0..<iterations {
            let moveStep = SKAction.run {
                if !self.isOutOfBound(x: self.x + step_size, y: self.y) {
                    self.walk(dx: step_size, dy: 0)
                }
            }
            let waitStep = SKAction.wait(forDuration: frameDuration)
            stepActions.append(moveStep)
            stepActions.append(waitStep)
        }
        
        let resetToIdle = SKAction.run {
            self.prevX = self.x
            self.renderSprite()
        }
        
        return SKAction.sequence([SKAction.sequence(stepActions), resetToIdle])
    }
    
    func getSleepingAction(config: [String: Any]) -> SKAction {
            
        let lowerDuration = config["lowerDuration"] as? Double ?? 2.0
        let upperDuration = config["upperDuration"] as? Double ?? 5.0
        
        let sleepDuration = Double.random(in: lowerDuration...upperDuration)
        let frameDuration = 0.75
        let totalBreaths = max(1, Int(sleepDuration / (frameDuration * 2)))
        let actualSleepTime = Double(totalBreaths) * (frameDuration * 2)
        
        let setSprite = SKAction.run {
            self.renderSprite(replaceSprite: self.sleepingSprite)
            
            let breatheOut = SKAction.scaleY(to: 0.9, duration: frameDuration)
            let breatheIn = SKAction.scaleY(to: 1.0, duration: frameDuration)
            
            let oneFullBreath = SKAction.sequence([breatheOut, breatheIn])
            let breathingLoop = SKAction.repeat(oneFullBreath, count: totalBreaths)
            
            self.currentSprite.run(breathingLoop, withKey: "Breathing")
        }
        
        let wait = SKAction.wait(forDuration: actualSleepTime)
        
        let resetToIdle = SKAction.run {
            self.currentSprite.yScale = 1.0
            self.prevX = self.x
            self.renderSprite()
        }
        
        return SKAction.sequence([setSprite, wait, resetToIdle])
    }
        
    func getStudyingAction(config: [String: Any]) -> SKAction {
        
        let lowerDuration = config["lowerDuration"] as? Double ?? 2.0
        let upperDuration = config["upperDuration"] as? Double ?? 5.0
        
        let setSprite = SKAction.run {
            self.renderSprite(replaceSprite: self.studyingSprite)
        }
        
        let studyDuration = Double.random(in: lowerDuration...upperDuration)
        let wait = SKAction.wait(forDuration: studyDuration)
        
        let resetToIdle = SKAction.run {
            self.prevX = self.x
            self.renderSprite()
        }
        
        return SKAction.sequence([setSprite, wait, resetToIdle])
    }
    
    func getJumpRopeAction(config: [String: Any]) -> SKAction {
        
        let lowerDuration = config["lowerDuration"] as? Double ?? 2.0
        let upperDuration = config["upperDuration"] as? Double ?? 5.0
        let duration = Double.random(in: lowerDuration...upperDuration)
        let groundY = self.y
        let jumpHeight: Double = 30.0
        
        // customAction gives us 'elapsedTime', which is perfect for syncing
        return SKAction.customAction(withDuration: duration) { node, elapsedTime in
            let totalTime = Double(elapsedTime)
            
            // 1. Calculate a "Cycle Progress" (0.0 to 1.0)
            // Adjust 'speed' to change how fast he jumps
            let speed = 2.0
            let progress = (totalTime * speed).truncatingRemainder(dividingBy: 1.0)
            
            // 2. The Bounce (Sine Wave from 0 to PI)
            // This ensures starts at 0, peaks at 0.5, and ends at 0
            let bounce = sin(progress * .pi) * jumpHeight
            self.y = groundY + bounce
            
            // 3. The Texture Sync
            // Map 0.0-0.33 to Frame 0, 0.33-0.66 to Frame 1, 0.66-1.0 to Frame 2
            let frameIndex: Int
            if progress < 0.33 {
                frameIndex = 0 // Ground
            } else if progress < 0.66 {
                frameIndex = 1 // Peak
            } else {
                frameIndex = 2 // Middle (Falling)
            }
            
            // Safety check for array bounds
            let safeIndex = min(frameIndex, self.jumpRopeSprite.count - 1)
            self.renderSprite(replaceSprite: self.jumpRopeSprite[safeIndex])
        }
    }

    func spriteLoop(lowerDuration: Double, upperDuration: Double, lowerDelay: Double = 2.0, upperDelay: Double = 5.0, step: Int = 2) {
        
        let config: [String: Any] = [
            "lowerDuration": lowerDuration,
            "upperDuration": upperDuration,
            "step": step
        ]
        
        let actionFunctions = [self.getWalkingAction, self.getJumpRopeAction, self.getSleepingAction, self.getStudyingAction]
        
        let chosenFunction = actionFunctions.randomElement() ?? self.getSleepingAction
//        let chosenFunction = self.getJumpRopeAction

        let actionSequence = chosenFunction(config)
        
        let waitBetween = SKAction.wait(forDuration: Double.random(in: lowerDelay...upperDelay))
        
        let queueNext = SKAction.run { [weak self] in
            self?.spriteLoop(
                lowerDuration: lowerDuration,
                upperDuration: upperDuration,
                lowerDelay: lowerDelay,
                upperDelay: upperDelay,
                step: step
            )
        }
        
        let mainSequence = SKAction.sequence([actionSequence, waitBetween, queueNext])
        
        self.run(mainSequence, withKey: "SpriteLoop")
    }
}
