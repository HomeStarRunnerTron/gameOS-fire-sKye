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

import QtQuick 2.3
import QtQuick.Layouts 1.11
import QtGraphicalEffects 1.12
import "../Global"
import "../Lists"
import "../utils.js" as Utils

FocusScope {
id: root
    
    // While not necessary to do it here, this means we don't need to change it in both
    // touch and gamepad functions each time
    function gameActivated() {
        storedCollectionGameIndex = gamegrid.currentIndex
        gameDetails(list.currentGame(gamegrid.currentIndex));
        gamegrid.currentIndex = gamegrid.currentIndex + 1;
        gamegrid.currentIndex = gamegrid.currentIndex - 1;
    }

    property var sortedGames;
    property var sortedGamesRedo;
    property var charReverse;
    property var charCode;
    
    property bool isLeftTriggerPressed: false;
    property bool isRightTriggerPressed: false;
    property bool reselecting: true;

    function prevChar(c) {
        charReverse = String.fromCharCode(c);
    }

    function nextChar(c, modifier, order) {
        reselecting = false;
        const firstAlpha = 97;
        const lastAlpha = 122;
        
        if (order == "ascending") {
            charCode = c.charCodeAt(0) + modifier;
        if (modifier > 0) { // Scroll down
            if (charCode < firstAlpha || isNaN(charCode)) {
                return 'a';
            }
            if (charCode > lastAlpha) {
                return '';
            }
        } else { // Scroll up
            if (charCode == firstAlpha - 1) {
                return '';
            }
            if (charCode < firstAlpha || charCode > lastAlpha || isNaN(charCode)) {
                return 'z';
            }
        }
        } else if (order == "descending") {
            charCode = c.charCodeAt(0) - modifier;
            var charCodeReverse = charCode - modifier;
            prevChar(charCodeReverse);
        if (modifier < 0) { // Scroll up
            if (charCode < firstAlpha || isNaN(charCode)) {
                return 'a';
            }
            if (charCode > lastAlpha) {
                return '';
            }
        } else { // Scroll down
            if (charCode == firstAlpha - 1) {
                return '';
            }
            if (charCode < firstAlpha || charCode > lastAlpha || isNaN(charCode)) {
                return 'z';
            }
        }
        }
        
        return String.fromCharCode(charCode);
    }

    function navigateToNextLetter(modifier) {
        reselecting = false;
        if (isRightTriggerPressed || isLeftTriggerPressed) {
            return false;
        }

        if (sortByFilter[sortByIndex].toLowerCase() != "sortby") {
            navigationErrorOpacityAnimator.running = false
            navigationError.text = "Navigating by letter is only compatible on<br>Show All + Sort by Title without Search Terms.";
            navigationOverlay2.opacity = 0.8;
            navigationErrorOpacityAnimator.running = true
            return false;
        }
        
        if (showFavs == true) {
            navigationErrorOpacityAnimator.running = false
            navigationError.text = "Navigating by letter is only compatible on<br>Show All + Sort by Title without Search Terms.";
            navigationOverlay2.opacity = 0.8;
            navigationErrorOpacityAnimator.running = true
            return false;
        }
        
        if (searchTerm != "") {
            navigationErrorOpacityAnimator.running = false
            navigationError.text = "Navigating by letter is only compatible on<br>Show All + Sort by Title without Search Terms.";
            navigationOverlay2.opacity = 0.8;
            navigationErrorOpacityAnimator.running = true
            return false;
        }

        var currentIndex = gamegrid.currentIndex;
        if (currentIndex == -1) {
            gamegrid.currentIndex = 0;
        }
        else {
            
            var currentGameTitle;
            var currentLetter;
            const firstAlpha = 97;
            const lastAlpha = 122;
            
            if (orderBy === Qt.AscendingOrder) {
                sortedGames = list.collection.games.toVarArray().map(g => g.sortBy.toLowerCase()).sort((a, b) => a.localeCompare(b));
            } else if (orderBy === Qt.DescendingOrder) {
                sortedGames = list.collection.games.toVarArray().map(g => g.sortBy.toLowerCase()).sort((a, b) => b.localeCompare(a));
                sortedGamesRedo = list.collection.games.toVarArray().map(g => g.sortBy.toLowerCase()).sort((a, b) => a.localeCompare(b));
            }

            currentGameTitle = sortedGames[currentIndex];
            currentLetter = currentGameTitle.toLowerCase().charAt(0);

            if (currentLetter.charCodeAt(0) < firstAlpha || currentLetter.charCodeAt(0) > lastAlpha) {
                currentLetter = '';
            }

            var nextIndex = currentIndex;
            var nextLetter = currentLetter;

            do {
                do {
                    if (orderBy === Qt.AscendingOrder) {
                        nextLetter = nextChar(nextLetter, modifier, "ascending");
                    } else if (orderBy === Qt.DescendingOrder) {
                        nextLetter = nextChar(nextLetter, modifier, "descending");
                    }

                    if (currentLetter == nextLetter) {
                        break;
                    }

                    if (nextLetter == '') {
                        if (sortedGames.some(g => g.toLowerCase().charCodeAt(0) < firstAlpha || g.toLowerCase().charCodeAt(0) > lastAlpha)) {
                            break;
                        }
                    }
                    else if (sortedGames.some(g => g.charAt(0) == nextLetter)) {
                        break;
                    }
                } while (true)
                if (orderBy === Qt.AscendingOrder) {
                    nextIndex = sortedGames.findIndex(g => g.toLowerCase().localeCompare(nextLetter) >= 0);
                } else if (orderBy === Qt.DescendingOrder) {
                    if (modifier == +1) {
                        nextIndex = sortedGamesRedo.findIndex(g => g.toLowerCase().localeCompare(currentLetter) >= 0);
                        nextIndex = (nextIndex - (sortedGames.length))*-1;
                    } else if (modifier == -1) {
                        nextIndex = sortedGamesRedo.findIndex(g => g.toLowerCase().localeCompare(charReverse) >= 0);
                        nextIndex = (nextIndex - (sortedGames.length))*-1;
                    }
                }
            } while(nextIndex === -1)
            
            if (orderBy === Qt.AscendingOrder) {
                gamegrid.currentIndex = nextIndex;
            } else if (orderBy === Qt.DescendingOrder) {
                if (nextIndex == sortedGames.length && modifier == -1) {
                    if (charCode > lastAlpha) {
                        nextIndex = sortedGamesRedo.findIndex(g => g.toLowerCase().localeCompare("a") >= 0);
                        nextIndex = (nextIndex - (sortedGames.length))*-1;
                        gamegrid.currentIndex = nextIndex;
                    } else if (currentLetter == "") {
                        nextIndex = sortedGamesRedo.findIndex(g => g.toLowerCase().localeCompare("b") >= 0);
                        nextIndex = (nextIndex - (sortedGames.length))*-1;
                        gamegrid.currentIndex = nextIndex;
                    } else if (nextLetter == "a" && modifier == -1) {
                        nextIndex = sortedGamesRedo.findIndex(g => g.toLowerCase().localeCompare("a") >= 0);
                        nextIndex = (nextIndex - (sortedGames.length)+1)*-1;
                        gamegrid.currentIndex = nextIndex;
                    } else {
                        gamegrid.currentIndex = 0;
                        nextIndex = 0;
                    }
                } else if (nextIndex == sortedGames.length && modifier == +1) {
                    gamegrid.currentIndex = 0;
                    nextIndex = 0;
                } else if (nextIndex == sortedGames.length && modifier == +1) {
                    gamegrid.currentIndex = 0;
                    nextIndex = 0;
                } else if (nextIndex == sortedGames.length+1 && modifier == -1) {
                    gamegrid.currentIndex = 0;
                    nextIndex = 0;
                } else {
                    gamegrid.currentIndex = nextIndex;
                }
            }
            
            nextLetter = sortedGames[nextIndex].toLowerCase().charAt(0);
            var nextLetterCharCode = nextLetter.charCodeAt(0);
            if (nextLetterCharCode < firstAlpha || nextLetterCharCode > lastAlpha) {
                nextLetter = '#';
            }

            navigationLetterOpacityAnimator.running = false
            navigationLetter.text = nextLetter.toUpperCase();
            navigationOverlay.opacity = 0.8;
            navigationLetterOpacityAnimator.running = true
        }

        gamegrid.focus = true;
        sfxToggle.play();

        return true;
    }

    ListCollectionGames { id: list; }

    // Load settings
    property bool showBoxes: settings.GridThumbnail === "Box Art"
    property int numColumns: settings.GridColumns ? settings.GridColumns : 6
    property int titleMargin: settings.AlwaysShowTitles === "Yes" ? vpx(30) : 0

    GridSpacer {
    id: fakebox

        width: vpx(100); height: vpx(100)
        games: list.games
    }

    Rectangle {
    id: navigationOverlay
        anchors.fill: parent;
        color: theme.main
        opacity: 0
        z: 10

        Text {
        id: navigationLetter
            antialiasing: true
            renderType: Text.QtRendering
            font.hintingPreference: Font.PreferNoHinting
            font.family: titleFont.name
            font.capitalization: Font.AllUppercase
            font.pixelSize: vpx(200)
            color: "white"
            anchors.centerIn: parent
        }

        SequentialAnimation {
        id: navigationLetterOpacityAnimator
            PauseAnimation { duration: 500 }
            OpacityAnimator {

                target: navigationOverlay
                from: navigationOverlay.opacity
                to: 0;
                duration: 500
            }
        }
    }
    
    Rectangle {
    id: navigationOverlay2
        anchors.fill: parent;
        color: theme.main
        opacity: 0
        z: 10

        Text {
        id: navigationError
            antialiasing: true
            renderType: Text.QtRendering
            font.hintingPreference: Font.PreferNoHinting
            font.family: titleFont.name
            font.pixelSize: vpx(25)
            color: "white"
            anchors.centerIn: parent
        }

        SequentialAnimation {
        id: navigationErrorOpacityAnimator
            PauseAnimation { duration: 1250 }
            OpacityAnimator {

                target: navigationOverlay2
                from: navigationOverlay2.opacity
                to: 0;
                duration: 500
            }
        }
    }

    Rectangle {
    id: header

        anchors {
            top:    parent.top
            left:   parent.left
            right:  parent.right
        }
        height: vpx(75)
        color: theme.main
        z: 5

        HeaderBar {
        id: headercontainer

            anchors.fill: parent
        }
        Keys.onDownPressed: {
            sfxNav.play();
            gamegrid.focus = true;
            if (gamegrid.currentIndex > -1) {
                gamegrid.currentIndex = gamegrid.currentIndex + 1;
                gamegrid.currentIndex = gamegrid.currentIndex - 1;
            } else {
                gamegrid.currentIndex = 0;
            }
        }
    }

    Item {
    id: gridContainer

        anchors {
            top: header.bottom; topMargin: 0
            left: parent.left; leftMargin: globalMargin
            right: parent.right; rightMargin: globalMargin
            bottom: parent.bottom; bottomMargin: 0
        }
        
        Rectangle {
            width: parent.width
            height: vpx(1)
            z: 100
        }

        GridView {
        id: gamegrid

            // Figuring out the aspect ratio for box art
            property real cellHeightRatio: fakebox.paintedHeight / fakebox.paintedWidth
            property real savedCellHeight: {
                if (settings.GridThumbnail == "Tall") {
                    return cellWidth / settings.TallRatio;
                } else if (settings.GridThumbnail == "Square") {
                    return cellWidth;
                } else {
                    return cellWidth * settings.WideRatio;
                }
            }
            property var sourceThumbnail: showBoxes ? "BoxArtGridItem.qml" : "../Global/DynamicGridItem.qml"

            Component.onCompleted: {
                currentIndex = storedCollectionGameIndex;
                positionViewAtIndex(currentIndex, ListView.Visible);
            }

            populate: Transition {
                NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: 400 }
            }

            anchors {
                top: parent.top; left: parent.left; right: parent.right;
                bottom: parent.bottom; bottomMargin: 0
            }
            cellWidth: width / numColumns
            cellHeight: ((showBoxes) ? cellWidth * cellHeightRatio : savedCellHeight) + titleMargin
            highlightMoveDuration: 200
            keyNavigationWraps: false
            displayMarginBeginning: cellHeight * 2
            displayMarginEnd: cellHeight * 2

            model: list.games
            delegate: (showBoxes) ? boxartdelegate : dynamicDelegate

            Component {
            id: boxartdelegate

                BoxArtGridItem {
                    selected: GridView.isCurrentItem && root.focus
                    gameData: modelData

                    width:      GridView.view.cellWidth
                    height:     GridView.view.cellHeight - titleMargin
                    
                    onActivate: {
                        if (selected)
                            gameActivated();
                        else
                            gamegrid.currentIndex = index;
                    }
                    onHighlighted: {
                        gamegrid.currentIndex = index;
                    }
                    Keys.onPressed: {
                        // Toggle favorite
                        if (api.keys.isDetails(event) && !event.isAutoRepeat) {
                            event.accepted = true;
                            sfxToggle.play();
                            modelData.favorite = !modelData.favorite;
                        }
                    }

                }
            }

            Component {
            id: dynamicDelegate

                DynamicGridItem {
                id: dynamicdelegatecontainer

                    selected: GridView.isCurrentItem && root.focus

                    width:      GridView.view.cellWidth
                    height:     GridView.view.cellHeight - titleMargin
                    
                    onActivated: {
                        if (selected)
                            gameActivated();
                        else
                            gamegrid.currentIndex = index;
                    }
                    onHighlighted: {
                        gamegrid.currentIndex = index;
                    }
                    Keys.onPressed: {
                        // Toggle favorite
                        if (api.keys.isDetails(event) && !event.isAutoRepeat) {
                            event.accepted = true;
                            sfxToggle.play();
                            modelData.favorite = !modelData.favorite;
                        }
                    }
                    
                    Component.onCompleted: {
                        if (reselecting == true) {
                            gamegrid.currentIndex = gamegrid.currentIndex + 1;
                            gamegrid.currentIndex = gamegrid.currentIndex - 1;
                        }
                    }
                }
            }

            Component {
            id: highlightcomponent

                ItemHighlight {
                    width: gamegrid.cellWidth
                    height: gamegrid.cellHeight
                    game: list.currentGame(gamegrid.currentIndex)
                    selected: gamegrid.focus
                    boxArt: showBoxes
                }
            }

            // Manually set the navigation this way so audio can play without performance hits
            Keys.onUpPressed: {
                sfxNav.play();
                if (currentIndex < numColumns) {
                    headercontainer.focus = true;
                    gamegrid.currentIndex = -1;
                } else {
                    moveCurrentIndexUp();
                }
            }
            
            Rectangle {
                width: parent.width;
                height: parent.height;
                opacity: 0;
                z:-1;
                // Mouse/touch functionality
                MouseArea {
                    anchors.fill: parent
                    onEntered: {reselecting = false; gamegrid.focus = true;}
                    onExited: {reselecting = false; gamegrid.focus = true;}
                    onClicked: {reselecting = false; gamegrid.focus = true;}
                }
            }
            
            Keys.onDownPressed:     { sfxNav.play(); moveCurrentIndexDown() }
            Keys.onLeftPressed:     { sfxNav.play(); moveCurrentIndexLeft() }
            Keys.onRightPressed:    { sfxNav.play(); moveCurrentIndexRight() }
        }

    }

    Keys.onReleased: {
        // Scroll Down
        if (api.keys.isPageDown(event) && !event.isAutoRepeat) {
            event.accepted = true;
            isRightTriggerPressed = false;
            return;
        }

        // Scroll Up
        if (api.keys.isPageUp(event) && !event.isAutoRepeat) {
            event.accepted = true;
            isLeftTriggerPressed = false;
            return;
        }
    }

    Keys.onPressed: {
        // Accept
        if (api.keys.isAccept(event) && !event.isAutoRepeat) {
            event.accepted = true;
            if (gamegrid.focus) {
                gameActivated();
            } else {
                gamegrid.currentIndex = 0;
                gamegrid.focus = true;
            }
            return;
        }

        // Back
        if (api.keys.isCancel(event) && !event.isAutoRepeat) {
            event.accepted = true;
            if (gamegrid.focus) {
                previousScreen();
                gamegrid.currentIndex = 0;
                sortedGames = null;
                currentGame = null;
            } else {
                gamegrid.focus = true;
            }
            return;
        }

        // Details
        if (api.keys.isFilters(event) && !event.isAutoRepeat) {
            event.accepted = true;
            sfxToggle.play();
            cycleSort();
            return;
        }

        // Scroll Down
        if (api.keys.isPageDown(event) && !event.isAutoRepeat) {
            event.accepted = true;
            isRightTriggerPressed = navigateToNextLetter(+1) ? true : isRightTriggerPressed;
            return;
        }

        // Scroll Up
        if (api.keys.isPageUp(event) && !event.isAutoRepeat) {
            event.accepted = true;
            isLeftTriggerPressed = navigateToNextLetter(-1) ? true : isLeftTriggerPressed;
            return;
        }

        // Next collection
        if (api.keys.isNextPage(event) && !event.isAutoRepeat) {
            event.accepted = true;
            if (currentCollectionIndex < api.collections.count-1)
                currentCollectionIndex++;
            else
                currentCollectionIndex = 0;

            gamegrid.currentIndex = 0;
            sfxToggle.play();

            // Reset our cached sorted games
            sortedGames = null;
            return;
        }

        // Previous collection
        if (api.keys.isPrevPage(event) && !event.isAutoRepeat) {
            event.accepted = true;
            if (currentCollectionIndex > 0)
                currentCollectionIndex--;
            else
                currentCollectionIndex = api.collections.count-1;

            gamegrid.currentIndex = 0;
            sfxToggle.play();

            // Reset our cached sorted games
            sortedGames = null;
            return;
        }
    }

    // Helpbar buttons
    ListModel {
        id: gridviewHelpModel

        ListElement {
            name: "Back"
            button: "cancel"
        }
        ListElement {
            name: "Toggle favorite"
            button: "details"
        }
        ListElement {
            name: "Filters"
            button: "filters"
        }
        ListElement {
            name: "View details"
            button: "accept"
        }
    }

    onFocusChanged: {
        if (focus) {
            currentHelpbarModel = gridviewHelpModel;
            gamegrid.focus = true;
            if (currentGame == null) {
                gamegrid.currentIndex = 0;
                sortedGames = null;
            } else if (orderBy === Qt.AscendingOrder && list.collection.games.toVarArray().findIndex(g => g === currentGame) != gamegrid.currentIndex) {
                reselecting = true;
                sortByIndex = 0;
                showFavs = false;
                if (currentGame.sortBy != undefined) {
                    searchTerm = currentGame.title;
                } else {
                    searchTerm = currentGame.sortBy;
                }
                gamegrid.currentIndex = 0;
                searchTerm = "";
            } else if (orderBy === Qt.DescendingOrder && list.collection.games.toVarArray().reverse().findIndex(g => g === currentGame) != gamegrid.currentIndex) {
                reselecting = true;
                sortByIndex = 0;
                showFavs = false;
                if (currentGame.sortBy != undefined) {
                    searchTerm = currentGame.title;
                } else {
                    searchTerm = currentGame.sortBy;
                }
                gamegrid.currentIndex = 0;
                searchTerm = "";
            }
        }
    }
}
