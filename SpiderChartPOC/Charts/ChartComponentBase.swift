//  Created by Pankti Patel on 22/07/15.
//  Copyright (c) 2015 Pankti Patel. All rights reserved.


import Foundation
import UIKit

/// This class encapsulates everything both Axis and Legend have in common.
public class ChartComponentBase: NSObject
{
    /// flag that indicates if this component is enabled or not
    public var enabled = true
    
    public override init()
    {
        super.init()
    }

    public var isEnabled: Bool { return enabled; }
}
