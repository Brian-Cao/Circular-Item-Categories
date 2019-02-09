//
//  ViewController.swift
//  Circular Categories
//
//  Created by Brian Cao on 2/7/19.
//  Copyright © 2019 Brian Cao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layoutIfNeeded()
        
        
        let circleCategory = BCCircularCategory(interCircleRadius: 75, outerCircleRadius: 50, numberOfOuterCircles: 7)
        self.view.addSubview(circleCategory)
        circleCategory.center = view.center
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


class BCRotatingView: UIView{
    var currentAngle: CGFloat
    let circle: Circle

    init(circle: Circle, angle: CGFloat, radius: CGFloat) {
        self.currentAngle = angle
        self.circle = circle
        super.init(frame: CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2))
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

class BCCircularCategory: UIView{
    let interCircleRadius: CGFloat
    let outerCircleRadius: CGFloat
    let numberOfOuterCircles: Int
    var rotatingViews = [BCRotatingView]()
    var animator: UIDynamicAnimator!
    var circle: Circle!
    
    var beginningLocation = CGPoint.zero
    var beginningAngle: CGFloat!
    var snap: UISnapBehavior!
    
    init(interCircleRadius: CGFloat, outerCircleRadius: CGFloat, numberOfOuterCircles: Int) {
        self.interCircleRadius = interCircleRadius
        self.outerCircleRadius = outerCircleRadius
        self.numberOfOuterCircles = numberOfOuterCircles
        let frameSize = 2 * (interCircleRadius + outerCircleRadius * 2 + 10)
        
        super.init(frame: CGRect(x: 0, y: 0, width: frameSize, height: frameSize))
        
        animator = UIDynamicAnimator(referenceView: self)
        
        let interCircle = UIButton(frame: CGRect(x: 0, y: 0, width: interCircleRadius*2, height: interCircleRadius*2))
        interCircle.layer.cornerRadius = min(interCircle.frame.size.height, interCircle.frame.size.width) / 2.0
        interCircle.center = self.center
        interCircle.clipsToBounds = true
        interCircle.isUserInteractionEnabled = true
        interCircle.backgroundColor = .red
        self.addSubview(interCircle)
        
        
        for i in 0...numberOfOuterCircles - 1 {
            let angleBetweenViews = (2 * Double.pi) / Double(numberOfOuterCircles)
            let circleRadius = interCircleRadius + outerCircleRadius + 5
            circle = Circle(center: self.center, radius: circleRadius)
            let viewOnCircle = BCRotatingView(circle: circle, angle: CGFloat(Double(i) * angleBetweenViews), radius: outerCircleRadius)
            
            rotatingViews.append(viewOnCircle)
            self.addSubview(viewOnCircle)
            
            
            
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan(panGesture:)))
            viewOnCircle.addGestureRecognizer(panGesture)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didPan(panGesture: UIPanGestureRecognizer){
        print("hello")
        let view = panGesture.view!
        
        if view is BCRotatingView{
            
            let pannedView = view as! BCRotatingView
            
            switch panGesture.state {
                
            case .began:
                beginningLocation = pannedView.center
                beginningAngle = pannedView.currentAngle
                
                
            case .changed:
                pannedView.center = panGesture.location(in: self)
                let angleDifference = circle.angleBetween(firstPoint: beginningLocation, secondPoint: panGesture.location(in: self))
                
                for view in rotatingViews {
                    if(view != pannedView){
                        view.updatePosition(angle: angleDifference)
                    }
                }
                
                beginningLocation = panGesture.location(in: self)
                
            case .ended:
                if snap != nil {
                    animator.removeBehavior(snap)
                }
                
                // Needs to snap to updated location
                let firstPoint = circle.pointOnCircle(angle: beginningAngle)
                let angleDifference = circle.angleBetween(firstPoint: firstPoint, secondPoint: panGesture.location(in: self))
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
