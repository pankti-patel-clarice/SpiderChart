//
//  ChartDataRendererBase.swift
//  Charts
//
//  Created by Pankti Patel on 22/07/15.
//  Copyright (c) 2015 Pankti Patel. All rights reserved.

import Foundation
import CoreGraphics

public class ChartDataRendererBase: ChartRendererBase
{
    
    public override init( viewPortHandler: ChartViewPortHandler)
    {
        super.init(viewPortHandler: viewPortHandler)
    }

    public func drawData(#context: CGContext)
    {
        fatalError("drawData() cannot be called on ChartDataRendererBase")
    }
    
    public func drawValues(#context: CGContext)
    {
        fatalError("drawValues() cannot be called on ChartDataRendererBase")
    }
    
    public func drawExtras(#context: CGContext)
    {
        fatalError("drawExtras() cannot be called on ChartDataRendererBase")
    }
    
}