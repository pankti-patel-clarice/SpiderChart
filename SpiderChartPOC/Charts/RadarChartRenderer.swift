//
//  RadarChartRenderer.swift
//  Charts
//
//  Created by Pankti Patel on 22/07/15.
//  Copyright (c) 2015 Pankti Patel. All rights reserved.

import Foundation
import CoreGraphics
import UIKit
import Darwin

public class RadarChartRenderer: ChartDataRendererBase
{
    internal weak var _chart: RadarChartView!
   

    public init(chart: RadarChartView, viewPortHandler: ChartViewPortHandler)
    {
        super.init(viewPortHandler: viewPortHandler)
        
        _chart = chart

    }
    
    public override func drawData(#context: CGContext)
    {
        if (_chart !== nil)
        {
            var radarData = _chart.data
            
            if (radarData != nil)
            {
                for set in radarData!.dataSets as! [RadarChartDataSet]
                {
                    if (set.isVisible)
                    {
                        drawDataSet(context: context, dataSet: set)
                    }
                }
            }
        }
    }
    
    internal func drawDataSet(#context: CGContext, dataSet: RadarChartDataSet)
    {
        CGContextSaveGState(context)
        
        var sliceangle = _chart.sliceAngle
        
        // calculate the factor that is needed for transforming the value to pixels
        var factor = _chart.factor
        
        var center = _chart.centerOffsets
        var entries = dataSet.yVals
        var path = CGPathCreateMutable()
        var hasMovedToPoint = false
        
        for (var j = 0; j < entries.count; j++)
        {
            var e = entries[j]
            
            var p = ChartUtils.getPosition(center: center, dist: CGFloat(e.value - _chart.chartYMin) * factor, angle: sliceangle * CGFloat(j) + _chart.rotationAngle)
            
            if (p.x.isNaN)
            {
                continue
            }
            
            if (!hasMovedToPoint)
            {
                CGPathMoveToPoint(path, nil, p.x, p.y)
                hasMovedToPoint = true
            }
            else
            {
                CGPathAddLineToPoint(path, nil, p.x, p.y)
            }
        }
        
        CGPathCloseSubpath(path)
        
        // draw filled
        if (dataSet.isDrawFilledEnabled)
        {
            CGContextSetFillColorWithColor(context, UIColor.cyanColor().CGColor)
            CGContextSetAlpha(context, 0.1)
            
            CGContextBeginPath(context)
            CGContextAddPath(context, path)
            CGContextFillPath(context)
        }
        
        // draw the line (only if filled is disabled or alpha is below 255)
        if (!dataSet.isDrawFilledEnabled || dataSet.fillAlpha < 1.0)
        {
            CGContextSetStrokeColorWithColor(context, dataSet.colorAt(0).CGColor)
            CGContextSetLineWidth(context, dataSet.lineWidth)
            CGContextSetAlpha(context, 1.0)
            
            CGContextBeginPath(context)
            CGContextAddPath(context, path)
            CGContextStrokePath(context)
        }
        
        CGContextRestoreGState(context)
    }
    
    public override func drawValues(#context: CGContext)
    {
        if (_chart.data === nil)
        {
            return
        }
        
        var data = _chart.data!
        
        var defaultValueFormatter = _chart.valueFormatter
        
        var sliceangle = _chart.sliceAngle
        
        // calculate the factor that is needed for transforming the value to pixels
        var factor = _chart.factor
        
        var center = _chart.centerOffsets
        
        var yoffset = CGFloat(5.0)
        
        for (var i = 0, count = data.dataSetCount; i < count; i++)
        {
            var dataSet = data.getDataSetByIndex(i) as! RadarChartDataSet
            
            if (!dataSet.isDrawValuesEnabled)
            {
                continue
            }
            
            var entries = dataSet.yVals
            
            for (var j = 0; j < entries.count; j++)
            {
                var e = entries[j]
                
                var p = ChartUtils.getPosition(center: center, dist: CGFloat(e.value) * factor, angle: sliceangle * CGFloat(j) + _chart.rotationAngle)
                
                var valueFont = dataSet.valueFont
                var valueTextColor = dataSet.valueTextColor
                
                var formatter = dataSet.valueFormatter
                if (formatter === nil)
                {
                    formatter = defaultValueFormatter
                }
                
                
                ChartUtils.drawText(context: context, text: formatter!.stringFromNumber(e.value)!, point: CGPoint(x: p.x, y: p.y - yoffset - valueFont.lineHeight), align: .Center, attributes: [NSFontAttributeName: valueFont, NSForegroundColorAttributeName: valueTextColor])
                
                
            }
        }
    }
    
    
    public override func drawExtras(#context: CGContext)
    {
        drawWeb(context: context)
    }
    
    private var _webLineSegmentsBuffer = [CGPoint](count: 2, repeatedValue: CGPoint())
    
    internal func drawWeb(#context: CGContext)
    {
        var sliceangle = _chart.sliceAngle
        
        CGContextSaveGState(context)
        
        // calculate the factor that is needed for transforming the value to
        // pixels
        var factor = _chart.factor
        var rotationangle = _chart.rotationAngle
        
        var center = _chart.centerOffsets
        
        // draw the web lines that come from the center
        CGContextSetLineWidth(context, _chart.webLineWidth)
        CGContextSetStrokeColorWithColor(context, _chart.webColor.CGColor)
        CGContextSetAlpha(context, _chart.webAlpha)
        
        var labelCount = _chart.yAxis.entryCount
        var centerOfWeb : CGPoint?
        var size:CGFloat = 25
        var start:CGPoint = CGPointZero
        var arrayPoints = Array<CGPoint>()
        
        for (var j = 0; j < labelCount; j++)
        {
            for (var i = 0, xValCount = _chart.data!.xValCount; i < xValCount; i++)
            {
                var r = CGFloat(_chart.yAxis.entries[j] - _chart.chartYMin) * factor
                
                
                var p1 = ChartUtils.getPosition(center: center, dist: r, angle: sliceangle * CGFloat(i) + rotationangle)
                var p2 = ChartUtils.getPosition(center: center, dist: r, angle: sliceangle * CGFloat(i + 1) + rotationangle)
                
                
                if j == 1{
                    
                    arrayPoints.append(p1)
                }

                centerOfWeb = center
                _webLineSegmentsBuffer[0].x = p1.x
                _webLineSegmentsBuffer[0].y = p1.y
                _webLineSegmentsBuffer[1].x = p2.x
                _webLineSegmentsBuffer[1].y = p2.y
                
                
                UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    
                    CGContextStrokeLineSegments(context, self._webLineSegmentsBuffer, 2)
                    
                    }, completion: { finished in
                        
                })

                
            }
            
        }
        
        
        for i in 0..<arrayPoints.count
        {
            var p = ChartUtils.getPosition(center: center, dist: CGFloat(_chart.yRange) * factor, angle: sliceangle * CGFloat(i) + rotationangle)
            
            start = arrayPoints[i]
            _webLineSegmentsBuffer[0].x = start.x
            _webLineSegmentsBuffer[0].y = start.y
            _webLineSegmentsBuffer[1].x = p.x
            _webLineSegmentsBuffer[1].y = p.y

            CGContextStrokeLineSegments(context, _webLineSegmentsBuffer, 2)

        }
        
           CGContextRestoreGState(context)

        if (_chart.drawImage != nil){
            
            _chart.drawImage! = maskImageWithEllipse(_chart.drawImage!, borderWidth: 10, borderColor: UIColor.blackColor())
            _chart.drawImage!.drawInRect(CGRectMake(centerOfWeb!.x-size/2, centerOfWeb!.y-size/2, size, size))
        }

    }
    
    
    
    func maskImageWithEllipse(image: UIImage,
        borderWidth: CGFloat, borderColor: UIColor) -> UIImage {
            
            let imgRef = Util.CGImageWithCorrectOrientation(image)
            let size = CGSize(width: CGFloat(CGImageGetWidth(imgRef)) / image.scale, height: CGFloat(CGImageGetHeight(imgRef)) / image.scale)
            
            return Util.drawImageWithClosure(size) { (size: CGSize, context: CGContext) -> () in
                
                let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                
                CGContextAddEllipseInRect(context, rect)
                CGContextClip(context)
                image.drawInRect(rect)
                
                if (borderWidth > 0) {
                    CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
                    CGContextSetLineWidth(context, borderWidth);
                    CGContextAddEllipseInRect(context, CGRect(x: borderWidth / 2,
                        y: borderWidth / 2,
                        width: size.width - borderWidth,
                        height: size.height - borderWidth));
                    CGContextStrokePath(context);
                }
            }
    }
    
    internal struct Util {
        
        /**
        Get the CGImage of the image with the orientation fixed up based on EXF data.
        This helps to normalise input images to always be the correct orientation when performing
        other core graphics tasks on the image.
        
        - parameter image: Image to create CGImageRef for
        
        - returns: CGImageRef with rotated/transformed image context
        */
        static func CGImageWithCorrectOrientation(image : UIImage) -> CGImageRef {
            
            if (image.imageOrientation == UIImageOrientation.Up) {
                return image.CGImage!
            }
            
            UIGraphicsBeginImageContextWithOptions(image.size, false, 0)
            
            let context = UIGraphicsGetCurrentContext()
            
            // TODO - handle other image orientations / mirrored states
            switch (image.imageOrientation) {
            case UIImageOrientation.Right:
                CGContextRotateCTM(context, CGFloat(90 * M_PI/180))
                break
            case UIImageOrientation.Left:
                CGContextRotateCTM(context, CGFloat(-90 * M_PI/180))
                break
            case UIImageOrientation.Down:
                CGContextRotateCTM(context, CGFloat(M_PI))
                break
            default:
                break
            }
            
            image.drawAtPoint(CGPointMake(0, 0));
            
            let cgImage = CGBitmapContextCreateImage(context);
            UIGraphicsEndImageContext();
            
            return cgImage!;
        }
        
               static func drawImageWithClosure(size: CGSize!, closure: (size: CGSize, context: CGContext) -> ()) -> UIImage {
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            closure(size: size, context: UIGraphicsGetCurrentContext())
            let image : UIImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
    }
    private var _lineSegments = [CGPoint](count: 4, repeatedValue: CGPoint())

}