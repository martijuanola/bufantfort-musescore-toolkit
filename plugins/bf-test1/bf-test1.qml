import QtQuick
//import QtQuick.Controls

import MuseScore 3.0
import Muse.Ui
import Muse.UiComponents

/*

Author: Martí Juanola

My BF Test Plugin

*/
MuseScore {

    title: "my bf-test1 plugin"
    //thumbnailName: "???"
    categoryCode: "composing-arranging-tools"
    pluginType: "dialog" // Others are: "docked" (doesn't work for 4.x), and not set

    version: "0.1"
    description: qsTr("Apply lyrics in lilypond format.")

    //requiresScore: true

    width: 800
    height: 400

    onRun: {}

    Item {
        id: window

        anchors.fill: parent

        Rectangle {
            anchors.fill: parent

            color: ui.theme.textFieldColor
            border.color: ui.theme.strokeColor
            border.width: Math.max(ui.theme.borderWidth, 1)
            radius: 3
        }
    }
}
