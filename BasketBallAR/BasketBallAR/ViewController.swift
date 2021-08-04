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

    //MARK: - IBOutlet

    @IBOutlet var arView: ARSCNView!

    //MARK: - View LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        arView.delegate = self
        arView.showsStatistics = true
        let scene = SCNScene()
        arView.scene = scene
        addBackboard()
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

    func addBackboard() {
        guard let backboardScene = SCNScene(named: "art.scnassets/hoop.scn") else {return}
        guard let backboardNode = backboardScene.rootNode.childNode(withName: "backboard", recursively: false) else {return}
        backboardNode.position = SCNVector3(x: 0, y: 0.5, z: -3)
        arView.scene.rootNode.addChildNode(backboardNode)
    }
}
