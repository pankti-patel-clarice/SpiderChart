//
//  ChartRendererBase.swift
//  Charts
//
//  Created by Pankti Patel on 22/07/15.
//  Copyright (c) 2015 Pankti Patel. All rights reserved.


import Foundation
import CoreGraphics

public class ChartRendererBase: NSObject
{
    /// the component that handles the drawing area of the chart and it's offsets
    public var viewPortHandler: ChartViewPortHandler!
    
    /// the minimum value on the x-axis that should be plotted
    internal var _minX: Int = 0
    
    /// the maximum value on the x-axis that should be plotted
    internal var _maxX: Int = 0
    
    public override init()
    {
        super.init()
    }
    
    public init(viewPortHandler: ChartViewPortHandler)
    {
        super.init()
        self.viewPortHandler = viewPortHandler
    }

    /// Returns true if the specified value fits in between the provided min and max bounds, false if not.
    internal func fitsBounds(val: Double, min: Double, max: Double) -> Bool
    {
        if (val < min || val > max)
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    
}
        