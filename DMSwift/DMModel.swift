//
//  DMModel.swift
//  DanmuSwift
//
//  Created by 袁祎凯 on 16/10/14.
//  Copyright © 2016年 paladin. All rights reserved.
//

import UIKit

protocol DMModelProtocol {
    func cellWidth() -> CGFloat;
    var configuration : Configuration {get set}
    var cellType: DMCellType {get set}
}

open class DMModel: NSObject, DMModelProtocol{
    internal var cellType: DMCellType = {
        let type : DMCellType = .DMCellNormal;
        return type;
    }()

    internal var configuration: Configuration = {
        let config : Configuration = Configuration.init();
        return config;
    }()
    public var content : String?
    public var width : CGFloat?
    
    public func cellWidth() -> CGFloat {
        let dic = NSDictionary.init(object: UIFont.systemFont(ofSize: 12), forKey: NSFontAttributeName as NSCopying);
        let rect : CGRect = (self.content! as NSString).boundingRect(with: CGSize.init(width: 0, height: 20), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: (dic as! [String : Any]), context: nil);
        return rect.size.width + 56;
    }
}

/// Cell 类型
///
/// - DMCellLeft:   滚动cell
/// - DMCellTop:    顶部cell
/// - DMCellBottom: 底部cell
public enum DMCellType {
    case DMCellNormal
    case DMCellTop
    case DMCellBottom
}



/// cell一些配置
class Configuration: NSObject {
    public var contentColor : UIColor?
}
