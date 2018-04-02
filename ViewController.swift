

import UIKit
import SceneKit
import ARKit

enum BodyType:Int {
    case int = 64
    case double = 32
    case string = 16
    case pointer = 8
    case array = 4
    case stc = 2
    case function = 1
    case plane = 128
}

@available(iOS 11.0, *)
class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {
    
    @IBOutlet weak var arrivalDayPicker: UIPickerView!
    @IBOutlet weak var datesView: UIView!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var numberOfGuestsLabel: UILabel!
    @IBOutlet weak var scroller: UIVisualEffectView!
    
    @IBOutlet var sceneView: ARSCNView!
    
    let intNode = SCNNode()
    let doubleNode = SCNNode()
    let stringNode = SCNNode()
    let pointerNode = SCNNode()
    let arrayNode = SCNNode()
    let structNode = SCNNode()
    let functionNode = SCNNode()
    var node = SCNNode()
    
    var planeNodes = [SCNNode]()
    
    var rotationAngle: CGFloat!
    var selectionModelPicker: SelectionModelPicker!
    var arrivalPickerDelDataSource: MonthYearPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //scroller.transform = CGAffineTransform(translationX: 0, y: scroller.frame.size.height);
        
        NotificationCenter.default.addObserver(self, selector: #selector(pickerChanged), name: .pickersChanged, object: nil)

        
        rotationAngle = -(90 * (.pi/180))
        let y = arrivalDayPicker.frame.origin.y
        arrivalDayPicker.transform = CGAffineTransform(rotationAngle: rotationAngle)
        arrivalDayPicker.frame = CGRect(x: -100, y: y, width: view.frame.width + 200, height: 100)
        
        selectionModelPicker = SelectionModelPicker()
       
        selectionModelPicker.rotationAngle = rotationAngle
        
        arrivalDayPicker.delegate = selectionModelPicker
        arrivalDayPicker.dataSource = selectionModelPicker
        arrivalDayPicker.selectRow(3, inComponent: 0, animated: true)
        
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.scene.physicsWorld.gravity = SCNVector3Make(0,-2,0)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panRecognized(pan:)))
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longRecognized(long:)))
       // let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapRecognized(tap:)))
        
        self.view.addGestureRecognizer(panGesture)
        self.view.addGestureRecognizer(longGesture)
       // self.view.addGestureRecognizer(tapGesture)
        configureLighting()

   }
    
    func pickerChanged(_ notification: Notification?) {
        let start = arrivalDayPicker.selectedRow(inComponent: 0)
        let dict = [intNode, doubleNode, stringNode, pointerNode, arrayNode, structNode, functionNode]
        node = dict[start]
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
    
    
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    //func tapRecognized(tap:UITapGestureRecognizer)
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer){
        /* Looking at the location where the user touched the screen */
        let result = sceneView.hitTest(sender.location(in: sceneView), types: .existingPlaneUsingExtent)
        guard let hitResult = result.first else {return}
        
        /* transforms the result into a matrix_float 4x4 so the SCN Node can read the data */
        let pointTransform = hitResult.worldTransform.translation
        let pointVector = SCNVector3Make(pointTransform.x, pointTransform.y+0.3, pointTransform.z)
        
        
       // let pointVector2 = SCNVector3Make(pointTransform.x, 0, pointTransform.z)
        /* Look at Add Geometry Class in Controller Group */
        switch node {
        case intNode:
            let torus = SCNTorus(ringRadius: 0.1, pipeRadius: 0.05)
            torus.firstMaterial?.diffuse.contents = UIColor.magenta
            torus.firstMaterial?.lightingModel = .physicallyBased
            let node = SCNNode(geometry: torus)
            let shape = SCNPhysicsShape(geometry: torus, options: nil)
            node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
            node.physicsBody?.isAffectedByGravity = true
            node.physicsBody?.categoryBitMask = BodyType.int.rawValue
            node.physicsBody?.contactTestBitMask =
                BodyType.int.rawValue|BodyType.double.rawValue|BodyType.string.rawValue|BodyType.pointer.rawValue|BodyType.array.rawValue|BodyType.stc.rawValue|BodyType.function.rawValue
            node.position = pointVector
            node.name = "int:0"
            sceneView.scene.rootNode.addChildNode(node)
            break
        case doubleNode:
            let cylinder = SCNCylinder(radius: 0.1, height: 0.1)
            cylinder.firstMaterial?.diffuse.contents = UIColor.brown
            cylinder.firstMaterial?.lightingModel = .physicallyBased
            let node = SCNNode(geometry: cylinder)
            let shape = SCNPhysicsShape(geometry: cylinder, options: nil)
            node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
            node.physicsBody?.isAffectedByGravity = true
            node.physicsBody?.mass = 0.05
            node.physicsBody?.categoryBitMask = BodyType.double.rawValue
            node.physicsBody?.contactTestBitMask = BodyType.int.rawValue|BodyType.double.rawValue|BodyType.string.rawValue|BodyType.pointer.rawValue|BodyType.array.rawValue|BodyType.stc.rawValue|BodyType.function.rawValue
            node.position = pointVector
            node.name = "double:0.0"
            sceneView.scene.rootNode.addChildNode(node)
            break
         
            
        case stringNode:
            let pyramid = SCNPyramid(width:0.15, height: 0.15, length: 0.15)
            pyramid.firstMaterial?.diffuse.contents = UIColor.lightGray
            pyramid.firstMaterial?.lightingModel = .physicallyBased
            let node = SCNNode(geometry: pyramid)
            let shape = SCNPhysicsShape(geometry: pyramid, options: nil)
            node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
            node.physicsBody?.isAffectedByGravity = true
            node.physicsBody?.categoryBitMask = BodyType.string.rawValue
            node.physicsBody?.contactTestBitMask = BodyType.int.rawValue|BodyType.double.rawValue|BodyType.string.rawValue|BodyType.pointer.rawValue|BodyType.array.rawValue|BodyType.stc.rawValue|BodyType.function.rawValue
            node.position = pointVector
            node.name = "string:''"
            sceneView.scene.rootNode.addChildNode(node)
            break
            
        case pointerNode:
            addObject(position: pointVector, sceneView: sceneView, node: pointerNode, objectPath: "art.scnassets/pointer.scn")
            break
        case arrayNode:
            let box = SCNBox(width:0.25, height: 0.25, length: 0.25, chamferRadius: 0.0)
            box.firstMaterial?.diffuse.contents = UIColor.brown
            box.firstMaterial?.lightingModel = .physicallyBased
            let node = SCNNode(geometry: box)
            let shape = SCNPhysicsShape(geometry: box, options: nil)
            node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
            node.physicsBody?.isAffectedByGravity = true
            
            node.physicsBody?.mass = 0.001
            
            node.physicsBody?.categoryBitMask = BodyType.array.rawValue
            node.physicsBody?.contactTestBitMask = BodyType.int.rawValue|BodyType.double.rawValue|BodyType.string.rawValue|BodyType.pointer.rawValue|BodyType.array.rawValue|BodyType.stc.rawValue|BodyType.function.rawValue
            node.position = pointVector
            node.name = "null array:[]"
            sceneView.scene.rootNode.addChildNode(node)
            break
            /*
            addObject(position: pointVector, sceneView: sceneView, node: arrayNode, objectPath: "art.scnassets/box_array.scn")
            break*/
        case structNode:
            let box = SCNBox(width:0.35, height: 0.35, length: 0.35, chamferRadius: 0.0)
            box.firstMaterial?.diffuse.contents = UIColor.black
            box.firstMaterial?.lightingModel = .physicallyBased
            let node = SCNNode(geometry: box)
            let shape = SCNPhysicsShape(geometry: box, options: nil)
            node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
            node.physicsBody?.isAffectedByGravity = true
            
            node.physicsBody?.mass = 0.001
            node.physicsBody?.damping = 2.0
            
            node.physicsBody?.categoryBitMask = BodyType.stc.rawValue
            node.physicsBody?.contactTestBitMask = BodyType.int.rawValue|BodyType.double.rawValue|BodyType.string.rawValue|BodyType.pointer.rawValue|BodyType.array.rawValue|BodyType.stc.rawValue|BodyType.function.rawValue
            node.position = pointVector
            node.name = "struct:{}"
            sceneView.scene.rootNode.addChildNode(node)
            break
        case functionNode:
            let cap = SCNCapsule(capRadius: 0.05, height: 0.4)

            cap.firstMaterial?.diffuse.contents = UIColor.cyan
            cap.firstMaterial?.lightingModel = .physicallyBased
            let node = SCNNode(geometry: cap)
            let shape = SCNPhysicsShape(geometry: cap, options: nil)
            node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
            node.physicsBody?.isAffectedByGravity = true
            
            node.physicsBody?.mass = 0.01
            
            node.physicsBody?.categoryBitMask = BodyType.function.rawValue
            node.physicsBody?.contactTestBitMask = BodyType.int.rawValue|BodyType.double.rawValue|BodyType.string.rawValue|BodyType.pointer.rawValue|BodyType.array.rawValue|BodyType.stc.rawValue|BodyType.function.rawValue
            node.position = pointVector
            node.name = "function: 2 + "
            sceneView.scene.rootNode.addChildNode(node)
            /*
             
 
            addObject(position: pointVector, sceneView: sceneView, node: functionNode, objectPath: "art.scnassets/generator_function.scn")*/
            break
        default:
            print("No Node Found")
        }
        
        
        sceneView.scene.physicsWorld.contactDelegate = self
    }
    
    
    func addObject(position: SCNVector3, sceneView: ARSCNView, node: SCNNode, objectPath: String){
        print(objectPath)
        // Create a new scene
        node.position = position
        guard let virtualObjectScene = SCNScene(named: objectPath)
            else {
                print("Unable to Generate" + objectPath)
                return
        }

        let wrapperNode = SCNNode()
        for child in virtualObjectScene.rootNode.childNodes {
            child.geometry?.firstMaterial?.lightingModel = .physicallyBased
            wrapperNode.addChildNode(child)
        }
        node.addChildNode(wrapperNode)
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        node.physicsBody = physicsBody
        node.physicsBody?.isAffectedByGravity = true
        
        node.physicsBody?.mass = 0.01
        node.physicsBody?.damping = 2.0
        
        sceneView.scene.rootNode.addChildNode(node)
        if(node == pointerNode){
            node.name = "pointer:NULL"
            node.physicsBody?.categoryBitMask = BodyType.pointer.rawValue
            node.physicsBody?.contactTestBitMask = BodyType.int.rawValue|BodyType.double.rawValue|BodyType.string.rawValue|BodyType.pointer.rawValue|BodyType.array.rawValue|BodyType.stc.rawValue|BodyType.function.rawValue
            print(node.name!)
        }/*
        else if(node == arrayNode){
            node.name = "null array:[]"
            node.physicsBody?.categoryBitMask = BodyType.array.rawValue
            node.physicsBody?.contactTestBitMask = BodyType.int.rawValue|BodyType.double.rawValue|BodyType.string.rawValue|BodyType.pointer.rawValue|BodyType.array.rawValue|BodyType.stc.rawValue|BodyType.function.rawValue
            print(node.name!)
        }*/
            /*
        else if(node == structNode){
            node.name = "struct:{} "
            node.physicsBody?.categoryBitMask = BodyType.stc.rawValue
            node.physicsBody?.contactTestBitMask = BodyType.int.rawValue|BodyType.double.rawValue|BodyType.string.rawValue|BodyType.pointer.rawValue|BodyType.array.rawValue|BodyType.stc.rawValue|BodyType.function.rawValue
            print(node.name!)
        }
        else if(node == functionNode){
            node.name = "function: 2 + int:1 "
            node.physicsBody?.categoryBitMask = BodyType.function.rawValue
            node.physicsBody?.contactTestBitMask = BodyType.int.rawValue|BodyType.double.rawValue|BodyType.string.rawValue|BodyType.pointer.rawValue|BodyType.array.rawValue|BodyType.stc.rawValue|BodyType.function.rawValue
            print(node.name!)
        }*/
        
        
    }
  /*
    func addSwipeGesturesToSceneView() {
        let swipeUpGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.applyForceToRocketship(withGestureRecognizer:)))
        swipeUpGestureRecognizer.direction = .up
        sceneView.addGestureRecognizer(swipeUpGestureRecognizer)
    }*/
    
    @objc func longRecognized(long: UILongPressGestureRecognizer){
        
        let hits = self.sceneView.hitTest(long.location(in: long.view), options: nil)
        if let tappedNode = hits.first?.node {
            var my_name = " "
            if(tappedNode.name != nil){
                my_name = tappedNode.name!
                tappedNode.removeFromParentNode()
            }
            else{
                return
            }
            let type = getType(process: my_name)
            print(tappedNode.name ?? "Name Error")
        }
        
    }
    
    // for pan gesture on xz plane
    var PCoordx: Float = 0.0
    var PCoordz: Float = 0.0
    @objc func panRecognized(pan: UIPanGestureRecognizer) {
        pan.minimumNumberOfTouches = 1
        if pan.state == .began{
            let hitNode = sceneView.hitTest(pan.location(in: sceneView), options: nil)
            if hitNode.first?.worldCoordinates.x == nil || hitNode.first?.worldCoordinates.z == nil{
                getAlert(msg: "Oops! Object is on the edge of our plane! Please be careful next time!")
                return
            }
            else{
                PCoordx = (hitNode.first?.worldCoordinates.x)!
                PCoordz = (hitNode.first?.worldCoordinates.z)!
            }
        }
        
        // when you start to pan in screen with your finger
        // hittest gives new coordinates of touched location in sceneView
        // coord-pcoord gives distance to move or distance paned in sceneview
        
        
        let hits = self.sceneView.hitTest(pan.location(in: pan.view), options: nil)
        if let tappedNode = hits.first?.node {
            if((tappedNode.geometry?.name) != "PLANE")
            {
                if pan.state == .changed {
                    let hitNode = sceneView.hitTest(pan.location(in: sceneView), options: nil)
                    if let coordx = hitNode.first?.worldCoordinates.x{
                        if let coordz = hitNode.first?.worldCoordinates.z{
                            
                            let action = SCNAction.moveBy(x: CGFloat(coordx-PCoordx), y: 0, z: CGFloat(coordz-PCoordz), duration: 0.1)
                            tappedNode.runAction(action)
                            
                            PCoordx = coordx
                            PCoordz = coordz
                        }
                    }
                    
                    pan.setTranslation(CGPoint.zero, in: sceneView)
                }
                if pan.state == .ended{
                    PCoordx = 0
                    PCoordz = 0
                }
            }
        }
    }
    
    func getValue(process: String) -> String{
        var pos = 0
        for (index, char) in process.enumerated() {
            if(char == ":"){
                pos = index
                break
            }
        }
        let len = process.count - pos - 1
        let subStr = process.suffix(len)
        return String(subStr)
    }
    
    func getType(process: String)-> String{
        var str = ""
        for (index, char) in process.enumerated() {
            if(char == ":"){
                return str
            }
            str = str + String(char)
        }
        return str
    }
    
    func getArrayType(process: String)-> String{
        var str = ""
        for (index, char) in process.enumerated() {
            if(char == " "){
                print("array type: "+str)
                return str
            }
            str = str + String(char)
        }
        print("array type: " + str)
        return str
    }
    
    func getAlert(msg: String){
        let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        print("diff")
        let infoA = contact.nodeA.physicsBody?.categoryBitMask
        let infoB = contact.nodeB.physicsBody?.categoryBitMask
        
        print("infoB:")
        print(infoB)
        print("infoA:")
        print(infoA)
        
        var nameA = ""
        var nameB = ""
        if contact.nodeB.name != nil{
            nameB = contact.nodeB.name!
            print("nodeB is" + nameB)
        }
        else{
            print("nodeB is nil")
        }
        
        if contact.nodeA.name != nil{
            nameA = contact.nodeA.name!
            print("nodeA is"+nameA)
        }
        else{
            print("nodeA is nil")
        }
        
        if(infoA == BodyType.stc.rawValue){
            print("struct")
            //"struct: { }"
             //STRUCT BOX update info
            var str = nameA
            let str2 = nameB
            let pos = (str.count)-1
            var subStr = " "
            if(pos > 0 ){
                subStr = String(str.prefix(pos))
            }
            else{
                print("Wrong")
            }
            print(subStr)
            str = subStr + str2 + "}"
            contact.nodeA.name = str
            contact.nodeB.removeFromParentNode()
        }
        else if(infoB == BodyType.stc.rawValue){
            print("struct")
            var str = nameB
            let str2 = nameA
            let pos = str.count-1
            var subStr = " "
            if(pos > 0 ){
                subStr = String(str.prefix(pos))
            }
            else{
                print("Wrong")
            }
            str = subStr + " " + str2 + "}"
            contact.nodeB.name = str
            contact.nodeA.removeFromParentNode()
        }
            
        else if(infoA == BodyType.array.rawValue){
            print("array")
            
            var str1 = nameA
            let str2 = nameB
            var type2 = getType(process: str2)
            var type1 = getArrayType(process: str1)
            if(type1 == "null"){
                print("HEYYYY")
                let len = str1.count - 4
                var str = String(str1.suffix(len))
                str = type2 + str
                contact.nodeA.name = str
                str1 = str
            }
            else if(type2 != type1){
                print("type2 is" + type2)
                print("type1 is" + type1)
                getAlert(msg: "Type Error")
                return
            }
            let value2 = getValue(process: str2)
            let pos = str1.count-1
            let subStr = String(str1.prefix(pos))
            let newStr = subStr + value2 + " " + "]"
            contact.nodeA.name = newStr
            contact.nodeB.removeFromParentNode()
        }
        else if(infoB == BodyType.array.rawValue){
            print("array")
            var str2 = nameA
            var str1 = nameB
            var type1 = getType(process: str2)
            var type2 = getArrayType(process: str1)
            if(type2 == "null"){
                print("HEY")
                let len = str1.count - 4
                var str = String(str1.suffix(len))
                str = type2 + str
                contact.nodeB.name = str
                str1 = str
            }
            else if(type2 != type1){
                getAlert(msg: "Type Error")
                return
            }
            let value2 = getValue(process: str2)
            let pos = str1.count-1
            let subStr = String(str1.prefix(pos))
            let newStr = subStr + value2 + " " + "]"
            contact.nodeB.name = newStr
            contact.nodeA.removeFromParentNode()
        }
        else if(infoA == BodyType.function.rawValue){
            
            var start = "2"
            for (index, char) in nameA.enumerated() {
                if(index == 10){
                    start = String(char)
                }
            }
            let num = Int(start)
            print("num is " + start)

            var count = 0
            for (index, char) in nameA.enumerated() {
                if(char == ":"){
                    count = count + 1
                }
            }
            let my_position = contact.nodeA.position
            if(count == num! + 1){
                contact.nodeA.removeFromParentNode()
                contact.nodeB.removeFromParentNode()
                let json = ["param":nameA]
                do{
                    let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                    let url = URL(string: "http://10.30.15.121:5000/api/function_result")!
                    let request = NSMutableURLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                    request.httpBody = jsonData
                    let task = URLSession.shared.dataTask(with: request as URLRequest){ data, response, error in
                        if error != nil{
                            print("Error -> \(error)")
                            return
                        }
                        do {
                            let result = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? String
                            self.test(data: result!, pos: my_position)
                        } catch {
                            print("Error -> \(error)")
                        }
                    }
                    task.resume()
                } catch {
                    print(error)
                    // Do any additional setup after loading the view, typically from a nib.
                }
                
            }
            else{
                var newStr = nameA + " " + nameB
                contact.nodeA.name = newStr
            }
        }
        else if(infoB == BodyType.function.rawValue){
            
            var start = "2"
            for (index, char) in nameB.enumerated() {
                if(index == 10){
                    start = String(char)
                }
            }
            let num = Int(start)
            var count = 0
            for (index, char) in nameB.enumerated() {
                if(char == ":"){
                    count = count + 1
                }
            }
            let my_position = contact.nodeA.position
            if(count == num! + 1){
                contact.nodeB.removeFromParentNode()
                contact.nodeA.removeFromParentNode()
                let json = ["param":nameB]
                do{
                    let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                    let url = URL(string: "http://10.30.15.121:5000/api/function_result")!
                    let request = NSMutableURLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                    request.httpBody = jsonData
                    let task = URLSession.shared.dataTask(with: request as URLRequest){ data, response, error in
                        if error != nil{
                            print("Error -> \(error)")
                            return
                        }
                        do {
                            let result = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? String
                            self.test(data: result!, pos: my_position)
                        } catch {
                            print("Error -> \(error)")
                        }
                    }
                    task.resume()
                } catch {
                    print(error)
                    // Do any additional setup after loading the view, typically from a nib.
                }
            }
            else{
                let newStr = nameB + " " + nameA
                contact.nodeB.name = newStr
            }
        }
        else
        {
            print ("hit")
        }

    }
    

func addInt(val: String, position: SCNVector3){
    let torus = SCNTorus(ringRadius: 0.1, pipeRadius: 0.05)
    torus.firstMaterial?.diffuse.contents = UIColor.magenta
    torus.firstMaterial?.lightingModel = .physicallyBased
    let node = SCNNode(geometry: torus)
    let shape = SCNPhysicsShape(geometry: torus, options: nil)
    node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
    node.physicsBody?.isAffectedByGravity = true
    node.physicsBody?.categoryBitMask = BodyType.int.rawValue
    node.physicsBody?.contactTestBitMask =
        BodyType.int.rawValue|BodyType.double.rawValue|BodyType.string.rawValue|BodyType.pointer.rawValue|BodyType.array.rawValue|BodyType.stc.rawValue|BodyType.function.rawValue
    node.position = position
    node.name = "int:" + val
    sceneView.scene.rootNode.addChildNode(node)
}

func addDouble(val: String, position: SCNVector3){
    let cylinder = SCNCylinder(radius: 0.1, height: 0.1)
    cylinder.firstMaterial?.diffuse.contents = UIColor.brown
    cylinder.firstMaterial?.lightingModel = .physicallyBased
    let node = SCNNode(geometry: cylinder)
    let shape = SCNPhysicsShape(geometry: cylinder, options: nil)
    node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
    node.physicsBody?.isAffectedByGravity = true
    node.physicsBody?.mass = 0.05
    node.physicsBody?.categoryBitMask = BodyType.double.rawValue
    node.physicsBody?.contactTestBitMask = BodyType.int.rawValue|BodyType.double.rawValue|BodyType.string.rawValue|BodyType.pointer.rawValue|BodyType.array.rawValue|BodyType.stc.rawValue|BodyType.function.rawValue
    node.position = position
    node.name = "double:" + val
    sceneView.scene.rootNode.addChildNode(node)
}

func addString(val: String, position: SCNVector3){
    let pyramid = SCNPyramid(width:0.15, height: 0.15, length: 0.15)
    pyramid.firstMaterial?.diffuse.contents = UIColor.lightGray
    pyramid.firstMaterial?.lightingModel = .physicallyBased
    let node = SCNNode(geometry: pyramid)
    let shape = SCNPhysicsShape(geometry: pyramid, options: nil)
    node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
    node.physicsBody?.isAffectedByGravity = true
    node.physicsBody?.categoryBitMask = BodyType.string.rawValue
    node.physicsBody?.contactTestBitMask = BodyType.int.rawValue|BodyType.double.rawValue|BodyType.string.rawValue|BodyType.pointer.rawValue|BodyType.array.rawValue|BodyType.stc.rawValue|BodyType.function.rawValue
    node.position = position
    node.name = "string:"+val
    sceneView.scene.rootNode.addChildNode(node)
}


    func test(data: String, pos: SCNVector3){
        print(data)
        var str = "i"
        for (index, char) in data.enumerated() {
            if(index == 0){
                str = String(char)
            }
        }
        print(str)
        if(str == "i"){
            let value = getValue(process: str)
            addInt(val: str, position: pos)
        }
        else if(str == "d"){
            let value = getValue(process: str)
            addDouble(val: str, position: pos)
        }
        else if(str == "s"){
            let value = getValue(process: str)
            addString(val: str, position: pos)
        }
    
    }
}


@available(iOS 11.0, *)
extension ViewController {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        plane.name = "PLANE"
        plane.materials.first?.diffuse.contents = UIColor.transparentWhite
        
        var planeNode = SCNNode(geometry: plane)
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,y,z)
        planeNode.eulerAngles.x = -.pi / 2
        
        // TODO: Update plane node
        update(&planeNode, withGeometry: plane, type: .static)
        
        node.addChildNode(planeNode)
        
        // TODO: Append plane node to plane nodes array if appropriate
        planeNodes.append(planeNode)
    }
    
    // TODO: Remove plane node from plane nodes array if appropriate
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor,
            let planeNode = node.childNodes.first
            else { return }
        planeNodes = planeNodes.filter { $0 != planeNode }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            var planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        let width = CGFloat(planeAnchor.extent.x*3)
        let height = CGFloat(planeAnchor.extent.z*3)
        plane.width = width
        plane.height = height
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        
        planeNode.position = SCNVector3(x, y, z)
        
        update(&planeNode, withGeometry: plane, type: .static)
        
    }

    // TODO: Create update plane node method
    func update(_ node: inout SCNNode, withGeometry geometry: SCNGeometry, type: SCNPhysicsBodyType) {
        let shape = SCNPhysicsShape(geometry: geometry, options: nil)
        let physicsBody = SCNPhysicsBody(type: type, shape: shape)
        node.physicsBody = physicsBody
        node.physicsBody?.categoryBitMask = BodyType.plane.rawValue

    }
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

extension UIColor {
    open class var transparentWhite: UIColor {
        return UIColor.white.withAlphaComponent(0.20)
    }
}


