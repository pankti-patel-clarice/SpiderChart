//
//  RadarChartData.swift
//  Charts
//
//  Created by Pankti Patel on 22/07/15.
//  Copyright (c) 2015 Pankti Patel. All rights reserved.

import Foundation
import CoreGraphics
import UIKit

public class RadarChartData: ChartData
{
    public var highlightColor = UIColor(red: 255.0/255.0, green: 187.0/255.0, blue: 115.0/255.0, alpha: 1.0)
    public var highlightLineWidth = CGFloat(1.0)
    public var highlightLineDashPhase = CGFloat(0.0)
    public var highlightLineDashLengths: [CGFloat]?
    
    public override init()
    {
        super.init()
    }
    
    public override init(xVals: [String?]?, dataSets: [ChartDataSet]?)
    {
        super.init(xVals: xVals, dataSets: dataSets)
    }
    
    public override init(xVals: [NSObject]?, dataSets: [ChartDataSet]?)
    {
        super.init(xVals: xVals, dataSets: dataSets)
    }
}
