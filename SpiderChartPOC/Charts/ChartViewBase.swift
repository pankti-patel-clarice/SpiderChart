//
//  ChartViewBase.swift
//  Charts
//
//  Created by Pankti Patel on 22/07/15.
//  Copyright (c) 2015 Pankti Patel. All rights reserved.

import Foundation
import UIKit


public class ChartViewBase: UIView
{
    // MARK: - Properties
    
    /// custom formatter that is used instead of the auto-formatter if set
    internal var _valueFormatter = NSNumberFormatter()
    
    /// the default value formatter
    internal var _defaultValueFormatter = NSNumberFormatter()
    
    /// object that holds all data that was originally set for the chart, before it was modified or any filtering algorithms had been applied
    internal var _data: ChartData!
    
    /// If set to true, chart continues to scroll after touch up
    public var dragDecelerationEnabled = true
    
    /// Deceleration friction coefficient in [0 ; 1] interval, higher values indicate that speed will decrease slowly, for example if it set to 0, it will stop immediately.
    /// 1 is an invalid value, and will be converted to 0.999 automatically.
    private var _dragDecelerationFrictionCoef: CGFloat = 0.9
    
    /// font object used for drawing the description text in the bottom right corner of the chart
    public var descriptionFont: UIFont? = UIFont(name: "HelveticaNeue", size: 9.0)
    public var descriptionTextColor: UIColor! = UIColor.blackColor()
    
    /// font object for drawing the information text when there are no values in the chart
    public var infoFont: UIFont! = UIFont(name: "HelveticaNeue", size: 12.0)
    public var infoTextColor: UIColor! = UIColor(red: 247.0/255.0, green: 189.0/255.0, blue: 51.0/255.0, alpha: 1.0) // orange
    
    /// description text that appears in the bottom right corner of the chart
    public var descriptionText = "Description"
    
    /// flag that indicates if the chart has been fed with data yet
    internal var _dataNotSet = true
    
    /// if true, units are drawn next to the values in the chart
    internal var _drawUnitInChart = false
    
    /// the number of x-values the chart displays
    internal var _deltaX = CGFloat(1.0)
    
    internal var _chartXMin = Double(0.0)
    internal var _chartXMax = Double(0.0)
    
    /// the legend object containing all data associated with the legend
    internal var _legend: ChartLegend!
    
    
    /// text that is displayed when the chart is empty
    public var noDataText = "No chart data available."
    
    /// text that is displayed when the chart is empty that describes why the chart is empty
    public var noDataTextDescription: String?
    
    internal var _legendRenderer: ChartLegendRenderer!
    
    /// object responsible for rendering the data
    public var renderer: ChartDataRendererBase?
    
    /// object that manages the bounds and drawing constraints of the chart
    internal var _viewPortHandler: ChartViewPortHandler!
    
    
    /// flag that indicates if offsets calculation has already been done or not
    private var _offsetsCalculated = false
    
    
    /// if set to true, the marker is drawn when a value is clicked
    public var drawMarkers = true
    
    
    private var _interceptTouchEvents = false
    
    /// An extra offset to be appended to the viewport's top
    public var extraTopOffset: CGFloat = 0.0
    
    /// An extra offset to be appended to the viewport's right
    public var extraRightOffset: CGFloat = 0.0
    
    /// An extra offset to be appended to the viewport's bottom
    public var extraBottomOffset: CGFloat = 0.0
    
    /// An extra offset to be appended to the viewport's left
    public var extraLeftOffset: CGFloat = 0.0
    
    public func setExtraOffsets(#left: CGFloat, top: CGFloat, right: CGFloat, bottom: CGFloat)
    {
        extraLeftOffset = left
        extraTopOffset = top
        extraRightOffset = right
        extraBottomOffset = bottom
    }
    
    // MARK: - Initializers
    
    public override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        initialize()
    }
    
    public required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        initialize()
    }
    
    deinit
    {
        self.removeObserver(self, forKeyPath: "bounds")
        self.removeObserver(self, forKeyPath: "frame")
    }
    
    internal func initialize()
    {

        _viewPortHandler = ChartViewPortHandler()
        _viewPortHandler.setChartDimens(width: bounds.size.width, height: bounds.size.height)
        
        _legend = ChartLegend()
        _legendRenderer = ChartLegendRenderer(viewPortHandler: _viewPortHandler, legend: _legend)
        
        _defaultValueFormatter.minimumIntegerDigits = 1
        _defaultValueFormatter.maximumFractionDigits = 1
        _defaultValueFormatter.minimumFractionDigits = 1
        _defaultValueFormatter.usesGroupingSeparator = true
        
        _valueFormatter = _defaultValueFormatter.copy() as! NSNumberFormatter
        
        self.addObserver(self, forKeyPath: "bounds", options: .New, context: nil)
        self.addObserver(self, forKeyPath: "frame", options: .New, context: nil)
    }
    
    // MARK: - ChartViewBase
    
    /// The data for the chart
    public var data: ChartData?
    {
        get
        {
            return _data
        }
        set
        {
            if (newValue == nil || newValue?.yValCount == 0)
            {
                println("Charts: data argument is nil on setData()")
                return
            }
            
            _dataNotSet = false
            _offsetsCalculated = false
            _data = newValue
            
            // calculate how many digits are needed
            calculateFormatter(min: _data.getYMin(), max: _data.getYMax())
            
            notifyDataSetChanged()
        }
    }
    
    /// Clears the chart from all data (sets it to null) and refreshes it (by calling setNeedsDisplay()).
    public func clear()
    {
        _data = nil
        _dataNotSet = true
        setNeedsDisplay()
    }
    
    /// Removes all DataSets (and thereby Entries) from the chart. Does not remove the x-values. Also refreshes the chart by calling setNeedsDisplay().
    public func clearValues()
    {
        if (_data !== nil)
        {
            _data.clearValues()
        }
        setNeedsDisplay()
    }
    
    /// Returns true if the chart is empty (meaning it's data object is either null or contains no entries).
    public func isEmpty() -> Bool
    {
        if (_data == nil)
        {
            return true
        }
        else
        {
            
            if (_data.yValCount <= 0)
            {
                return true
            }
            else
            {
                return false
            }
        }
    }
    
    /// Lets the chart know its underlying data has changed and should perform all necessary recalculations.
    public func notifyDataSetChanged()
    {
        fatalError("notifyDataSetChanged() cannot be called on ChartViewBase")
    }
    
    /// calculates the offsets of the chart to the border depending on the position of an eventual legend or depending on the length of the y-axis and x-axis labels and their position
    internal func calculateOffsets()
    {
        fatalError("calculateOffsets() cannot be called on ChartViewBase")
    }
    
    /// calcualtes the y-min and y-max value and the y-delta and x-delta value
    internal func calcMinMax()
    {
        fatalError("calcMinMax() cannot be called on ChartViewBase")
    }
    
    /// calculates the required number of digits for the values that might be drawn in the chart (if enabled), and creates the default value formatter
    internal func calculateFormatter(#min: Double, max: Double)
    {
        // check if a custom formatter is set or not
        var reference = Double(0.0)
        
        if (_data == nil || _data.xValCount < 2)
        {
            var absMin = fabs(min)
            var absMax = fabs(max)
            reference = absMin > absMax ? absMin : absMax
        }
        else
        {
            reference = fabs(max - min)
        }
        
        var digits = ChartUtils.decimals(reference)
    
        _defaultValueFormatter.maximumFractionDigits = digits
        _defaultValueFormatter.minimumFractionDigits = digits
    }
    
    public override func drawRect(rect: CGRect)
    {
        let context = UIGraphicsGetCurrentContext()
        let frame = self.bounds
        
        
        if (_dataNotSet || _data === nil || _data.yValCount == 0)
        { // check if there is data
            
            CGContextSaveGState(context)
            
            // if no data, inform the user
            
            ChartUtils.drawText(context: context, text: noDataText, point: CGPoint(x: frame.width / 2.0, y: frame.height / 2.0), align: .Center, attributes: [NSFontAttributeName: infoFont, NSForegroundColorAttributeName: infoTextColor])
            
            if (noDataTextDescription != nil && count(noDataTextDescription!) > 0)
            {   
                var textOffset = -infoFont.lineHeight / 2.0
                
                ChartUtils.drawText(context: context, text: noDataTextDescription!, point: CGPoint(x: frame.width / 2.0, y: frame.height / 2.0 + textOffset), align: .Center, attributes: [NSFontAttributeName: infoFont, NSForegroundColorAttributeName: infoTextColor])
            }
            
            return
        }
        
        if (!_offsetsCalculated)
        {
            calculateOffsets()
            _offsetsCalculated = true
        }
    }
    
    /// draws the description text in the bottom right corner of the chart
    internal func drawDescription(#context: CGContext)
    {
        if (descriptionText.lengthOfBytesUsingEncoding(NSUTF16StringEncoding) == 0)
        {
            return
        }
        
        let frame = self.bounds
        
        var attrs = [NSObject: AnyObject]()
        
        var font = descriptionFont
        
        if (font == nil)
        {
            font = UIFont.systemFontOfSize(UIFont.systemFontSize())
        }
        
        attrs[NSFontAttributeName] = font
        attrs[NSForegroundColorAttributeName] = descriptionTextColor
        
        ChartUtils.drawText(context: context, text: descriptionText, point: CGPoint(x: frame.width - _viewPortHandler.offsetRight - 10.0, y: frame.height - _viewPortHandler.offsetBottom - 10.0 - font!.lineHeight), align: .Right, attributes: attrs)
    }
    
    
    
    // MARK: - Accessors

    /// returns the total value (sum) of all y-values across all DataSets
    public var yValueSum: Double
    {
        return _data.yValueSum
    }

    /// returns the current y-max value across all DataSets
    public var chartYMax: Double
    {
        return _data.yMax
    }

    /// returns the current y-min value across all DataSets
    public var chartYMin: Double
    {
        return _data.yMin
    }
    
    public var chartXMax: Double
    {
        return _chartXMax
    }
    
    public var chartXMin: Double
    {
        return _chartXMin
    }
    
    /// returns the average value of all values the chart holds
    public func getAverage() -> Double
    {
        return yValueSum / Double(_data.yValCount)
    }
    
    /// returns the average value for a specific DataSet (with a specific label) in the chart
    public func getAverage(#dataSetLabel: String) -> Double
    {
        var ds = _data.getDataSetByLabel(dataSetLabel, ignorecase: true)
        if (ds == nil)
        {
            return 0.0
        }
        
        return ds!.yValueSum / Double(ds!.entryCount)
    }
    
    /// returns the total number of values the chart holds (across all DataSets)
    public var getValueCount: Int
    {
        return _data.yValCount
    }
    
    /// Returns the center point of the chart (the whole View) in pixels.
    /// Note: (Equivalent of getCenter() in MPAndroidChart, as center is already a standard in iOS that returns the center point relative to superview, and MPAndroidChart returns relative to self)
    public var midPoint: CGPoint
    {
        var bounds = self.bounds
        return CGPoint(x: bounds.origin.x + bounds.size.width / 2.0, y: bounds.origin.y + bounds.size.height / 2.0)
    }
    
    /// Returns the center of the chart taking offsets under consideration. (returns the center of the content rectangle)
    public var centerOffsets: CGPoint
    {
        return _viewPortHandler.contentCenter
    }
    
    /// Returns the Legend object of the chart. This method can be used to get an instance of the legend in order to customize the automatically generated Legend.
    public var legend: ChartLegend
    {
        return _legend
    }
    
    /// Returns the renderer object responsible for rendering / drawing the Legend.
    public var legendRenderer: ChartLegendRenderer!
    {
        return _legendRenderer
    }
    
    /// Returns the rectangle that defines the borders of the chart-value surface (into which the actual values are drawn).
    public var contentRect: CGRect
    {
        return _viewPortHandler.contentRect
    }
    
    /// Sets the formatter to be used for drawing the values inside the chart.
    /// If no formatter is set, the chart will automatically determine a reasonable
    /// formatting (concerning decimals) for all the values that are drawn inside
    /// the chart. Set this to nil to re-enable auto formatting.
    public var valueFormatter: NSNumberFormatter!
    {
        get
        {
            return _valueFormatter
        }
        set
        {
            if (newValue === nil)
            {
                _valueFormatter = _defaultValueFormatter.copy() as! NSNumberFormatter
            }
            else
            {
                _valueFormatter = newValue
            }
        }
    }
    
    /// returns the x-value at the given index
    public func getXValue(index: Int) -> String!
    {
        if (_data == nil || _data.xValCount <= index)
        {
            return nil
        }
        else
        {
            return _data.xVals[index]
        }
    }
    
    /// Get all Entry objects at the given index across all DataSets.
    public func getEntriesAtIndex(xIndex: Int) -> [ChartDataEntry]
    {
        var vals = [ChartDataEntry]()
        
        for (var i = 0, count = _data.dataSetCount; i < count; i++)
        {
            var set = _data.getDataSetByIndex(i)
            var e = set.entryForXIndex(xIndex)
            if (e !== nil)
            {
                vals.append(e!)
            }
        }
        
        return vals
    }
    
    /// returns the percentage the given value has of the total y-value sum
    public func percentOfTotal(val: Double) -> Double
    {
        return val / _data.yValueSum * 100.0
    }
    
    /// Returns the ViewPortHandler of the chart that is responsible for the
    /// content area of the chart and its offsets and dimensions.
    public var viewPortHandler: ChartViewPortHandler!
    {
        return _viewPortHandler
    }
    
    /// Returns the bitmap that represents the chart.
    public func getChartImage(#transparent: Bool) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(bounds.size, opaque || !transparent, UIScreen.mainScreen().scale)
        
        var context = UIGraphicsGetCurrentContext()
        var rect = CGRect(origin: CGPoint(x: 0, y: 0), size: bounds.size)
        
        if (opaque || !transparent)
        {
            // Background color may be partially transparent, we must fill with white if we want to output an opaque image
            CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
            CGContextFillRect(context, rect)
            
            if (self.backgroundColor !== nil)
            {
                CGContextSetFillColorWithColor(context, self.backgroundColor?.CGColor)
                CGContextFillRect(context, rect)
            }
        }
        
        layer.renderInContext(UIGraphicsGetCurrentContext())
        
        var image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
    
    public enum ImageFormat
    {
        case JPEG
        case PNG
    }
    
    /// Saves the current chart state with the given name to the given path on
    /// the sdcard leaving the path empty "" will put the saved file directly on
    /// the SD card chart is saved as a PNG image, example:
    /// saveToPath("myfilename", "foldername1/foldername2")
    ///
    /// :filePath: path to the image to save
    /// :format: the format to save
    /// :compressionQuality: compression quality for lossless formats (JPEG)
    ///
    /// :returns: true if the image was saved successfully
    public func saveToPath(path: String, format: ImageFormat, compressionQuality: Double) -> Bool
    {
        var image = getChartImage(transparent: format != .JPEG)

        var imageData: NSData!
        switch (format)
        {
        case .PNG:
            imageData = UIImagePNGRepresentation(image)
            break
            
        case .JPEG:
            imageData = UIImageJPEGRepresentation(image, CGFloat(compressionQuality))
            break
        }

        return imageData.writeToFile(path, atomically: true)
    }
    
    /// Saves the current state of the chart to the camera roll
    public func saveToCameraRoll()
    {
        UIImageWriteToSavedPhotosAlbum(getChartImage(transparent: false), nil, nil, nil)
    }
    
    internal typealias VoidClosureType = () -> ()
    internal var _sizeChangeEventActions = [VoidClosureType]()
    
    override public func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject: AnyObject], context: UnsafeMutablePointer<Void>)
    {
        if (keyPath == "bounds" || keyPath == "frame")
        {
            var bounds = self.bounds
            
            if (_viewPortHandler !== nil &&
                (bounds.size.width != _viewPortHandler.chartWidth ||
                bounds.size.height != _viewPortHandler.chartHeight))
            {
                _viewPortHandler.setChartDimens(width: bounds.size.width, height: bounds.size.height)
                
                // Finish any pending viewport changes
                while (!_sizeChangeEventActions.isEmpty)
                {
                    _sizeChangeEventActions.removeAtIndex(0)()
                }
                
                notifyDataSetChanged()
            }
        }
    }
    
    public func clearPendingViewPortChanges()
    {
        _sizeChangeEventActions.removeAll(keepCapacity: false)
    }
    
    /// if true, value highlighting is enabled
    public var highlightEnabled: Bool
    {
        get
        {
            return _data === nil ? true : _data.highlightEnabled
        }
        set
        {
            if (_data !== nil)
            {
                _data.highlightEnabled = newValue
            }
        }
    }
    
    /// if true, value highlightning is enabled
    public var isHighlightEnabled: Bool { return highlightEnabled }
    
    /// :returns: true if chart continues to scroll after touch up, false if not.
    /// :default: true
    public var isDragDecelerationEnabled: Bool
        {
            return dragDecelerationEnabled
    }
    
    /// Deceleration friction coefficient in [0 ; 1] interval, higher values indicate that speed will decrease slowly, for example if it set to 0, it will stop immediately.
    /// 1 is an invalid value, and will be converted to 0.999 automatically.
    /// :default: true
    public var dragDecelerationFrictionCoef: CGFloat
    {
        get
        {
            return _dragDecelerationFrictionCoef
        }
        set
        {
            var val = newValue
            if (val < 0.0)
            {
                val = 0.0
            }
            if (val >= 1.0)
            {
                val = 0.999
            }
            
            _dragDecelerationFrictionCoef = val
        }
    }
    
    
    // MARK: - Touches
    
    public override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        if (!_interceptTouchEvents)
        {
            super.touchesBegan(touches, withEvent: event)
        }
    }
    
    public override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        if (!_interceptTouchEvents)
        {
            super.touchesMoved(touches, withEvent: event)
        }
    }
    
    public override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        if (!_interceptTouchEvents)
        {
            super.touchesEnded(touches, withEvent: event)
        }
    }
    
    public override func touchesCancelled(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        if (!_interceptTouchEvents)
        {
            super.touchesCancelled(touches, withEvent: event)
        }
    }
}