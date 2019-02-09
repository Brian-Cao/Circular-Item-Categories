//
//  ViewController.swift
//  Circular Categories
//
//  Created by Brian Cao on 2/7/19.
//  Copyright © 2019 Brian Cao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var rotatingViews = [RotatingView]()
    let numberOfViews = 7
    var circle: Circle!
    var beginningLocation = CGPoint.zero
    var beginningAngle: CGFloat!
    var animator: UIDynamicAnimator!
    var snap: UISnapBehavior!
    var collision: UICollisionBehavior!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        animator = UIDynamicAnimator(referenceView: self.view)
        self.view.layoutIfNeeded()
        
        circle = Circle(center: CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/2), radius: 130)

        for i in 0...numberOfViews - 1 {
            let angleBetweenViews = (2 * Double.pi) / Double(numberOfViews)
            let viewOnCircle = RotatingView(circle: circle, angle: CGFloat(Double(i) * angleBetweenViews))

            rotatingViews.append(viewOnCircle)
            view.addSubview(viewOnCircle)



            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan(panGesture:)))
            viewOnCircle.addGestureRecognizer(panGesture)
        }

        collision = UICollisionBehavior(items: rotatingViews)

    }

    @objc func didPan(panGesture: UIPanGestureRecognizer){

        let view = panGesture.view!

        if view is RotatingView{
            
            let pannedView = view as! RotatingView
            
            switch panGesture.state {
                
            case .began:
                beginningLocation = pannedView.center
                beginningAngle = pannedView.currentAngle
                
                
            case .changed:
                pannedView.center = panGesture.location(in: self.view)
                let angleDifference = circle.angleBetween(firstPoint: beginningLocation, secondPoint: panGesture.location(in: self.view))
    
                for view in rotatingViews {
                    if(view != pannedView){
                        view.updatePosition(angle: angleDifference)
                    }
                }
                
                beginningLocation = panGesture.location(in: self.view)
                
            case .ended:
                if snap != nil {
                    animator.removeBehavior(snap)
                }
                
                // Needs to snap to updated location
                let firstPoint = circle.pointOnCircle(angle: beginningAngle)
                let angleDifference = circle.angleBetween(firstPoint: firstPoint, secondPoint: panGesture.location(in: self.view))
                let snapLocation = circle.pointOnCircle(angle: beginningAngle + angleDifference)
                snap = UISnapBehavior(item: pannedView, snapTo: snapLocation)
                
                //need to update current angle
                pannedView.currentAngle += angleDifference
                animator.addBehavior(snap)
                
                
                
            default:
                break
            }
            
        }

        
    }
}


struct Circle {
    let center: CGPoint
    let radius: CGFloat

    func pointOnCircle(angle: CGFloat) -> CGPoint {
        let x = center.x + radius * cos(angle)
        let y = center.y + radius * sin(angle)

        return CGPoint(x: x, y: y)
    }

    func angleBetween(firstPoint: CGPoint, secondPoint: CGPoint) -> CGFloat {
        let firstAngle = atan2(firstPoint.y - center.y, firstPoint.x - center.x)
        let secondAngle = atan2(secondPoint.y - center.y, secondPoint.x - center.x)
        let angleDiff = (firstAngle - secondAngle) * -1

        return angleDiff
    }
}


class RotatingView: UIView{
    var currentAngle: CGFloat
    let circle: Circle

    init(circle: Circle, angle: CGFloat) {
        self.currentAngle = angle
        self.circle = circle
        super.init(frame: CGRect(x: 0, y: 0, width: 110, height: 110))
        self.layer.cornerRadius = min(self.frame.size.height, self.frame.size.width) / 2.0
        self.clipsToBounds = true
        center = circle.pointOnCircle(angle: currentAngle)
        backgroundColor = .blue
        self.isUserInteractionEnabled = true


    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updatePosition(angle: CGFloat) {
        currentAngle += angle
        center = circle.pointOnCircle(angle: currentAngle)
    }

}

//import UIKit
//
//class ViewController: UIViewController {
//
//    var rotatingViews = [RotatingView]()
//    let numberOfViews = 8
//    var circle = Circle(center: CGPoint(x: 200, y: 200), radius: 100)
//    var prevLocation = CGPoint.zero
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        for i in 0...numberOfViews {
//            let angleBetweenViews = (2 * Double.pi) / Double(numberOfViews)
//            let viewOnCircle = RotatingView(circle: circle, angle: CGFloat(Double(i) * angleBetweenViews))
//            rotatingViews.append(viewOnCircle)
//            view.addSubview(viewOnCircle)
//        }
//
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan(panGesture:)))
//        view.addGestureRecognizer(panGesture)
//    }
//
//    @objc func didPan(panGesture: UIPanGestureRecognizer){
//        switch panGesture.state {
//        case .began:
//            prevLocation = panGesture.location(in: view)
//        case .changed, .ended:
//            let nextLocation = panGesture.location(in: view)
//            let angle = circle.angleBetween(firstPoint: prevLocation, secondPoint: nextLocation)
//
//            rotatingViews.forEach({ $0.updatePosition(angle: angle)})
//            prevLocation = nextLocation
//        default: break
//        }
//    }
//}
//
//
//struct Circle {
//    let center: CGPoint
//    let radius: CGFloat
//
//    func pointOnCircle(angle: CGFloat) -> CGPoint {
//        let x = center.x + radius * cos(angle)
//        let y = center.y + radius * sin(angle)
//
//        return CGPoint(x: x, y: y)
//    }
//
//    func angleBetween(firstPoint: CGPoint, secondPoint: CGPoint) -> CGFloat {
//        let firstAngle = atan2(firstPoint.y - center.y, firstPoint.x - center.x)
//        let secondAnlge = atan2(secondPoint.y - center.y, secondPoint.x - center.x)
//        let angleDiff = (firstAngle - secondAnlge) * -1
//
//        return angleDiff
//    }
//}
//
//
//class RotatingView: UIView {
//    var currentAngle: CGFloat
//    let circle: Circle
//
//    init(circle: Circle, angle: CGFloat) {
//        self.currentAngle = angle
//        self.circle = circle
//        super.init(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
//        center = circle.pointOnCircle(angle: currentAngle)
//        backgroundColor = .blue
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    func updatePosition(angle: CGFloat) {
//        currentAngle += angle
//        center = circle.pointOnCircle(angle: currentAngle)
//    }
//}
