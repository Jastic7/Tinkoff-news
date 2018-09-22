//
//  StringExtensions.swift
//  TinkoffDemo
//
//  Created by Andrey Morozov on 22.09.2018.
//  Copyright © 2018 Jastic7. All rights reserved.
//

import Foundation

extension String {
	var transformedByHtml: String? {
		guard let data = data(using: .utf8) else { return nil }
		do {
			return try NSAttributedString(data: data,
										  options: [.documentType: NSAttributedString.DocumentType.html,
													.characterEncoding: String.Encoding.utf8.rawValue],
										  documentAttributes: nil).string
		} catch {
			return nil
		}
	}
}
