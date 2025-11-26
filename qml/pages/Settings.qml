// This file is part of harbour-pipes.
// SPDX-FileCopyrightText: 2025 Mirian Margiani
// SPDX-FileCopyrightText: 2022 Arusekk
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../DB.js" as DB

Page {
    id: settingsPage
    allowedOrientations: Orientation.All

    RemorsePopup { id: remorseSettings }
    Column {
        spacing: Theme.paddingMedium
        width: parent.width

        PageHeader { title: qsTr("Settings") }
        TextSwitch {
            checked: DB.getParameter("increasingDifficulty") === 1
            text: qsTr("Increasing difficulty")
            description: checked ?
                qsTr("Difficulty will increase whenever you complete a level") :
                qsTr("You must increase difficulty yourself in this settings page")
            onClicked: DB.setParameter("increasingDifficulty", checked ? 1 : 0)
        }
        Slider {
            id: sliderX
            width: parent.width
            label: qsTr("Horizontal dimension")
            minimumValue: 2
            maximumValue: game.maximumDimension
            stepSize: 1
            value: game.dimensionX
            valueText: value
        }
        Slider {
            id: sliderY
            width: parent.width
            label: qsTr("Vertical dimension")
            minimumValue: 2
            maximumValue: game.maximumDimension
            stepSize: 1
            value: game.dimensionY
            valueText: value
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 2*x
            x: Theme.horizontalPageMargin

            text: qsTr("Warning: the selected size exceeds the recommended " +
                       "maximum of %n tiles. The game may become really slow.",
                       "", game.recommendedMaximumTiles)
            color: Theme.errorColor
            wrapMode: Text.Wrap
            visible: sliderX.value * sliderY.value > game.recommendedMaximumTiles

            topPadding: Theme.paddingLarge
            bottomPadding: Theme.paddingLarge
        }

        Item {
            width: parent.width
            height: 2 * Theme.paddingLarge
        }

        ButtonLayout {
            preferredWidth: Theme.buttonWidthLarge

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Clear saved progress and settings")
                onClicked: {
                    remorseSettings.execute(qsTr("Clearing all databases"), function(){
                        DB.destroyData()
                        DB.initialize()
                    })
                }
            }
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Clear saved progress")
                onClicked: {
                    remorseSettings.execute(qsTr("Clearing saved progress database"), function(){
                        DB.destroySaves()
                        DB.initializeSaves()
                    })
                }
            }
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Reset settings")
                onClicked: {
                    remorseSettings.execute(qsTr("Resetting settings"), function(){
                        DB.destroySettings()
                        pageStack.pop()
                    })
                }
            }
        }

    }
    Component.onDestruction: {
        game.pause = false

        if (game.dimensionX != sliderX.value
                || game.dimensionY != sliderY.value) {
            // Make sure to only regenerate the grid if
            // the dimensions have changed, and only after
            // both variables are updated.
            game.completedSet = false
            game.dimensionX = sliderX.value
            game.dimensionY = sliderY.value
            game.completedSet = true
            game.gridUpdated()
        }
    }
}
