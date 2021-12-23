//
//  SwiftyAdWrapper.swift
//  Pilot Ace
//
//  Created by Sean Kosanovich on 8/25/20.
//  Copyright © 2020 Sean Kosanovich. All rights reserved.
//

import Foundation
import UIKit

// This class now does nothing. Keeping it around incase I decide to add ads back in, as the rest of the app knows how to handle this API

@objc class SwiftyAdsHelper: NSObject {

    @objc class var isRequiredToAskForConsent: Bool {
        return false
    }

    @objc class func setupAdsWithVc(_ viewController: UIViewController) {

    }

    @objc class func hideBannerAd() {

    }

    @objc class func showBannerAd(_ viewController: UIViewController) {

    }

    @objc class func requestFullscreenWithViewController(_ viewController: UIViewController, withInterval interval: Int) {

    }

    @objc class func askForConsentWithViewController(_ viewController: UIViewController) {

    }

}
