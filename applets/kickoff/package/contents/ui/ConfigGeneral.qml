/*
 *  Copyright 2013 David Edmundson <davidedmundson@kde.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.0 as QtControls

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons

Item {

    width: childrenRect.width
    height: childrenRect.height

    property string cfg_icon: plasmoid.configuration.icon
    property alias cfg_switchTabsOnHover: switchTabsOnHoverCheckbox.checked
    property alias cfg_showAppsByName: showApplicationsByNameCheckbox.checked

    KQuickAddons.IconDialog {
        id: iconDialog
        onIconNameChanged: cfg_icon = iconName || "start-here-kde" // TODO use actual default
    }

    Column {
        spacing: units.smallSpacing

        RowLayout {
            spacing: units.smallSpacing

            QtControls.Label {
                text: i18n("Icon:")
            }

            QtControls.Button {
                id: iconButton
                Layout.minimumWidth: units.iconSizes.large + units.smallSpacing * 2
                Layout.maximumWidth: Layout.minimumWidth
                Layout.minimumHeight: Layout.minimumWidth
                Layout.maximumHeight: Layout.minimumWidth

                // just to provide some visual feedback, cannot have checked without checkable enabled
                checkable: true
                onClicked: {
                    checked = Qt.binding(function() { // never actually allow it being checked
                        return iconMenu.status === PlasmaComponents.DialogStatus.Open
                    })

                    iconMenu.open(0, height)
                }

                PlasmaCore.IconItem {
                    anchors.centerIn: parent
                    width: units.iconSizes.large
                    height: width
                    source: cfg_icon
                }
            }

            // QQC Menu can only be opened at cursor position, not a random one
            PlasmaComponents.ContextMenu {
                id: iconMenu
                visualParent: iconButton

                PlasmaComponents.MenuItem {
                    text: i18nc("@item:inmenu Open icon chooser dialog", "Choose...")
                    icon: "document-open-folder"
                    onClicked: iconDialog.open()
                }
                PlasmaComponents.MenuItem {
                    text: i18nc("@item:inmenu Reset icon to default", "Clear Icon")
                    icon: "edit-clear"
                    onClicked: cfg_icon = "start-here-kde" // TODO reset to actual default
                }
            }
        }

        QtControls.CheckBox {
            id: switchTabsOnHoverCheckbox
            text: i18n("Switch tabs on hover")
        }

        QtControls.CheckBox {
            id: showApplicationsByNameCheckbox
            text: i18n("Show applications by name")
        }
    }
}
