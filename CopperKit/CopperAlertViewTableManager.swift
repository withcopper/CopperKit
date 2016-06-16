//
//  CopperAlertViewTableManager.swift
//  Copper
//
//  Created by Doug Williams on 4/25/16.
//  Copyright © 2016 Copper Technologies, Inc. All rights reserved.
//

import Foundation

protocol CopperAlertViewTableManagerDelegate: class {
    func actionWasPressed(action: C29AlertAction)
}

enum CopperAlertCellIdentifier: String {
    case HeaderImageCell = "com.copper.alert.headerImageCell"
    case TitleCell = "com.copper.alert.titleCell"
    case MessageCell = "com.copper.alert.messageCell"
    case ImageCell = "com.copper.alert.imageCell"
    case ActionButtonCell = "com.copper.alert.actionButtonCell"
    case InlineButtonCell = "com.copper.alert.inlineButtonCell"
    case TwoButtonCell = "com.copper.alert.twoButtonCell"
    case NumberPadCell = "com.copper.alert.numberPadCell"
    case PhoneNumberEntryCell = "com.copper.alert.phoneNumberEntryCell"
    case DigitEntryCell = "com.copper.alert.digitEntryCell"
}

struct CopperAlertTableRowConfig {
    let cellIdentifier: CopperAlertCellIdentifier
    var action: C29AlertAction! = nil
    var action2: C29AlertAction! = nil
    init(cellIdentifier: CopperAlertCellIdentifier, action: C29AlertAction! = nil, action2: C29AlertAction! = nil) {
        self.cellIdentifier = cellIdentifier
        self.action = action
        self.action2 = action2
    }
}

class CopperAlertViewTableManager: NSObject, UITableViewDataSource, UITableViewDelegate {

    var delegate: CopperAlertViewTableManagerDelegate?
    var dataSource: CopperAlertControllerDatasource?
    var alert: C29Alert!
        
    init(alert: C29Alert) {
        super.init()
        self.alert = alert
    }
    
    var phoneEntryCell: CopperAlertPhoneNumberEntryCell?
    var digitEntryCell: CopperAlertDigitEntryCell?
    var numberPadCell: CopperAlertNumberPadCell?
    var imageCell: CopperAlertImageCell?
    var messageCell: CopperAlertMessageCell?
    var titleCell: CopperAlertTitleCell?
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let config = configForIndexPath(indexPath)
        switch config.cellIdentifier {
        case .HeaderImageCell:
            let cell = tableView.dequeueReusableCellWithIdentifier(config.cellIdentifier.rawValue) as! CopperAlertHeaderImageCell
            cell.setupForAlert(alert)
            return cell
        case .TitleCell:
            if titleCell == nil {
                titleCell = tableView.dequeueReusableCellWithIdentifier(config.cellIdentifier.rawValue) as? CopperAlertTitleCell
            }
            titleCell!.setupForAlert(alert)
            return titleCell!
        case .MessageCell:
            if messageCell == nil {
                messageCell = tableView.dequeueReusableCellWithIdentifier(config.cellIdentifier.rawValue) as? CopperAlertMessageCell
            }
            messageCell!.setupForAlert(alert)
            return messageCell!
        case .ImageCell:
            if imageCell == nil {
                imageCell = tableView.dequeueReusableCellWithIdentifier(config.cellIdentifier.rawValue) as? CopperAlertImageCell

            }
            imageCell!.setupForAlert(alert)
            return imageCell!
        case .ActionButtonCell:
            let cell = tableView.dequeueReusableCellWithIdentifier(config.cellIdentifier.rawValue) as! CopperAlertActionButtonCell
            cell.setupForAlertAction(config.action)
            cell.delegate = self
            return cell
        case .InlineButtonCell:
            let cell = tableView.dequeueReusableCellWithIdentifier(config.cellIdentifier.rawValue) as! CopperAlertActionButtonCell
            cell.setupForAlertAction(config.action)
            cell.delegate = self
            return cell
        case .TwoButtonCell:
            let cell = tableView.dequeueReusableCellWithIdentifier(config.cellIdentifier.rawValue) as! CopperAlertTwoActionButtonCell
            cell.setupForAlertAction(config.action)
            cell.setupForAlertAction(config.action2)
            cell.delegate = self
            return cell
        case .PhoneNumberEntryCell:
            if phoneEntryCell == nil {
                phoneEntryCell = tableView.dequeueReusableCellWithIdentifier(config.cellIdentifier.rawValue) as? CopperAlertPhoneNumberEntryCell
                phoneEntryCell?.setup()
            }
            return phoneEntryCell!
        case .DigitEntryCell:
            if digitEntryCell == nil {
                digitEntryCell = tableView.dequeueReusableCellWithIdentifier(config.cellIdentifier.rawValue) as? CopperAlertDigitEntryCell
                digitEntryCell?.setup()
            }
            return digitEntryCell!
        case .NumberPadCell:
            if numberPadCell == nil {
                numberPadCell = tableView.dequeueReusableCellWithIdentifier(config.cellIdentifier.rawValue) as? CopperAlertNumberPadCell
                numberPadCell?.setup()
            }
            return numberPadCell!
        }
    }
    
    var identifiers: [CopperAlertTableRowConfig] {
        if let dataSource = dataSource {
            return dataSource.identifiers
        }
        // otherwise use the defaults
        var i = [CopperAlertTableRowConfig]()
        if alert.headerImage != nil {
            i.append(CopperAlertTableRowConfig(cellIdentifier: .HeaderImageCell))
        }
        if alert.title != nil {
            i.append(CopperAlertTableRowConfig(cellIdentifier: .TitleCell))
        }
        if alert.message != nil {
            i.append(CopperAlertTableRowConfig(cellIdentifier: .MessageCell))
        }
        if alert.image != nil {
            i.append(CopperAlertTableRowConfig(cellIdentifier: .ImageCell))
        }
        for action in alert.actions {
            let identifier: CopperAlertCellIdentifier
            switch action.format {
            case .Inline:
                identifier = .InlineButtonCell
            default:
                identifier = .ActionButtonCell
            }
            i.append(CopperAlertTableRowConfig(cellIdentifier: identifier, action: action))
        }
        return i
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return identifiers.count
    }
    
    func configForIndexPath(indexPath: NSIndexPath) -> CopperAlertTableRowConfig {
        return identifiers[indexPath.row]
    }
}

extension CopperAlertViewTableManager: CopperAlertTableViewCellDelegate {
    func actionWasPressed(action: C29AlertAction) {
        self.delegate?.actionWasPressed(action)
    }
}