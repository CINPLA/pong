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

    function reload() {
        console.log("Reloading")

        var req = new XMLHttpRequest;
        req.open("GET", "http://fysfys.ranked.no/leaderboard.json");
        req.onreadystatechange = function() {
            var status = req.readyState;
            if (status === XMLHttpRequest.DONE) {
                var fixedResponse = req.responseText.replace("height=70", "height=240")
                var objectArray = JSON.parse(fixedResponse);
                console.log(req.responseText)
                if (objectArray.errors !== undefined)
                    console.log("Error fetching leaderboards: " + objectArray.errors[0].message)
                else {
                    leaderboardModel.clear()
                    for (var key in objectArray) {
                        var jsonObject = objectArray[key];
                        leaderboardModel.append(jsonObject);
                    }
                }
            }
        }
        req.send();
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
            width: 10 * scaling
            height: 10 * scaling
            radius: width / 2
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

            property real approximateScore: 0.0

            x: rating.activity * 50 * scaling + Math.random() * 50 * scaling
            y: peopleView.height - approximateScore / 2500 * peopleView.height
            smooth: true
            antialiasing: true
            width: 100 * scaling
            height: 100 * scaling

            SequentialAnimation {
                running: true
                loops: Animation.Infinite
                NumberAnimation {
                    target: player
                    property: "approximateScore"
                    duration: 5000 + Math.random() * 5000
                    easing.type: Easing.InOutQuad
                    from: (rating.score - rating.rd)
                    to: (rating.score + rating.rd)
                }
                NumberAnimation {
                    target: player
                    property: "approximateScore"
                    duration: 5000 + Math.random() * 5000
                    easing.type: Easing.InOutQuad
                    from: (rating.score + rating.rd)
                    to: (rating.score - rating.rd)
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
                emitRate: 0.0000001 * rating.activity * rating.activity * (rating.score - 1000)*(rating.score - 1000)
                lifeSpan: 2400
                size: 24 * scaling
                endSize: 8 * scaling
                velocity: AngleDirection {
                    angleVariation: 360
                    magnitude: 18 * scaling
                    magnitudeVariation: 6 * scaling
                }
                anchors.centerIn: parent
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
                anchors.centerIn: parent
                width: 50 * scaling
                height: 50 * scaling
                source: user.square_avatar
                smooth: true
                antialiasing: true

                fillMode: Image.PreserveAspectCrop

                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Item {
                        width: playerImage.width
                        height: playerImage.height
                        Rectangle {
                            anchors.centerIn: parent
                            width: playerImage.width
                            height: playerImage.height
                            radius: Math.min(width, height)
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
}

