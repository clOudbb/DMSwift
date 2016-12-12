//
//  ViewController.swift
//  DanmuSwift
//
//  Created by 袁祎凯 on 16/10/14.
//  Copyright © 2016年 paladin. All rights reserved.
//

import UIKit

let kScreenWidth : CGFloat = UIScreen.main.bounds.size.width;
let kScreenHeight : CGFloat = UIScreen.main.bounds.size.height;

class ViewController: UIViewController, DMViewDataSource {
    
    public func DMViewWith(numberOfDmView dmView: DMView) -> Int {
        return 5;
    }

    public func DMViewWith(dmView: DMView, index: Int) -> DMCell {
//        var cell : DMCell = self.dView.retrieveCell(identifier: "DMCellIdentifierWithLeft");
//        if cell as DMCell! == nil {
//        let cell : DMCell = DMCell.init();
        let cell : CustomCell = CustomCell.init();
        cell.model = self.model;
//        }
//        cell.content = "123";
        return cell;
    }

    lazy var dView : DMView = {
        let dView : DMView = DMView.init(frame: CGRect.init(x: 0, y: 10, width: kScreenWidth, height: 200));
        dView.dataSource = self;
        dView.backgroundColor = UIColor.orange;
        return dView;
    }();
    
    let model : DMModel = {
        let m : DMModel = DMModel();
        let config : Configuration = Configuration();
        config.contentColor = UIColor.white;
        m.configuration = config;
        m.width = 50;
        m.content = "DarkFlameMaster";
        return m;
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.addSubview(self.dView);
        self.dView.sendDM(array: [self.model], isShow: true);
        
        let button : UIButton = UIButton.init(type: UIButtonType.custom);
        self.view.addSubview(button);
        button.backgroundColor = UIColor.orange;
        button.snp.makeConstraints { (make) in
            make.center.equalToSuperview();
            make.size.equalTo(CGSize.init(width: 50, height: 30));
        }
        button.addTarget(self, action: #selector(action(_ : )), for: .touchUpInside);
    }
    
    func action(_ button : UIButton) -> Void {
        self.dView.sendDM(array: [self.model], isShow: true);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

