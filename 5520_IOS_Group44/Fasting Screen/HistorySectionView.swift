//
//  HistorySectionView.swift
//  5520_IOS_Group44
//
//  Created by LL on 2024/12/4.
//

import UIKit

class HistorySectionView: UIView {
    var titleLabel: UILabel!
    var tableView: UITableView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 4
        
        titleLabel = UILabel()
        titleLabel.text = "History"
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .systemPink
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 12
        tableView.backgroundColor = .clear
        tableView.register(HistoryTableViewCell.self, forCellReuseIdentifier: "HistoryCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
}

protocol HistoryTableViewCellDelegate: AnyObject {
    func didTapDeleteButton(in cell: HistoryTableViewCell)
    func didTapEditButton(in cell: HistoryTableViewCell)
}


class HistoryTableViewCell: UITableViewCell {
    var dateLabel: UILabel!
    var timeRangeLabel: UILabel!
    var deleteButton: UIButton!
    var editButton: UIButton!
    
    weak var delegate: HistoryTableViewCellDelegate?

    private func setupActions() {
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
    }

    @objc private func deleteButtonTapped() {
        delegate?.didTapDeleteButton(in: self)
    }

    @objc private func editButtonTapped() {
        delegate?.didTapEditButton(in: self)
    }

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupActions()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupActions()
        setupConstraints()
    }
    
    private func setupViews() {
        backgroundColor = .clear
        
        dateLabel = UILabel()
        dateLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        dateLabel.textColor = .label
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dateLabel)
        
        timeRangeLabel = UILabel()
        timeRangeLabel.font = .systemFont(ofSize: 14)
        timeRangeLabel.textColor = .secondaryLabel
        timeRangeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(timeRangeLabel)
        
        deleteButton = UIButton(type: .system)
        deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteButton.tintColor = .systemGray
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(deleteButton)
        
        editButton = UIButton(type: .system)
        editButton.setImage(UIImage(systemName: "pencil"), for: .normal)
        editButton.tintColor = .systemGray
        editButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(editButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            timeRangeLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            timeRangeLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            timeRangeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            deleteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            editButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            editButton.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -16)
        ])
    }

}
