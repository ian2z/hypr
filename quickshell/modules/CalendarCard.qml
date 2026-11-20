import QtQuick
import QtQuick.Layouts
import Quickshell
import "../style"

Rectangle {
    id: root

    property bool expanded: false

    // Estado da data atual real
    property var today: new Date()
    readonly property int todayDay: today.getDate()
    readonly property int todayMonth: today.getMonth()
    readonly property int todayYear: today.getFullYear()
    readonly property int todayWeekDay: today.getDay()

    // Estado de navegação do calendário
    property int viewYear: todayYear
    property int viewMonth: todayMonth

    readonly property var monthNames: [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]

    readonly property var weekDayNames: [
        "Sunday", "Monday", "Tuesday", "Wednesday",
        "Thursday", "Friday", "Saturday"
    ]

    readonly property var weekDayShorts: ["S", "M", "T", "W", "T", "F", "S"]

    readonly property string headerTitle: {
        return weekDayNames[todayWeekDay] || "Today"
    }

    readonly property string headerSubtitle: {
        return monthNames[todayMonth] + " " + todayDay + ", " + todayYear
    }

    Layout.fillWidth: true
    implicitHeight: mainCol.implicitHeight + 24
    radius: Theme.radiusLarge
    color: Theme.cardBackground
    border.color: Theme.borderSubtle
    border.width: 1

    Behavior on implicitHeight {
        NumberAnimation { duration: 180; easing.type: Easing.OutQuad }
    }

    // Timer para manter a data atualizada se virar a meia-noite
    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: {
            root.today = new Date()
        }
    }

    function prevMonth() {
        if (viewMonth === 0) {
            viewMonth = 11
            viewYear--
        } else {
            viewMonth--
        }
    }

    function nextMonth() {
        if (viewMonth === 11) {
            viewMonth = 0
            viewYear++
        } else {
            viewMonth++
        }
    }

    function resetToToday() {
        viewYear = todayYear
        viewMonth = todayMonth
    }

    // Gera a lista de células do mês (dias do mês anterior para preencher, mês atual e próximo)
    readonly property var calendarGrid: {
        var days = []
        var firstDayOfWeek = new Date(viewYear, viewMonth, 1).getDay()
        var daysInCurrentMonth = new Date(viewYear, viewMonth + 1, 0).getDate()
        var daysInPrevMonth = new Date(viewYear, viewMonth, 0).getDate()

        // 1. Dias do mês anterior para completar a primeira semana
        for (var p = firstDayOfWeek - 1; p >= 0; p--) {
            days.push({
                day: daysInPrevMonth - p,
                isCurrentMonth: false,
                isToday: false
            })
        }

        // 2. Dias do mês atual
        for (var c = 1; c <= daysInCurrentMonth; c++) {
            var isCurrentToday = (c === todayDay && viewMonth === todayMonth && viewYear === todayYear)
            days.push({
                day: c,
                isCurrentMonth: true,
                isToday: isCurrentToday
            })
        }

        // 3. Dias do próximo mês para completar a grade em múltiplos de 7 (até 35 ou 42)
        var totalCells = days.length > 35 ? 42 : 35
        var remaining = totalCells - days.length
        for (var n = 1; n <= remaining; n++) {
            days.push({
                day: n,
                isCurrentMonth: false,
                isToday: false
            })
        }

        return days
    }

    ColumnLayout {
        id: mainCol
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 12
        spacing: 12

        // =====================================================================
        // LINHA SUPERIOR: ACESSO RÁPIDO AO DIA ATUAL & TOGGLE DE EXPANSÃO
        // =====================================================================
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            // Botão de Ícone
            Rectangle {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                radius: 12
                color: Theme.surface

                Text {
                    anchors.centerIn: parent
                    text: "󰸗"
                    font.family: Theme.fontFamily
                    font.pixelSize: 18
                    color: Theme.primary
                }
            }

            // Data por extenso
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    text: root.headerTitle
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.bold: true
                    color: Theme.text
                }

                Text {
                    text: root.headerSubtitle
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    color: Theme.primary
                }
            }

            // Indicador / Botão Expandir Calendário
            Rectangle {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                radius: height / 2
                color: expandMouse.containsMouse || root.expanded ? Theme.surface : "transparent"
                border.color: expandMouse.containsMouse ? Theme.borderSubtle : "transparent"
                border.width: 1

                Behavior on color { ColorAnimation { duration: 150 } }

                Text {
                    anchors.centerIn: parent
                    text: root.expanded ? "󰅃" : "󰅀"
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    color: root.expanded ? Theme.primary : Theme.textMuted
                }

                MouseArea {
                    id: expandMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.expanded = !root.expanded
                }
            }
        }

        // =====================================================================
        // CORPO EXPANDIDO: NAVEGAÇÃO E GRADE COMPLETA DO MÊS
        // =====================================================================
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 10
            visible: root.expanded
            opacity: root.expanded ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }

            // Linha divisória sutil
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Theme.borderSubtle
            }

            // Barra de Navegação do Mês (< Novembro 2026 > [Hoje])
            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                // Mês Anterior
                Rectangle {
                    Layout.preferredWidth: 26
                    Layout.preferredHeight: 26
                    radius: 8
                    color: prevMouse.containsMouse ? Theme.surface : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "󰅁"
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                        color: Theme.textMuted
                    }

                    MouseArea {
                        id: prevMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.prevMonth()
                    }
                }

                // Nome do Mês e Ano
                Text {
                    Layout.fillWidth: true
                    text: root.monthNames[root.viewMonth] + " " + root.viewYear
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.bold: true
                    color: Theme.text
                    horizontalAlignment: Text.AlignHCenter
                }

                // Botão Hoje (aparece se navegou para outro mês)
                Rectangle {
                    visible: (root.viewMonth !== root.todayMonth || root.viewYear !== root.todayYear)
                    Layout.preferredHeight: 22
                    Layout.preferredWidth: todayBtnText.implicitWidth + 12
                    radius: 6
                    color: todayBtnMouse.containsMouse ? Theme.primary : Theme.surface

                    Text {
                        id: todayBtnText
                        anchors.centerIn: parent
                        text: "Today"
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        font.bold: true
                        color: todayBtnMouse.containsMouse ? Theme.textOnPrimary : Theme.text
                    }

                    MouseArea {
                        id: todayBtnMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.resetToToday()
                    }
                }

                // Próximo Mês
                Rectangle {
                    Layout.preferredWidth: 26
                    Layout.preferredHeight: 26
                    radius: 8
                    color: nextMouse.containsMouse ? Theme.surface : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "󰅂"
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                        color: Theme.textMuted
                    }

                    MouseArea {
                        id: nextMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.nextMonth()
                    }
                }
            }

            // Cabeçalho dos Dias da Semana (D, S, T, Q, Q, S, S)
            RowLayout {
                Layout.fillWidth: true
                spacing: 0

                Repeater {
                    model: root.weekDayShorts

                    Item {
                        Layout.fillWidth: true
                        height: 20

                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            font.bold: true
                            color: (index === 0 || index === 6) ? Theme.primary : Theme.textSubtle
                        }
                    }
                }
            }

            // Grade de Dias (GridLayout 7 Colunas)
            GridLayout {
                id: daysGrid
                Layout.fillWidth: true
                columns: 7
                rowSpacing: 4
                columnSpacing: 0

                Repeater {
                    model: root.calendarGrid

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 28

                        Rectangle {
                            anchors.centerIn: parent
                            width: 26
                            height: 26
                            radius: 13
                            color: {
                                if (modelData.isToday) return Theme.primary
                                if (dayMouse.containsMouse) return Theme.surface
                                return "transparent"
                            }

                            Text {
                                anchors.centerIn: parent
                                text: String(modelData.day)
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.bold: modelData.isToday
                                color: {
                                    if (modelData.isToday) return Theme.textOnPrimary
                                    if (!modelData.isCurrentMonth) return Theme.textSubtle
                                    return Theme.text
                                }
                            }

                            MouseArea {
                                id: dayMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
                    }
                }
            }
        }
    }
}
