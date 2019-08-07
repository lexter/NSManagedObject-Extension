//
//  UIView+Custom.swift
//
//  Created by Lexter Labra on 23/11/2015.
//  Copyright © 2015 Lexter Labra. All rights reserved.
//

import UIKit

/// A type alias for view constraints
typealias Constraint = (attribute: NSLayoutAttribute, relativeView: UIView?, relativeViewAttribute: NSLayoutAttribute, constant: CGFloat)

/// Extends UIView in order to add custom methods intended for specific and generic use.
extension UIView {
    // --------------------------------------------------------------
    // Adding a stored property to a class extension by using object association.
    // This solution is taken from:
    // http://stackoverflow.com/questions/25426780/swift-extension-stored-properties-alternative
    // --------------------------------------------------------------
    
    /// Stores a name tag of the view.
    @IBInspectable var name: String? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.name) as? String }
        set { objc_setAssociatedObject(self, &AssociatedKeys.name, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /**
     Search and return the subview whose name property is equal to the parameter.
     
     - parameter name: The name to search.
     
     - returns: Subview if there's a matching name; nil if none.
     */
    final func getSubviewByName(name: String) -> UIView? {
        for child in self.subviews where child.name == name {
            return child
        }
        return nil
    }
    
    /**
     Search and remove the subview whose name property is equal to the parameter.
     
     - parameter name: The name to search.
     */
    final func removeSubviewWithName(name: String) {
        for child in self.subviews where child.name == name {
            child.removeFromSuperview()
            return
        }
    }
    
    /**
     Remove all subviews of this view.
     */
    final func removeChildren() {
        for child in self.subviews {
            child.removeFromSuperview()
        }
    }
    
    /**
     Set the view's frame width.
     - parameter n: The value to be assigned for the view's width.
     */
    func setWidth(n: CGFloat) {
        var rect = self.frame
        rect.size.width = n
        self.frame = rect
    }
    
    /**
     Get the view's frame width.
     - returns: The view's frame width.
     */
    func getWidth() -> CGFloat {
        return self.frame.width
    }
    
    /**
     Set the view's frame height.
     - parameter n: The value to be assigned for the view's height.
     */
    func setHeight(n: CGFloat) {
        var rect = self.frame
        rect.size.height = n
        self.frame = rect
    }
    
    /**
     Get the view's frame height.
     - returns: The view's frame height.
     */
    func getHeight() -> CGFloat {
        return self.frame.height
    }
    
    /**
     Set the view's x position.
     - parameter n: The value to be assigned for the view's x position.
     */
    func setX(n: CGFloat) {
        var rect = self.frame
        rect.origin.x = n
        self.frame = rect
    }
    
    /**
     Get the view's x position.
     - returns: The view's x position value.
     */
    func getX() -> CGFloat {
        return self.frame.minX
    }
    
    /**
     Set the view's y position.
     - parameter n: The value to be assigned for the view's y position.
     */
    func setY(n: CGFloat) {
        var rect = self.frame
        rect.origin.y = n
        self.frame = rect
    }
    
    /**
     Get the view's y position.
     - returns: The view's y position value.
     */
    func getY() -> CGFloat {
        return self.frame.minY
    }
    
    /**
     Get the view's max X value. This is a shortcut to x + width computation.
     - returns: The view's max X position value.
     */
    func getMaxX() -> CGFloat {
        return self.frame.maxX
    }
    
    /**
     Get the view's max Y value. This is a shortcut to x + width computation.
     - returns: The view's max X position value.
     */
    func getMaxY() -> CGFloat {
        return self.frame.maxY
    }
    
    /**
     Set the view's rectangular values, x, y, width, height.
     - parameter values: A tuple containing x, y, width, and height values.
     */
    func setFrameWith(values: (x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat)) {
        self.frame = CGRect(x: values.x, y: values.y, width: values.w, height: values.h)
    }
    
    /// Remove all constraints
    func clearConstraints() {
        guard self.superview != nil else { return }
        for constraint in self.superview!.constraints where constraint.firstItem as? UIView == self {
            self.superview!.removeConstraint(constraint)
        }
    }
    
    /// Adds a constraints to fill the super view with option to add padding to its sides.
    /// - parameter padding - An optional parameter in tuple data type containing top, left, bottom, right attributes used for padding. Default is (0,0,0,0)
    func fillSuperview(padding: (top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) = (0,0,0,0)) {
        guard self.superview != nil else { return }
        
        self.clearConstraints()
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.superview!.addConstraints([
            NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.superview, attribute: NSLayoutAttribute.top, multiplier: 1, constant: padding.top),
            NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self.superview, attribute: NSLayoutAttribute.left, multiplier: 1, constant: padding.left),
            NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self.superview, attribute: NSLayoutAttribute.right, multiplier: 1, constant: -padding.bottom),
            NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.superview, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -padding.right)
        ])
    }
    
    /// Add contraints to the receiver(target view).
    ///
    /// Sample use:
    ///
    ///     view.addConstraints(constraints: [
    ///         (.Top, self.parent, .Top, 5),
    ///         (.Left, self.parent, .Left, 10),
    ///         (.Right, self.parent, .Right, 10),
    ///         (.Height, nil, .NotAnAttribute, 30)
    ///     ])
    ///
    /// - parameter usingConstraints: An array of Constraints.
    func addConstraints(constraints usingConstraints: [Constraint]) {
        guard self.superview != nil else { return }
        
        self.clearConstraints()
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        for constraint in usingConstraints {
            self.superview!.addConstraint(NSLayoutConstraint(item: self, attribute: constraint.attribute, relatedBy: NSLayoutRelation.equal, toItem: constraint.relativeView, attribute: constraint.relativeViewAttribute, multiplier: 1, constant: constraint.constant))
        }
    }
    
    /// Returns a Constraint described by attribute, relativeViewAttribute,
    /// - parameter constraintToSearch: The Constraint to search and return.
    /// - returns: NSLayoutConstraint object
    func getConstraint(constraintToSearch: Constraint) -> NSLayoutConstraint? {
        guard self.superview != nil else { return nil }
        for constraint in self.superview!.constraints where constraint.firstItem as? UIView == self {
            if constraint.firstAttribute == constraintToSearch.attribute && constraint.secondAttribute == constraintToSearch.relativeViewAttribute && (constraint.secondItem as? UIView == constraintToSearch.relativeView) {
                return constraint
            }
        }
        return nil
    }
    
    /// Removes specific Constraint described by attribute, relativeViewAttribute,
    /// - parameter constraintToSearch: The Constraint to search and remove.
    func clearConstraint(constraintToSearch: Constraint) {
        guard self.superview != nil else { return }
        for constraint in self.superview!.constraints where constraint.firstItem as? UIView == self {
            if constraint.firstAttribute == constraintToSearch.attribute && constraint.secondAttribute == constraintToSearch.relativeViewAttribute && (constraint.secondItem as? UIView == constraintToSearch.relativeView) {
                self.superview!.removeConstraint(constraint)
                return
            }
        }
    }
    
    /// Updates a specific Constraint
    func updateConstraint(constraint: Constraint) {
        guard self.superview != nil else { return }
        self.clearConstraint(constraintToSearch: constraint)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.superview!.addConstraint(NSLayoutConstraint(item: self, attribute: constraint.attribute, relatedBy: NSLayoutRelation.equal, toItem: constraint.relativeView, attribute: constraint.relativeViewAttribute, multiplier: 1, constant: constraint.constant))
    }
    
    func addSubviews(_ subviews: [UIView]) {
        for subview in subviews {
            self.addSubview(subview)
        }
    }
    
    func shake() {
        // Taken from http://stackoverflow.com/questions/27987048/shake-animation-for-uitextfield-uiview-in-swift
        autoreleasepool { [unowned self] in
            let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            animation.duration = 0.6
            animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
            self.layer.add(animation, forKey: "shake")
        }
    }
}
