import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

Scope {
    id: root

    property string uptimeStr: "󰔛 UPTIME: ..."
    property bool isReady: false
    property bool isClosing: false

    function formatUptime(raw) {
        if (!raw) return "󰔛 N/A"
        var clean = raw.trim().replace(/^up\s+/i, "")
        var formatted = clean
            .replace(/\s*days?,\s*/gi, "d ")
            .replace(/\s*hours?,\s*/gi, "h ")
            .replace(/\s*minutes?/gi, "m")
            .replace(/\s*seconds?/gi, "s")
        return "󰔛 " + formatted
    }

    // Leitura assíncrona do Uptime
    Process {
        command: ["uptime", "-p"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root.uptimeStr = root.formatUptime(this.text)
            }
        }
    }

    // Executor de Ações do Sistema
    Process {
        id: cmdRunner
        property var pendingCmd: []
        command: pendingCmd
    }

    Timer {
        id: quitTimer
        interval: 220
        repeat: false
        onTriggered: Qt.quit()
    }

    function closePowermenu() {
        if (root.isClosing) return
        root.isClosing = true
        quitTimer.start()
    }

    function runAction(cmdList, targetBtn) {
        if (targetBtn) {
            targetBtn.isTriggered = true
        }
        cmdRunner.pendingCmd = cmdList
        cmdRunner.running = true
        closePowermenu()
    }

    Component.onCompleted: {
        // Dispara animação de entrada no próximo ciclo de eventos
        animStartTimer.start()
    }

    Timer {
        id: animStartTimer
        interval: 16
        repeat: false
        onTriggered: root.isReady = true
    }

    PanelWindow {
        id: powermenuWindow
        visible: true
        focusable: true
        exclusionMode: ExclusionMode.Ignore

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        // Fundo escuro com Fade Suave
        Rectangle {
            id: backdrop
            anchors.fill: parent
            color: "#85000000"
            opacity: (root.isReady && !root.isClosing) ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation { duration: 220; easing.type: Easing.OutQuad }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.closePowermenu()
            }
        }

        // Captura de Teclas (Atalhos 1-5, D/R/S/E/L, ESC)
        Item {
            focus: true
            Keys.onEscapePressed: root.closePowermenu()
            Keys.onPressed: event => {
                if (event.key === Qt.Key_1 || event.key === Qt.Key_D) {
                    root.runAction(["systemctl", "poweroff"], btnShutdown)
                } else if (event.key === Qt.Key_2 || event.key === Qt.Key_R) {
                    root.runAction(["systemctl", "reboot"], btnReboot)
                } else if (event.key === Qt.Key_3 || event.key === Qt.Key_S) {
                    root.runAction(["systemctl", "suspend"], btnSuspend)
                } else if (event.key === Qt.Key_4 || event.key === Qt.Key_E) {
                    root.runAction(["hyprctl", "dispatch", "exit"], btnLogout)
                } else if (event.key === Qt.Key_5 || event.key === Qt.Key_L) {
                    root.runAction(["loginctl", "lock-session"], btnLock)
                }
            }
        }

        // Cápsula Central (Estilo Dynamic Island)
        Rectangle {
            id: dialogCard
            anchors.centerIn: parent
            width: 560
            height: 186
            radius: Theme.radiusLarge
            color: "#f20d0e15"
            border.color: "#3d415d"
            border.width: 1

            // Efeito de Entrada e Saída
            opacity: (root.isReady && !root.isClosing) ? 1.0 : 0.0
            scale: {
                if (root.isClosing) return 0.90
                if (root.isReady) return 1.0
                return 0.86
            }

            Behavior on opacity {
                NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
            }
            Behavior on scale {
                NumberAnimation { duration: 280; easing.type: Easing.OutBack }
            }

            // Impede cliques no card de fecharem a janela
            MouseArea {
                anchors.fill: parent
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 14

                // Topo: Badges em Pílula (Perfil, Uptime, Botão Cancelar)
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    // Identificação / Usuário
                    Rectangle {
                        Layout.preferredHeight: 28
                        Layout.preferredWidth: userRow.implicitWidth + 16
                        radius: height / 2
                        color: Theme.cardBackground
                        border.color: Theme.borderSubtle
                        border.width: 1

                        RowLayout {
                            id: userRow
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                text: ""
                                font.family: Theme.fontFamily
                                font.pixelSize: 13
                                color: Theme.primary
                            }

                            Text {
                                text: "ian"
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                                color: Theme.text
                            }
                        }
                    }

                    // Badge de Uptime
                    Rectangle {
                        Layout.preferredHeight: 28
                        Layout.preferredWidth: upRow.implicitWidth + 16
                        radius: height / 2
                        color: Theme.cardBackground
                        border.color: Theme.borderSubtle
                        border.width: 1

                        RowLayout {
                            id: upRow
                            anchors.centerIn: parent
                            spacing: 5

                            Text {
                                text: root.uptimeStr
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                                color: Theme.textMuted
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // Botão Fechar / Cancelar [ESC]
                    Rectangle {
                        Layout.preferredHeight: 28
                        Layout.preferredWidth: cancelRow.implicitWidth + 16
                        radius: height / 2
                        color: cancelMouse.containsMouse ? Theme.surfaceActive : Theme.cardBackground
                        border.color: cancelMouse.containsMouse ? Theme.primary : Theme.borderSubtle
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: 140 } }

                        RowLayout {
                            id: cancelRow
                            anchors.centerIn: parent
                            spacing: 5

                            Text {
                                text: "󰅖"
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                color: cancelMouse.containsMouse ? Theme.primary : Theme.textSubtle
                            }

                            Text {
                                text: "ESC"
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                                font.bold: true
                                color: cancelMouse.containsMouse ? Theme.text : Theme.textSubtle
                            }
                        }

                        MouseArea {
                            id: cancelMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.closePowermenu()
                        }
                    }
                }

                // Linha de Ações (5 Botões Modernos Arredondados)
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 10

                    PowerButton {
                        id: btnShutdown
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        icon: "⏻"
                        label: "Shutdown"
                        shortcut: "1"
                        accentColor: Theme.red
                        onActivated: root.runAction(["systemctl", "poweroff"], btnShutdown)
                    }

                    PowerButton {
                        id: btnReboot
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        icon: "󰜉"
                        label: "Reboot"
                        shortcut: "2"
                        accentColor: Theme.orange
                        onActivated: root.runAction(["systemctl", "reboot"], btnReboot)
                    }

                    PowerButton {
                        id: btnSuspend
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        icon: "󰒲"
                        label: "Suspend"
                        shortcut: "3"
                        accentColor: Theme.calm
                        onActivated: root.runAction(["systemctl", "suspend"], btnSuspend)
                    }

                    PowerButton {
                        id: btnLogout
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        icon: "󰍃"
                        label: "Log Out"
                        shortcut: "4"
                        accentColor: Theme.pacific
                        onActivated: root.runAction(["hyprctl", "dispatch", "exit"], btnLogout)
                    }

                    PowerButton {
                        id: btnLock
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        icon: "󰌾"
                        label: "Lock"
                        shortcut: "5"
                        accentColor: Theme.ice
                        onActivated: root.runAction(["loginctl", "lock-session"], btnLock)
                    }
                }
            }
        }
    }
}
