import QtQuick 2.8

Item {
id: root

    property var gameData
    property string playersText: gameData && gameData.players ? String(gameData.players).trim() : ""

    readonly property int playerCount: resolvePlayerCount(playersText)
    readonly property string iconSource: {
        if (playerCount <= 1)
            return "../assets/images/player-sinlge.svg";
        if (playerCount === 2)
            return "../assets/images/player-coop.svg";
        return "../assets/images/player-multi.svg";
    }

    visible: playersText !== ""
    width: visible ? playersRow.implicitWidth : 0
    height: playersRow.implicitHeight

    function resolvePlayerCount(value) {
        if (!value)
            return 0;

        const matches = String(value).match(/\d+/g);
        if (!matches || !matches.length)
            return 0;

        let maxPlayers = 0;
        for (let i = 0; i < matches.length; ++i)
            maxPlayers = Math.max(maxPlayers, parseInt(matches[i], 10) || 0);

        return maxPlayers;
    }

    Row {
    id: playersRow

        anchors.verticalCenter: parent.verticalCenter
        spacing: vpx(6)

    

        Item {
            width: vpx(22)
            height: vpx(22)

            Image {
                anchors.fill: parent
                source: root.iconSource
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
            }
        }

        Text {
            text: root.playersText
            visible: root.playerCount > 3
            width: visible ? implicitWidth : 0
            font.pixelSize: vpx(16)
            font.family: subtitleFont.name
            color: theme.text
            verticalAlignment: Text.AlignVCenter
        }
    }
}
