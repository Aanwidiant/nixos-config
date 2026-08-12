pragma Singleton

import QtQuick

QtObject {
    // Font Sizes
    readonly property int text2XS: 8
    readonly property int textXS: 10
    readonly property int textSM: 12
    readonly property int textMD: 14
    readonly property int textLG: 16
    readonly property int textXL: 20
    readonly property int text2XL: 24
    readonly property int text3XL: 32
    readonly property int text4XL: 48
    readonly property int text5XL: 56

    // Icon Sizes
    readonly property int iconXS: 12
    readonly property int iconSM: 16
    readonly property int iconMD: 20
    readonly property int iconLG: 24
    readonly property int iconXL: 32

    // Radius
    readonly property int radius2XS: 4
    readonly property int radiusXS: 6
    readonly property int radiusSM: 8
    readonly property int radiusMD: 12
    readonly property int radiusLG: 16
    readonly property int radiusXL: 24
    readonly property int radiusFull: 9999

    // Spacing
    readonly property int spacingXS: 1
    readonly property int spacingSM: 2
    readonly property int spacingMD: 4
    readonly property int spacingLG: 8
    readonly property int spacingXL: 16
    readonly property int spacing2XL: 32

    // Animation
    readonly property int durationFast: 100
    readonly property int durationNormal: 200
    readonly property int durationSlow: 300
}
