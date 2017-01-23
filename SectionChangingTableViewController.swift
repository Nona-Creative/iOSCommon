//
//  SectionChangingTableViewController.swift
//
//  Created by David O'Reilly on 2016/01/19.
//  Copyright © 2016 David O'Reilly All rights reserved.
//

import Foundation

protocol TableSection: RawRepresentable {}

/**
 Extension to UITableViewController to make it easy to have different sections that are toggled between using a header that partially scrolls offscreen
 and retain the correct scrolled positions.
 The table is arranged with a two part header - the part that scrolls off the top is implemented as a cell in section 0 row 0, and the part that remains visible
 is implemented as a secion header view for the following section.
 */
protocol SectionChangingTableViewController: class {
    associatedtype TableSectionType: TableSection
    /**
     The table content offset position for each section
     */
    var sectionOffsets: [CGFloat] { get set }
    /**
     Enum holding the different sections this table can switch between
     */
    var activeSection: TableSectionType { get set }
    /**
     The height of the section header view that that does not scroll offscreen
     */
    var sectionHeaderHeight: CGFloat { get }

    /**
     Switch to the specified table section
     */
    func switchToSection(_ section: TableSectionType)
    /**
     Returns true if the current section is busy loading
     */
    func isLoading() -> Bool

    /**
     The height of the empty cell that sits at the bottom of the table to ensure that
     all sections can scroll far enough to have the hideable part of the header (section 0 row 0) totally offscreen.
     */
    func emptyCellHeight() -> CGFloat

    /**
     Called when the table scrolls, to adjust the scroll indicator to sit under the header and record the current content offset for the section
     */
    func sectionScrollViewDidScroll()
}

extension SectionChangingTableViewController where Self: UITableViewController {

    /**
     Returns how much of the hideable section of the header is visible
     */
    var hideableHeaderOffset: CGFloat {
        var offset: CGFloat = 0
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) {
            offset = cell.bounds.size.height
            offset -= tableView.contentOffset.y
            if offset < 0 {
                offset = 0
            }
        }

        return offset
    }

    /**
     Returns true if the top section of the header is hidden
     */
    var hideableHeaderIsHidden: Bool {

        return hideableHeaderOffset == 0
    }

    /**
     Set the table view content and content offset correctly for the newly selected section
     */
    func updateContentOffsetForSectionChange() {
        let currentOffset = tableView.contentOffset.y
        let newOffset = sectionOffsets[activeSection.rawValue as! Int] // Save this here because scroll will get triggered by reload / layout
        let hideableHeaderWasHidden = hideableHeaderIsHidden
        tableView.reloadData() // Workaround for iOS bug - reloading only relevant sections causes seperator to appear above section header SOMETIMES
        tableView.layoutIfNeeded() // Needed so that offset change works properly
        if hideableHeaderWasHidden {
            tableView.setContentOffset(CGPoint(x: 0, y: newOffset), animated: false)
            if !hideableHeaderIsHidden {
                tableView.setContentOffset(CGPoint(x: 0, y: tableView.cellForRow(at: IndexPath(row: 0, section: 0))!.bounds.size.height), animated: false)
            }
        } else {
            tableView.setContentOffset(CGPoint(x: 0, y: currentOffset), animated: false)
        }
    }

    func sectionScrollViewDidScroll() {

        let offset = hideableHeaderOffset + sectionHeaderHeight // Underneath visible top header + all of bottom header
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(offset, 0, 0, 0)

        sectionOffsets[activeSection.rawValue as! Int] = tableView.contentOffset.y
    }
}
