//
//  ViewController.swift
//  BarToTab
//
//  Created by Kevin Stewart on 2021-10-16.
//

import UIKit

class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Save to Tab Bar Demo"
    view.backgroundColor = .green
    configureNavigationBar()
    setupView()
  }
  
  private func configureNavigationBar() {
    let navBarItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(didTapBarButtonItem(sender:)))
    navigationItem.rightBarButtonItem = navBarItem
  }
  
  private func setupView() {
    let insetBackgroundView = UIView()
    insetBackgroundView.translatesAutoresizingMaskIntoConstraints = false
    insetBackgroundView.backgroundColor = .systemIndigo
    view.addSubview(insetBackgroundView)
    NSLayoutConstraint.activate([
      insetBackgroundView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16.0),
      insetBackgroundView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16.0),
      insetBackgroundView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16.0),
      insetBackgroundView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16.0),
    ])
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "This is the view."
    label.textColor = .white
    insetBackgroundView.addSubview(label)
    NSLayoutConstraint.activate([
      label.centerXAnchor.constraint(equalTo: insetBackgroundView.centerXAnchor),
      label.centerYAnchor.constraint(equalTo: insetBackgroundView.centerYAnchor)
    ])
  }
  
  @objc func didTapBarButtonItem(sender: UIBarButtonItem) {
    performPageSnapshotAnimation()
  }
  
  private func performPageSnapshotAnimation() {
    guard let tabBarController = tabBarController else { return }
    guard let tabBarViewFrame = getSelectedTabBarItemFrame(from: tabBarController) else { return }
    
    // Capture snapshot of view inside safe area
    let snapshotBounds = CGRect(
      x: view.bounds.origin.x,
      y: view.bounds.origin.y + view.safeAreaInsets.top,
      width: view.bounds.width,
      height: view.bounds.height - view.safeAreaInsets.bottom - view.safeAreaInsets.top
    )
    guard let snapshot = view.resizableSnapshotView(
      from: snapshotBounds,
      afterScreenUpdates: true,
      withCapInsets: .zero
    ) else {
      return
    }
    
    snapshot.frame.origin.y = view.bounds.origin.y + view.safeAreaInsets.top
    tabBarController.view.addSubview(snapshot)
    
    let snapshotAspectRatio = snapshot.bounds.size.width / snapshot.bounds.size.height
    let terminalHeight = 60.0
    let terminalWidth = terminalHeight * snapshotAspectRatio
    
    UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseInOut], animations: {
      snapshot.frame = CGRect(
        x: tabBarViewFrame.origin.x + (tabBarViewFrame.width / 2.0) - (terminalWidth / 2.0),
        y: tabBarController.view.bounds.maxY - tabBarViewFrame.height,
        width: terminalWidth,
        height: terminalHeight
      )
    }, completion: { _ in
      UIView.animate(withDuration: 0.1) {
        snapshot.alpha = 0.0
      } completion: { _ in
        snapshot.removeFromSuperview()
      }
    })
  }
  
  private func getSelectedTabBarItemFrame(from tabBarController: UITabBarController) -> CGRect? {
    let sortedFrames = tabBarController.tabBar.subviews
      // Only the user-interactive subviews are valid candidates to be out selected tab bar item
      .filter { $0.isUserInteractionEnabled }
      // Sort by frame origin so we can figure out the correct order
      .sorted(by: { $0.frame.origin.x < $1.frame.origin.x })
      .map { $0.frame }
    
    if sortedFrames.indices.contains(tabBarController.selectedIndex) {
      return sortedFrames[tabBarController.selectedIndex]
    } else {
      return nil
    }
    
  }
}

