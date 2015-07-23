//
//  RadarChartDataSet.swift
//  Charts
//
//  Created by Pankti Patel on 22/07/15.
//  Copyright (c) 2015 Pankti Patel. All rights reserved.

import Foundation
import UIKit

public class RadarChartDataSet: LineRadarChartDataSet
{
    public override init()
    {
        super.init()
        
        self.valueFont = UIFont.systemFontOfSize(13.0)
    }
    
    public override init(yVals: [ChartDataEntry]?, label: String?)
    {
        super.init(yVals: yVals, label: label)
        
        self.valueFont = UIFont.systemFontOfSize(13.0)
    }
}