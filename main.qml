import QtQuick 2.5
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0
import QtQuick.Particles 2.0

Window {
    id: windowRoot
    visible: true

    width: 1280
    height: 1024

    property real scaling: Math.min(width, height) / 1000

    ListModel {
        id: leaderboardModel
    }

    ListModel {
        id: matchModel
    }

    function reload() {
        console.log("Reloading")

        var req = new XMLHttpRequest;
        req.open("GET", "http://fysfys.ranked.no/leaderboard.json");
        req.onreadystatechange = function() {
            var status = req.readyState;
            if (status === XMLHttpRequest.DONE) {
                //                var fixedResponse = req.responseText.replace("height=70", "height=240")
                var objectArray = JSON.parse(req.responseText);
                console.log(req.responseText)
                if (objectArray.errors !== undefined)
                    console.log("Error fetching leaderboards: " + objectArray.errors[0].message)
                else {
                    //                    leaderboardModel.clear()
                    for (var key in objectArray) {
                        var jsonObject = objectArray[key];
                        var alreadyInList = false
                        for(var i = 0; i < leaderboardModel.count; i++) {
                            var listObject = leaderboardModel.get(i)
                            if(listObject.user.id == jsonObject.user.id) {
                                listObject = jsonObject
                                alreadyInList = true
                            }
                        }
                        if(!alreadyInList) {
                            leaderboardModel.append(jsonObject);
                        }
                    }

                    for(var i = 0; i < leaderboardModel.count; i++) {
                        var listObject = leaderboardModel.get(i)
                        var existsInList = false
                        for (var key in objectArray) {
                            var jsonObject = objectArray[key];
                            if(listObject.user.id == jsonObject.user.id) {
                                existsInList = true
                            }
                        }
                        if(!existsInList) {
                            leaderboardModel.remove(i)
                            i = 0
                        }
                    }
                }
            }
        }
        req.send();

        var req2 = new XMLHttpRequest;
        req2.open("GET", "http://fysfys.ranked.no/matches.json");
        req2.onreadystatechange = function() {
            var status = req2.readyState;
            if (status === XMLHttpRequest.DONE) {
                var objectArray = JSON.parse(req2.responseText);
                console.log(req2.responseText)
                if (objectArray.errors !== undefined)
                    console.log("Error fetching matches: " + objectArray.errors[0].message)
                else {
                    matchModel.clear()
                    var matchups = objectArray.summary[0].matchups
                    for (var key in matchups) {
                        console.log(key)
                        var jsonObject = matchups[key];
                        console.log(jsonObject.player_a[0].name)
                        matchModel.append({"player_a_name": jsonObject.player_a[0].name,
                                           "player_b_name": jsonObject.player_b[0].name,
                                           "player_a_wins": jsonObject.player_a_wins,
                                           "player_b_wins": jsonObject.player_b_wins})
                    }
                }
            }
        }
        req2.send();
    }

    Component.onCompleted: {
        reload()
    }

    Timer {
        interval: 60 * 1000
        repeat: true
        running: true
        onTriggered: {
            reload()
        }
    }

    Timer {
        interval: 10 * 1000
        repeat: true
        running: true
        onTriggered: {
            if(peopleView.count < 1) {
                return
            }

            for(var i = 0; i < peopleView.count; i++) {
                peopleView.itemAt(i).state = ""
            }

            var i = parseInt(Math.random() * peopleView.count)
            peopleView.itemAt(i).animate()
        }
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: "#282C34"
    }

    Rectangle {
        id: scoreAxis
        color: "white"
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
            margins: 24
        }
        width: 4
    }

    Text {
        anchors {
            left: scoreAxis.right
            top: scoreAxis.top
            margins: 12
        }

        text: "Score"
        color: "white"
    }

    Rectangle {
        id: activityAxis
        color: "white"
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 24
        }
        height: 4
    }


    Text {
        anchors {
            right: activityAxis.right
            bottom: activityAxis.top
            margins: 12
        }

        text: "Activity"
        color: "white"
    }

    ParticleSystem {
        id: particleSystem
    }
    ItemParticle {
        system: particleSystem
        delegate: Rectangle {
            width: 5 * scaling
            height: 5 * scaling
            radius: width / 2
            color: Qt.rgba(0.9, 0.9, 0.92, 0.8)
        }
    }

    Repeater {
        id: peopleView
        anchors.fill: parent
        model: leaderboardModel
        smooth: true
        antialiasing: true
        delegate: Item {
            id: player
            function animate() {
                state = "triggered"
            }

            property real animatedScoreDeviation: 0.0
            property real animatedActivityDeviation: 0.0
            property real approximateScore: rating.score + animatedScoreDeviation
            property real approximateActivity: rating.activity + animatedActivityDeviation + 1.5

            x: approximateActivity / 25.0 * peopleView.width
            y: peopleView.height - (approximateScore) / 2200 * peopleView.height
            smooth: true
            antialiasing: true
            width: 100 * scaling
            height: 100 * scaling

            SequentialAnimation {
                running: true
                loops: Animation.Infinite
                NumberAnimation {
                    target: player
                    property: "animatedScoreDeviation"
                    duration: Math.max(500, 30*1000 + Math.random() * 10*1000)
                    easing.type: Easing.InOutQuad
                    from: -rating.rd
                    to: +rating.rd
                }
                NumberAnimation {
                    target: player
                    property: "animatedScoreDeviation"
                    duration: Math.max(500, 30*1000 + Math.random() * 10*1000)
                    easing.type: Easing.InOutQuad
                    from: +rating.rd
                    to: -rating.rd
                }
            }
            SequentialAnimation {
                running: true
                loops: Animation.Infinite
                NumberAnimation {
                    target: player
                    property: "animatedActivityDeviation"
                    duration: 20000 + Math.random() * 30*1000
                    easing.type: Easing.InOutQuad
                    from: -1.5
                    to: +1.5
                }
                NumberAnimation {
                    target: player
                    property: "animatedActivityDeviation"
                    duration: 20000 + Math.random() * 30*1000
                    easing.type: Easing.InOutQuad
                    from: +1.5
                    to: -1.5
                }
            }

            states: [
                State {
                    name: "triggered"
                    PropertyChanges {
                        target: playerImage
                        width: 100 * scaling
                        height: 100 * scaling
                    }
                    PropertyChanges {
                        target: playerName
                        opacity: 1.0
                    }
                    PropertyChanges {
                        target: player
                        z: 1000
                    }
                }
            ]

            transitions: [
                Transition {
                    NumberAnimation {
                        duration: 1000
                        easing.type: Easing.InOutQuad
                        properties: "width,height,opacity"
                    }
                }
            ]

            Emitter {
                system: particleSystem
//                emitRate: 0.0000001 * rating.activity * rating.activity * (rating.score - 1000)*(rating.score - 1000)
                emitRate: Math.abs(rating.delta_today) * 0.15
                lifeSpan:  4000
                size: 24 * scaling
                endSize: 8 * scaling
                velocity: AngleDirection {
                    angle: 90
                    angleVariation: 5
                    magnitude: rating.delta_today * 0.2
                    magnitudeVariation: scaling
                }
                x: parent.width / 2
                y: rating.delta_today > 0 ? parent.height * 3. / 4. : parent.height / 4
            }

            Text {
                id: playerName
                anchors.left: parent.right
                anchors.margins: 10
                text: user.name + "\n" + Math.round(rating.score) + " ± " + Math.round(rating.rd)
                opacity: 0.0
                smooth: true
                color: "white"
                font.family: "Ubuntu"
                font.pixelSize: 24 *  scaling
                Rectangle {
                    z: -1
                    color: background.color
                    anchors.fill: parent
                    smooth: true
                    antialiasing: true
                }
            }

            Image {
                id: playerImage
                //                anchors.centerIn: parent
                x: parent.width / 2 - width / 2
                y: parent.height / 2 - height / 2
                width: 50 * scaling
                height: 50 * scaling
                source: user.square_avatar
                smooth: true
                antialiasing: true

                fillMode: Image.PreserveAspectCrop

                layer.enabled: true
                layer.effect: OpacityMask {
                    smooth: true
                    antialiasing: true
                    cached: true
                    maskSource: Item {
                        width: playerImage.width
                        height: playerImage.height
                        smooth: true
                        antialiasing: true
                        Rectangle {
                            anchors.centerIn: parent
                            width: playerImage.width
                            height: playerImage.height
                            radius: Math.min(width, height)
                            smooth: true
                            antialiasing: true
                        }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    player.animate()
                }
            }
        }
    }

    ParticleSystem {
        id: particles
    }

    ImageParticle {
        anchors.fill: parent
        system: particles
        source: "qrc:///images/faceless.png"
        alpha: 0
        colorVariation: 0.6
    }

    Shortcut {
        sequence: StandardKey.FullScreen
        onActivated: {
            if(windowRoot.visibility == Window.FullScreen) {
                windowRoot.visibility = Window.AutomaticVisibility
            } else {
                windowRoot.visibility = Window.FullScreen
            }
        }
    }
}

