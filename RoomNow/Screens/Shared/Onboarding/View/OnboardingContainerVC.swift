//
//  OnboardingContainerVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 30.05.2025.
//

import UIKit

final class OnboardingContainerVC: UIViewController {

    private let viewModel = OnboardingVM()
    private var currentIndex = 0

    private lazy var pageVC: UIPageViewController = {
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        vc.dataSource = self
        vc.delegate = self
        return vc
    }()

    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.applyPrimaryOnboardingStyle(with: "Next")
        button.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setInitialPage()
    }

    private func setupUI() {
        view.backgroundColor = .appBackground
        addChild(pageVC)
        view.addSubview(pageVC.view)
        
        pageVC.didMove(toParent: self)
        pageVC.view.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(nextButton)
        nextButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            pageVC.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageVC.view.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -20),

            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 64),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -64),
            nextButton.heightAnchor.constraint(equalToConstant: 48),
        ])
    }

    private func setInitialPage() {
        if let first = viewController(at: 0) {
            pageVC.setViewControllers([first], direction: .forward, animated: true)
        }
    }

    @objc private func nextTapped() {
        currentIndex += 1
        if currentIndex < viewModel.pages.count {
            if let vc = viewController(at: currentIndex) {
                pageVC.setViewControllers([vc], direction: .forward, animated: true)
                nextButton.setTitle(currentIndex == viewModel.pages.count - 1 ? "Get Started" : "Next", for: .normal)
            }
        } else {
            UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
            goToMainApp()
        }
    }

    private func viewController(at index: Int) -> UIViewController? {
        guard index >= 0 && index < viewModel.pages.count else { return nil }
        return OnboardingPageVC(page: viewModel.pages[index])
    }

    private func goToMainApp() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        
        let tabBarVC = UserTabBarVC()
        tabBarVC.modalPresentationStyle = .fullScreen
        self.present(tabBarVC, animated: true)
    }
}

extension OnboardingContainerVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        currentIndex = max(currentIndex - 1, 0)
        return self.viewController(at: currentIndex)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let next = currentIndex + 1
        return self.viewController(at: next)
    }
}

