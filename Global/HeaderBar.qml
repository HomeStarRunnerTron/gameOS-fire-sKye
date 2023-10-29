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

import QtQuick 2.12
import QtQuick.Layouts 1.11
import QtGraphicalEffects 1.10
import QtQml.Models 2.1
import "../utils.js" as Utils

FocusScope {
id: root

    property bool searchActive
    property bool onDownDirectionButton: false;
    property bool onDownTimeButton: false;
    property bool onDownFilterButton: false;

    onFocusChanged: buttonbar.currentIndex = 0;

    function toggleSearch() {
        searchActive = true;
    }

    Item {
    id: container

        anchors.fill: parent

        // Platform logo
        Image {
        id: logobg

            anchors.fill: platformlogo
            source: "../assets/images/gradient_white.png"
            asynchronous: true
            visible: false
        }

        Image {
        id: platformlogo
            anchors {
                top: parent.top; topMargin: vpx(10)
                left: parent.left; leftMargin: vpx(20)
            }
            height: vpx(60)
            fillMode: Image.PreserveAspectFit
            source: "../assets/images/logospng/" + Utils.processPlatformName(currentCollection.shortName) + ".png"
            sourceSize { width: 256; height: 256 }
            smooth: true
            visible: false
            asynchronous: true         
        }

        OpacityMask {
            anchors.fill: logobg
            source: logobg
            maskSource: platformlogo
            // Mouse/touch functionality
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: { searchTerm = ""; gamegrid.currentIndex = 0; previousScreen(); }
            }
        }

        // Platform title
        Text {
        id: softwareplatformtitle
            
            text: currentCollection.name
            
            anchors {
                top:    parent.top;
                left:   parent.left;    leftMargin: globalMargin
                right:  parent.right
                bottom: parent.bottom
            }
            
            color: theme.text
            font.family: titleFont.name
            font.pixelSize: vpx(30)
            font.bold: true
            horizontalAlignment: Text.AlignHLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            visible: platformlogo.status == Image.Error

            // Mouse/touch functionality
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: { searchTerm = ""; gamegrid.currentIndex = 0; previousScreen(); }
            }
        }

        ObjectModel {
        id: headermodel

            // Search bar
            Item {
            id: searchbar
                
                property bool selected: ListView.isCurrentItem && root.focus
                onSelectedChanged: if (!selected && searchActive) toggleSearch();

                width: (searchActive || searchTerm != "") ? vpx(250) : height
                height: vpx(40)

                Behavior on width {
                    PropertyAnimation { duration: 200; easing.type: Easing.OutQuart; easing.amplitude: 2.0; easing.period: 1.5 }
                }
                
                Rectangle {
                    width: parent.width
                    height: parent.height
                    color: searchbar.selected && !searchActive ? theme.accent : "white"
                    radius: height/2
                    opacity: searchbar.selected && !searchActive ? 1 : searchActive ? 0.4 : 0.2

                }

                Image {
                id: searchicon

                    width: height
                    height: vpx(18)
                    anchors { 
                        left: parent.left; leftMargin: vpx(11)
                        top: parent.top; topMargin: vpx(10)
                    }
                    source: "../assets/images/searchicon.svg"
                    opacity: searchbar.selected && !searchActive ? 1 : searchActive ? 0.8 : 0.5
                }

                TextInput {
                id: searchInput
                    
                    anchors { 
                        left: searchicon.right; leftMargin: vpx(10)
                        top: parent.top; bottom: parent.bottom
                        right: parent.right; rightMargin: vpx(15)
                    }
                    verticalAlignment: Text.AlignVCenter
                    color: theme.text
                    focus: searchbar.selected && searchActive
                    font.family: subtitleFont.name
                    font.pixelSize: vpx(18)
                    clip: true
                    text: searchTerm
                    onTextEdited: {
                        reselecting = true;
                        var tempIndex = gamegrid.currentIndex;
                        if (gamegrid.count <= settings.GridColumns && gamegrid.count > 0) {
                            gamegrid.currentIndex = -1;
                            gamegrid.currentIndex = tempIndex;
                        } else {
                            gamegrid.currentIndex = 0;
                            gamegrid.currentIndex = tempIndex;
                        }
                        if (gamegrid.currentIndex > gamegrid.count || gamegrid.currentIndex < 0) {
                            gamegrid.currentIndex = 0;
                        }
                        searchTerm = searchInput.text
                    }
                }

                // Mouse/touch functionality
                MouseArea {
                    anchors.fill: parent
                    enabled: !searchActive
                    hoverEnabled: true
                    onEntered: {}
                    onExited: {}
                    onClicked: {
                        if (!searchActive)
                        {
                            toggleSearch();
                        }
                    }
                }
                
                Component.onCompleted: { toggleSearch(); sortByIndex = storedSortIndex; }

                Keys.onPressed: {
                    // Accept
                    if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                        event.accepted = true;
                        if (!searchActive) {
                            toggleSearch();
                        }
                    }
                }
            }

            // Ascending/descending
            Item {
            id: directionbutton

                property bool selected: ListView.isCurrentItem && root.focus
                width: directiontitle.contentWidth + vpx(30)
                height: searchbar.height

                Rectangle
                { 
                    anchors.fill: parent
                    radius: height/2
                    color: theme.accent
                    visible: directionbutton.selected || onDownDirectionButton == true
                }

                Text {
                id: directiontitle
                    
                    text: (orderBy === Qt.AscendingOrder) ? "Ascending" : "Descending"
                                    
                    color: theme.text
                    font.family: subtitleFont.name
                    font.pixelSize: vpx(18)
                    anchors.centerIn: parent
                    elide: Text.ElideRight
                }
                
                // Mouse/touch functionality
                MouseArea {
                    anchors.fill: parent
                    onEntered: {onDownDirectionButton = true;}
                    onExited: {onDownDirectionButton = false;}
                    onClicked: {
                        if (sortByFilter[sortByIndex] == "sortBy") {
                            var tempIndex = (gamegrid.currentIndex - (gamegrid.count-1))*-1;
                                gamegrid.currentIndex = 0;
                                toggleOrderBy();
                                gamegrid.currentIndex = tempIndex;
                                reselecting = true;
                        } else {
                            gamegrid.currentIndex = 0;
                        }
                    }
                }

                Keys.onPressed: {
                    // Accept
                    if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                        event.accepted = true;
                        toggleOrderBy();
                        gamegrid.currentIndex = 0;
                    }
                }
            }

            // Order by title
            Item {
            id: titlebutton

                property bool selected: ListView.isCurrentItem && root.focus
                width: ordertitle.contentWidth + vpx(30)
                height: searchbar.height

                Rectangle
                { 
                    anchors.fill: parent
                    radius: height/2
                    color: theme.accent
                    visible: titlebutton.selected || onDownTimeButton == true
                }

                Text {
                id: ordertitle
                    
                    text: if (sortByFilter[sortByIndex] == "sortBy") {
                            "Sort by Title";
                        } else if (sortByFilter[sortByIndex] == "lastPlayed") {
                            "Sort by Last Opened";
                        } else if (sortByFilter[sortByIndex] == "playTime") {
                            "Sort by Time Spent";
                        }
                                    
                    color: theme.text
                    font.family: subtitleFont.name
                    font.pixelSize: vpx(18)
                    anchors.centerIn: parent
                    elide: Text.ElideRight
                }
                
                // Mouse/touch functionality
                MouseArea {
                    anchors.fill: parent
                    onEntered: {onDownTimeButton = true;}
                    onExited: {onDownTimeButton = false;}
                    onClicked: {
                        gamegrid.currentIndex = 0;
                        cycleSort();
                        gamegrid.currentIndex = 0;
                    }
                }

                Keys.onPressed: {
                    // Accept
                    if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                        event.accepted = true;
                        cycleSort();
                        gamegrid.currentIndex = 0;
                    }
                }
            }
            
            // Filters menu
            Item {
            id: filterbutton

                property bool selected: ListView.isCurrentItem && root.focus
                width: filtertitle.contentWidth + vpx(30)
                height: searchbar.height

                Rectangle
                { 
                    anchors.fill: parent
                    radius: height/2
                    color: theme.accent
                    visible: filterbutton.selected || onDownFilterButton == true
                }
                
                // Filter title
                Text {
                id: filtertitle
                    
                    text: (showFavs) ? "Favorites" : "Show All"
                                    
                    color: theme.text
                    font.family: subtitleFont.name
                    font.pixelSize: vpx(18)
                    anchors.centerIn: parent
                    elide: Text.ElideRight
                }
                
                // Mouse/touch functionality
                MouseArea {
                    anchors.fill: parent
                    onEntered: {onDownFilterButton = true;}
                    onExited: {onDownFilterButton = false;}
                    onClicked: {
                        gamegrid.currentIndex = 0;
                        toggleFavs();
                        gamegrid.currentIndex = 0;
                    }
                }

                Keys.onPressed: {
                    // Accept
                    if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                        event.accepted = true;
                        toggleFavs();
                        gamegrid.currentIndex = 0;
                    }
                }
            }
        }

        // Buttons
        ListView {
        id: buttonbar

            focus: true
            model: headermodel
            spacing: vpx(10)
            orientation: ListView.Horizontal
            layoutDirection: Qt.RightToLeft
            anchors {
                right: parent.right; rightMargin: globalMargin
                left: parent.left; top: parent.top; topMargin: vpx(15)
            }
        }
        
        // Mouse/touch functionality
        MouseArea {
                    anchors.fill: parent
                    onEntered: {}
                    onExited: {}
                    onClicked: {gamegrid.focus = true;}
                    z: -100
        }
        
    }

}