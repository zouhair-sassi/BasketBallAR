//
//  ViewController.swift
//  BasketBallAR
//
//  Created by Zouhair Sassi on 8/4/21.
//

import UIKit
import RealityKit
import ARKit
import SceneKit


class ViewController: UIViewController, ARSCNViewDelegate {

    //MARK: - Vars

    var currentNode: SCNNode!

    //MARK: - IBOutlet

    @IBOutlet var arView: ARSCNView!
    @IBOutlet weak var addHoopButton: UIButton!

    //MARK: - View LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        arView.delegate = self
        arView.showsStatistics = true
        let scene = SCNScene()
        arView.scene = scene
        registerGestureRecognizer()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let config = ARWorldTrackingConfiguration()
        arView.session.run(config, options: .resetTracking)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arView.session.pause()
    }

    @IBAction func startRoundAction(_ sender: Any) {
        roundAction(node: currentNode)
    }

    @IBAction func stopAllAction(_ sender: Any) {
        currentNode.removeAllActions()
    }

    @IBAction func startHorizontalAction(_ sender: Any) {
        horizontaleAction(node: currentNode)
    }

    @IBAction func addHoop(_ sender: Any) {
        addBackboard()
        addHoopButton.isHidden = true
    }

    //MARK: - private

    private func addBackboard() {
        guard let backboardScene = SCNScene(named: "art.scnassets/hoop.scn") else {return}
        guard let backboardNode = backboardScene.rootNode.childNode(withName: "backboard", recursively: false) else {return}
        backboardNode.position = SCNVector3(x: 0, y: 0, z: -3)

        let physicsShape = SCNPhysicsShape(node: backboardNode, options: [SCNPhysicsShape.Option.type : SCNPhysicsShape.ShapeType.concavePolyhedron])
        let physicsBody = SCNPhysicsBody(type: .static, shape: physicsShape)
        backboardNode.physicsBody = physicsBody

        arView.scene.rootNode.addChildNode(backboardNode)
        currentNode = backboardNode
    }

    private func registerGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        arView.addGestureRecognizer(tap)
    }

    @objc func handleTap(gestureRecognizer: UIGestureRecognizer) {
        guard let sceneView = gestureRecognizer.view as? ARSCNView else { return }
        guard let centerPoint = sceneView.pointOfView else { return }

        let cameraTransform = centerPoint.transform
        let cameraLocation = SCNVector3(x: cameraTransform.m41, y: cameraTransform.m42, z: cameraTransform.m43)
        let cameraOrientation = SCNVector3(x: -cameraTransform.m31, y: -cameraTransform.m32, z: -cameraTransform.m33)

        let cameraPosition = SCNVector3Make(cameraLocation.x + cameraOrientation.x, cameraLocation.y + cameraOrientation.y, cameraLocation.z +  cameraOrientation.z)

        let ball = SCNSphere(radius: 0.15)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "basketballSkin.png")
        ball.materials = [material]

        let ballNode = SCNNode(geometry: ball)
        ballNode.position = cameraPosition

        let physicsShape = SCNPhysicsShape(node: ballNode, options: nil)
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: physicsShape)
        ballNode.physicsBody = physicsBody

        let forceVector : Float = 6
        ballNode.physicsBody?.applyForce(SCNVector3(cameraOrientation.x * forceVector, cameraOrientation.y * forceVector, cameraOrientation.z * forceVector), asImpulse: true)

        arView.scene.rootNode.addChildNode(ballNode)
    }

    private func horizontaleAction(node: SCNNode) {
        let leftAction = SCNAction.move(by: SCNVector3(-1, 0, 0), duration: 3)
        let rightAction = SCNAction.move(by: SCNVector3(1, 0, 0), duration: 3)
        let actionSequence = SCNAction.sequence([leftAction, rightAction])
        node.runAction(SCNAction.repeat(actionSequence, count: 4))
    }

    private func roundAction(node: SCNNode) {
        let upLeft = SCNAction.move(by: SCNVector3(1, 1, 0), duration: 2)
        let downRight = SCNAction.move(by: SCNVector3(1, -1, 0), duration: 2)
        let downLeft = SCNAction.move(by: SCNVector3(1, -1, 0), duration: 2)
        let upRight = SCNAction.move(by: SCNVector3(-1, 1, 0), duration: 2)

        let actionSequence = SCNAction.sequence([upLeft, downRight, downLeft, upRight])
        node.runAction(SCNAction.repeat(actionSequence, count: 2))
    }
}
