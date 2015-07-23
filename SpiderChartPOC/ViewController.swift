//
//  ViewController.swift
//  SpiderChartPOC
//
//  Created by Pankti Patel on 22/07/15.
//  Copyright (c) 2015 Pankti Patel. All rights reserved.
//

import UIKit



class ViewController: UIViewController {

    @IBOutlet var chartView: RadarChartView!


    var talents = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 1...6{
            
            talents.append("talent \(i)")
            
        }
        
        chartView!.descriptionText = ""
        chartView!.webLineWidth = 0.75
        chartView!.innerWebLineWidth = 0.375
        chartView!.webAlpha = 1.0

        var xAxis:ChartXAxis = chartView!.xAxis
        xAxis.labelFont = UIFont(name: "HelveticaNeue-Light", size: 9)!

        var yAxis:ChartYAxis = chartView!.yAxis
        yAxis.labelFont = UIFont(name: "HelveticaNeue-Light", size: 0)!
        yAxis.labelTextColor = UIColor.clearColor()
        yAxis.labelCount = talents.count
        
        // set image
        chartView.drawImage = UIImage(named: "photo.jpg")
        
        setData()


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setData()
    {
        var mult:Double = 10
        
        var xVals = Array<String>()
        
        for  i in 0..<talents.count
        {
            xVals.append(talents[i])
        }
        
        var yVals1 = Array<ChartDataEntry>()
        var yVals2 = Array<ChartDataEntry>()
        
        
        for i in 0..<5
        {
            
            var data = ChartDataEntry(value: Double(arc4random_uniform(UInt32(mult))) + mult / 2, xIndex: i)
            yVals1.append(data)
            yVals2.append(data)
        }

        var set1:RadarChartDataSet =  RadarChartDataSet(yVals: yVals1, label: "")
        set1.setColor(UIColor.blackColor())
        set1.drawFilledEnabled = true;
        set1.lineWidth = 1
        
        var set2:RadarChartDataSet =  RadarChartDataSet(yVals: yVals2, label: "")
        set2.setColor(UIColor.blackColor())
        set2.drawFilledEnabled = true;
        set2.lineWidth = 1

        var dataSet : [ChartDataSet] = [set1,set2]
        
        var data:RadarChartData = RadarChartData(xVals: xVals, dataSets: dataSet)
        data.setDrawValues(false)
        chartView!.data = data
    }



}

