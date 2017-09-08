//
//  QuotesTableViewController.swift
//  QuoteBook
//
//  Created by yusuf_kildan on 07/03/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout

let TotalNumberOfQuotes = 1030

class QuotesTableViewController: BaseTableViewController {
    
    fileprivate var quotes: [Quote]! = []
    fileprivate var lastQuoteIndex: Int! = 0
    
    fileprivate var category: String?
    fileprivate var author: String?
    
    // MARK: Constructors
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init() {
        super.init()
        commonInit()
    }
    
    init(withCategory category: String) {
        super.init()
        self.category = category
        self.title = category
        
        commonInit()
    }
    
    init(withAuthor author: String) {
        super.init()
        self.author = author
        self.title = author
        
        commonInit()
    }
    
    fileprivate func commonInit() {
        if category != nil || author != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customBackButton)
        }
    }
    
    // MARK: - View's Lifecyle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.primaryBackgroundColor()
        
        tableView.register(QuotesTableViewCell.classForCoder(),
                           forCellReuseIdentifier: QuotesTableViewCellReuseIdentifier)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        loadData(withRefresh: true)
    }
    
    // MARK: - Interface
    
    override func canPullToRefresh() -> Bool {
        return true
    }
    
    override func shouldShowLogoAsTitleView() -> Bool {
        return !(category != nil || author != nil)
    }
    
    // MARK: - Load Data
    
    @discardableResult override func loadData(withRefresh refresh: Bool) -> Bool {
        if !super.loadData(withRefresh: refresh) {
            return false
        }
        
        if refresh {
            lastQuoteIndex = 0
            quotes = []
            
            self.endRefreshing()
        }
        
        if let category = category {
            DatabaseManager.shared.getQuotesByCategory(category: category, completion: { (quotes) in
                self.quotes = quotes
                
                self.tableView.reloadData()
                self.finishLoading(withState: ControllerState.none, andMessage: nil)
            })
        } else if let author = author {
            DatabaseManager.shared.getQuotesByAuthor(author: author, completion: { (quotes) in
                self.quotes = quotes
                
                self.tableView.reloadData()
                self.finishLoading(withState: ControllerState.none, andMessage: nil)
            })
        } else {
            DatabaseManager.shared.getAllQuotes(lastQuoteIndex: lastQuoteIndex, completion: { (quotes) in
                self.canLoadMore = self.lastQuoteIndex < TotalNumberOfQuotes
                
                self.quotes = self.quotes + quotes
                self.lastQuoteIndex = quotes.last?.id
                
                self.tableView.reloadData()
                self.finishLoading(withState: ControllerState.none, andMessage: nil)
            })
        }
        
        return true
    }
    
    // MARK: - Configure
    
    fileprivate func configure(QuotesTableViewCell cell: QuotesTableViewCell, withIndexPath indexPath: IndexPath) {
        if indexPath.row >= quotes.count {
            return
        }
        
        let quote = quotes[indexPath.row]
        
        if let categoryName = quote.category_name {
            cell.category = categoryName
        }
        
        if let authorName = quote.author_name {
            cell.avatar = UIImage(named: authorName)
            cell.author = authorName
        }
        
        if let quote = quote.text?.trim() {
            cell.quote = quote
        }
    }
    
    // MARK: - Actions
    
    override func backButtonTapped(_ button: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDelegate

extension QuotesTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row >= quotes.count {
            return
        }
        
        let quote = quotes[indexPath.row]
        let controller = QuoteDetailViewController(withQuote: quote)
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension QuotesTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quotes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: QuotesTableViewCellReuseIdentifier) as! QuotesTableViewCell
        
        configure(QuotesTableViewCell: cell, withIndexPath: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return QuotesTableViewCell.cellHeight()
    }
}
