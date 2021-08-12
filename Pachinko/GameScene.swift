import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var scoreLabel: SKLabelNode!
    var editLabel: SKLabelNode!
    var score = 0{
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var editingMode: Bool = false {
        didSet{
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        makeBouncer(at: CGPoint(x: 0,y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let object = nodes(at: location)
            
            if object.contains(editLabel){
                editingMode.toggle()
            } else {
                if editingMode {
                    let size = CGSize(width: Int.random(in: 16...128), height: 16)
                    let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1),
                                                          green: CGFloat.random(in: 0...1),
                                                          blue: CGFloat.random(in: 0...1),
                                                          alpha: 1),
                                           size: size)
                    box.zRotation = CGFloat.random(in: 0...3)
                    box.position = location
                    box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                    box.physicsBody?.isDynamic = false
                    addChild(box)
                } else {
                    let ball = SKSpriteNode(imageNamed: "ballRed")
                    ball.position = location
                    ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
                    ball.physicsBody?.restitution = 0.4
                    ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
                    ball.name = "ball"
                    addChild(ball)
                }
            }
        }
    }
    func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
        
    }
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slot: SKSpriteNode
        var glow: SKSpriteNode
        if isGood {
            slot = SKSpriteNode(imageNamed: "slotBaseGood")
            glow = SKSpriteNode(imageNamed: "slotGlowGood")
            slot.name = "good"
        } else {
            slot = SKSpriteNode(imageNamed: "slotBaseBad")
            glow = SKSpriteNode(imageNamed: "slotGlowBad")
            slot.name = "bad"
        }
        slot.position = position
        glow.position = position
        slot.physicsBody = SKPhysicsBody(rectangleOf: slot.size)
        slot.physicsBody?.isDynamic = false
        addChild(slot)
        addChild(glow)
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        glow.run(spinForever)
    }
    func collisionBetween(ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(ball: ball)
            score += 1
        } else if object.name == "bad" {
            destroy(ball: ball)
            score -= 1
        }
    }
    func destroy(ball: SKNode) {
        ball.removeFromParent()
    }
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        if contact.bodyA.node?.name == "ball" {
            collisionBetween(ball: nodeA,
                             object: nodeB)
        } else if contact.bodyB.node?.name == "ball" {
            collisionBetween(ball: nodeB,
                             object: nodeA)
        }
    }
}
