//
//  ViewController.swift
//  version-1
//
//  Created by 咩咩 on 31/03/2018.
//  Copyright © 2018 Xiwei M. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    
    let firstNode = SCNNode()
    let secondNode = SCNNode()
    let thirdNode = SCNNode()
    var node = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchRecognized(pinch:)))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panRecognized(pan:)))
        
        self.view.addGestureRecognizer(pinchGesture)
        self.view.addGestureRecognizer(panGesture)
   
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        let firstButton = UIButton(frame: CGRect(x: 50, y: 100, width: 100, height: 50))
        firstButton.backgroundColor = UIColor.cyan
        firstButton.setTitle("Set int", for: .normal)
        firstButton.addTarget(self, action: #selector(setFirstNode), for: .touchUpInside)
        
        let secondButton = UIButton(frame: CGRect(x: 50, y: 200, width: 100, height: 50))
        secondButton.backgroundColor = UIColor.cyan
        secondButton.setTitle("Set float", for: .normal)
        secondButton.addTarget(self, action: #selector(setSecondNode), for: .touchUpInside)
        
        let thirdButton = UIButton(frame: CGRect(x: 50, y: 300, width: 100, height: 50))
        thirdButton.backgroundColor = UIColor.cyan
        thirdButton.setTitle("Set string", for: .normal)
        thirdButton.addTarget(self, action: #selector(setThirdNode), for: .touchUpInside)
        
        self.view.addSubview(firstButton)
        self.view.addSubview(secondButton)
        self.view.addSubview(thirdButton)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let standardConfiguration: ARWorldTrackingConfiguration = {
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
            return configuration
        }()
        
        // Run the view's session
        sceneView.session.run(standardConfiguration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    /*
    @IBAction func handlePinch(_ gestureRecognizer: UIPinchGestureRecognizer) {
        print("pinch")
        node.runAction(SCNAction.scale(by: gestureRecognizer.scale, duration: 0.1))
    }
    
    @IBAction func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        print("pan")
        let xPan = gestureRecognizer.velocity(in: sceneView).x/10000
        
        node.runAction(SCNAction.rotateBy(x: 0, y: xPan, z: 0, duration: 0.1))
        
    }*/

    
    @IBAction func handeTap(_ sender: UITapGestureRecognizer) {
        /* Looking at the location where the user touched the screen */
        print("tap")
        let result = sceneView.hitTest(sender.location(in: sceneView), types: [ARHitTestResult.ResultType.featurePoint])
        guard let hitResult = result.last else {return}
        
        /* transforms the result into a matrix_float 4x4 so the SCN Node can read the data */
        let pointTransform = SCNMatrix4(hitResult.worldTransform)
        let pointVector = SCNVector3Make(pointTransform.m41, pointTransform.m42, pointTransform.m43)
        
        /* Look at Add Geometry Class in Controller Group */
        switch node {
        case firstNode:
            
            
            let sphere = SCNSphere(radius: 0.2)
            sphere.firstMaterial?.diffuse.contents = UIColor.green
            let node = SCNNode(geometry: sphere)
            node.position = pointVector
            sceneView.scene.rootNode.addChildNode(node)
            break
            
        case secondNode:
            let box = SCNBox(width: 0.4 ,height: 0.4, length: 0.4, chamferRadius: 0.1 )
            box.firstMaterial?.diffuse.contents = UIColor.orange
            let node = SCNNode(geometry: box)
            node.position = pointVector
            sceneView.scene.rootNode.addChildNode(node)
            break
            
        case thirdNode:
            let pyramid = SCNPyramid()
            pyramid.firstMaterial?.diffuse.contents = UIColor.blue
            let node = SCNNode(geometry: pyramid)
            node.position = pointVector
            sceneView.scene.rootNode.addChildNode(node)
            break
        default:
            print("No Node Found")
        }
    }
    
    @objc func pinchRecognized(pinch: UIPinchGestureRecognizer) {
        print("pinch")
        node.runAction(SCNAction.scale(by: pinch.scale, duration: 0.1))
    }
    
    @objc func panRecognized(pan: UIPanGestureRecognizer) {
        pan.minimumNumberOfTouches = 1
        
        let results = self.sceneView.hitTest(pan.location(in: pan.view), types: ARHitTestResult.ResultType.featurePoint)
        
        guard let result: ARHitTestResult = results.first else{return}
        
        let hits = self.sceneView.hitTest(pan.location(in: pan.view), options: nil)
        if let tappedNode = hits.first?.node {
            let position = SCNVector3Make(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y, result.worldTransform.columns.3.z)
            tappedNode.position = position
        }
    }
/*
    
    @objc func panRecognized(pan: UIPanGestureRecognizer) {
        print("pan")
        //let xPan = pan.velocity(in: sceneView).x/10000
        /*
         y pan is a not tuned for user expereience
         let yPan = pan.velocity(in: sceneView).y/10000
         */
        let result = sceneView.hitTest(pan.location(in: sceneView), types: [ARHitTestResult.ResultType.featurePoint])
        guard let hitResult = result.last else {return}
        
        /* transforms the result into a matrix_float 4x4 so the SCN Node can read the data */
        let pointTransform = SCNMatrix4(hitResult.worldTransform)
        let pointVector = SCNVector3Make(pointTransform.m41, pointTransform.m42, pointTransform.m43)
        
        node.runAction(SCNAction.move(to: pointVector, duration: 0.1))
    }*/
    
    @objc func setFirstNode(sender: UIButton!) {
        print("first")
        node = firstNode
    }
    
    @objc func setSecondNode(sender: UIButton!) {
        print("second")
        node = secondNode
    }
    
    @objc func setThirdNode(sender: UIButton!) {
        print("third")
        node = thirdNode
    }
    
}

