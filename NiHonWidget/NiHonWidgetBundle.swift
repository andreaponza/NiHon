//
//  NiHonWidgetBundle.swift
//  NiHonWidget
//
//  Created by Andrea De Martino on 17/10/24.
//

import SwiftUI
import WidgetKit


@main
struct NiHonWidget: Widget {
    let kind: String = "NiHonWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WordProvider()) { entry in
            NiHonWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("NiHon Word Widget")
        .description("Displays a random Japanese word, its romaji, and its Italian translation every hour.")
    }
}
