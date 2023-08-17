// gameOS theme
// Copyright (C) 2018-2020 Seth Powell 
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

import QtQuick 2.0
import QtQuick.Layouts 1.11
import "qrc:/qmlutils" as PegasusUtils

Item {
id: infocontainer

    property var gameData: currentGame

    // Game title
    Text {
    id: gametitle
        
        text: gameData ? gameData.title : ""
        
        anchors {
            top:    parent.top;
            left:   parent.left;
            right:  parent.right
        }
        
        color: theme.text
        font.family: titleFont.name
        font.pixelSize: vpx(44)
        font.bold: true
        horizontalAlignment: Text.AlignHLeft
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        wrapMode: Text.WordWrap
    }

    // Meta data
    Item {
    id: metarow

        height: vpx(50)
        anchors {
            top: gametitle.bottom; 
            left: parent.left
            right: parent.right
        }

        // Players box
        Text {
        id: playerstitle

            width: contentWidth
            height: parent.height
            anchors { leftMargin: vpx(25) }
            verticalAlignment: Text.AlignVCenter
            text: "Time Spent: "
            font.pixelSize: vpx(16)
            font.family: subtitleFont.name
            font.bold: true
            color: theme.textgrey
        }

        Text {
        id: playerstext

            width: contentWidth
            height: parent.height
            anchors { left: playerstitle.right; leftMargin: vpx(5) }
            verticalAlignment: Text.AlignVCenter
            text: {
            function formatplayTime(timeSecs) {
                var hours = Math.floor(timeSecs / (60 * 60));
                var minutes = Math.floor((timeSecs % (60 * 60)) / 60);
                var hoursWord = "";
                var minutesWord = "";
                var timecompositeWord = "";
                
                if (hours == 1) {
                    hoursWord = " hour, ";
                } else {
                    hoursWord = " hours, "
                }
                
                if (minutes == 1) {
                    minutesWord = " minute";
                } else {
                    minutesWord = " minutes"
                }
                
                if (hours == 0 && minutes == 0) {
                    timecompositeWord = minutes + minutesWord;
                } else if (hours == 0 && minutes != 0) {
                    timecompositeWord = minutes + minutesWord;
                } else if (hours != 0 && minutes == 0) {
                    timecompositeWord = hours + hoursWord;
                } else if (hours != 0 && minutes != 0) {
                    timecompositeWord = hours + hoursWord + minutes + minutesWord;
                }
                
                return timecompositeWord;
            }
            return "" + formatplayTime(game ? game.playTime : 0);
            }
            font.pixelSize: vpx(16)
            font.family: subtitleFont.name
            color: theme.text
        }

        Rectangle {
        id: divider2
            width: vpx(2)
            anchors {
                left: playerstext.right; leftMargin: (25)
                top: parent.top; topMargin: vpx(10)
                bottom: parent.bottom; bottomMargin: vpx(10)
            }
            opacity: 0.2
        }

        // Genre box
        Text {
        id: genretitle

            width: contentWidth
            height: parent.height
            anchors { left: divider2.right; leftMargin: vpx(25) }
            verticalAlignment: Text.AlignVCenter
            text: "Genre: "
            font.pixelSize: vpx(16)
            font.family: subtitleFont.name
            font.bold: true
            color: theme.textgrey
        }

        Text {
        id: genretext

            anchors { 
                left: genretitle.right; leftMargin: vpx(5)
                right: parent.right
                top: parent.top
                bottom: parent.bottom
            }
            verticalAlignment: Text.AlignVCenter
            text: gameData ? gameData.genre : ""
            font.pixelSize: vpx(16)
            font.family: subtitleFont.name
            elide: Text.ElideRight
            color: theme.text
        }
    }
    
}