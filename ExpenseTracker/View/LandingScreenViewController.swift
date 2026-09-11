//
//  LandingScreenViewController.swift
//  ExpenseTracker
//
//  Created by iPHTech 34 on 10/09/26.
//

import UIKit

final class LandingScreenViewController: UIViewController {

    private let vm = AuthVM(
        repository: AppContainer.shared.userRepository
    )

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // A valid session can land here after e.g. a cold start before
        // SceneDelegate routing — skip straight to the main app.
        if vm.isLoggedIn {
            SceneDelegate.of(self)?.showMain(animated: false)
        }
    }
}
