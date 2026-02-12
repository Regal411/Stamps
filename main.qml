import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs

ApplicationWindow {
    visible: true
    width: 600
    height: 1000
    title: "Коллекция марок"

    property color bgMain: "#1F2326"
    property color bgTop: "#2B2F33"
    property color bgCard: "#2B2F33"
    property color borderCard: "#3A3F44"

    property color textDark: "#1A1A1A"
    property color textSecondary: "#9AA0A6"
    property color textLight: "#E6E6E6"

    property color btnDark: "#3A3F44"
    property color btnHover: "#4A5056"
    property color btnText: "#F5F5F5"

    property color accent: "#4A90E2"
    property color danger: "#D9534F"
    property color dialogBg: "#1F2326"
    property color fieldBg: "#24292D"
    property color fieldBorder: "#3A3F44"
    property color fieldText: "#E6E6E6"
    property color fieldPlaceholder: "#9AA0A6"

    color: bgMain

    property var stampsModel: []
    property var collectionsModel: []
    property var reportData: ({})
    property int selectedCollectionId: -1

    property int collectionToDeleteId: -1
    property int stampsInCollectionToDelete: 0

    property int collectionToRenameId: -1
    property string collectionOldName: ""
    property string searchText: ""

    property int savedContentY: 0
    property int savedCurrentIndex: -1

    // Функция для обновления коллекций
    function updateCollections() {
        collectionsModel = collections.getAllCollections()
    }

    function refreshStamps() {
        var all = stamps.getAllStamps()

        // Фильтр по коллекции
        if (selectedCollectionId !== -1) {
            all = all.filter(s => s.collectionId === selectedCollectionId)
        }

        // Фильтр по поиску
        if (searchText.length > 0) {
            var text = searchText.toLowerCase()
            all = all.filter(s =>
                s.title.toLowerCase().includes(text) ||
                s.country.toLowerCase().includes(text) ||
                s.category.toLowerCase().includes(text)
            )
        }

        stampsModel.length = 0
        Array.prototype.push.apply(stampsModel, all)

        stampsListView.model = stampsModel
    }

    function forceRefreshStamps() {

        savedContentY = stampsListView.contentY
        savedCurrentIndex = stampsListView.currentIndex

        refreshStamps()


        Qt.callLater(function() {
            stampsListView.contentY = savedContentY
            stampsListView.currentIndex = savedCurrentIndex
        })
    }

    Component.onCompleted: {
        updateCollections()
        refreshStamps()
    }
    // асинхронные фото
    Connections {
        target: stamps
        function onStampImageUpdated(stampId) {
            forceRefreshStamps()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // ---------- TOP BAR ----------
        Rectangle {
            Layout.fillWidth: true
            height: 44
            radius: 6
            color: bgTop

            RowLayout {
                anchors.fill: parent
                anchors.margins: 6
                spacing: 6

                ComboBox {
                    id: mainCollectionCombo
                    Layout.fillWidth: true
                    model: [{ id: -1, name: "Все коллекции" }, ...collectionsModel]
                    textRole: "name"
                    valueRole: "id"

                    palette.base: btnDark
                    palette.button: btnDark
                    palette.text: btnText
                    palette.highlight: accent
                    palette.highlightedText: "white"
                    palette.buttonText: btnText
                    palette.window: btnDark
                    palette.windowText: btnText
                    palette.alternateBase: btnHover

                    onActivated: {
                        selectedCollectionId = currentValue
                        forceRefreshStamps()
                    }

                    Component.onCompleted: {

                        selectedCollectionId = -1
                        currentIndex = 0
                    }
                }

                Button {
                    text: "➕ Марка"
                    palette.button: btnDark
                    palette.buttonText: btnText
                    onClicked: {
                        updateCollections()
                        addDialog.open()
                    }
                }

                Button {
                    text: "📚 Коллекции"
                    palette.button: btnDark
                    palette.buttonText: btnText
                    onClicked: {
                        updateCollections()
                        collectionsDialog.open()
                    }
                }

                Button {
                    text: "📊 Отчет"
                    palette.button: btnDark
                    palette.buttonText: btnText
                    onClicked: {
                        reportData = reports.getReport(selectedCollectionId)
                        reportDialog.open()
                    }
                }
            }
        }
        // поиск
        Rectangle {
            Layout.fillWidth: true
            height: 40
            radius: 6
            color: bgTop

            TextField {
                anchors.fill: parent
                anchors.margins: 6

                placeholderText: "Поиск..."
                color: fieldText
                background: Rectangle {
                    color: fieldBg
                    border.color: fieldBorder
                    radius: 4
                }

                onTextChanged: {
                    searchText = text
                    forceRefreshStamps()
                }
            }
        }

        // Отобаржение марок
        ListView {
            id: stampsListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8
            model: stampsModel
            clip: true

            delegate: Rectangle {
                width: ListView.view.width
                height: 155
                radius: 6
                color: bgCard
                border.color: borderCard

                RowLayout {
                    anchors.fill: parent
                    spacing: 10

                    Image {
                        id: stampImage
                        width: 155
                        height: 155
                        source: {
                            if (modelData.image && modelData.image !== "") {
                                var path = modelData.image

                                if (path.startsWith("file:///")) {
                                    return path
                                } else if (path.startsWith("/")) {
                                    return "file://" + path
                                } else {
                                    return "file:///" + path
                                }
                            } else {
                                return ""
                            }
                        }
                        fillMode: Image.PreserveAspectFit
                        cache: false
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: modelData.title + " (" + modelData.count + ")"
                            font.bold: true
                            font.pointSize: 14
                            color: textLight
                        }

                        Text { text: modelData.country + ", " + modelData.year; color: textSecondary }
                        Text { text: "Категория: " + modelData.category; color: textSecondary }
                        Text { text: "Коллекция: " + modelData.collection; color: textSecondary }

                        Text {
                            text: modelData.rare === "Yes" ? "Редкая марка" : ""
                            color: danger
                        }
                    }

                    ColumnLayout {
                        spacing: 4

                        Button {
                            text: "✏"
                            palette.button: btnDark
                            palette.buttonText: btnText
                            onClicked: {
                                updateCollections()
                                editDialog.openWithStamp(modelData)
                            }
                        }

                        Button {
                            text: "🗑"
                            palette.button: danger
                            palette.buttonText: "#FFFFFF"
                            onClicked: {
                                stamps.deleteStamp(modelData.stampId)
                                forceRefreshStamps()
                            }
                        }
                    }
                }
            }
        }
    }

    // Новые марки
    Dialog {
        id: addDialog
        title: "Добавить марку"
        modal: true
        width: 360
        standardButtons: Dialog.Ok | Dialog.Cancel

        background: Rectangle {
            color: dialogBg
            border.color: fieldBorder
        }

        palette.base: fieldBg
        palette.text: fieldText
        palette.window: dialogBg
        palette.button: btnDark
        palette.buttonText: btnText
        palette.windowText: fieldText
        palette.highlight: accent
        palette.highlightedText: btnText

        property string imagePath: ""

        ColumnLayout {
            anchors.margins: 10
            spacing: 8

            TextField {
                id: addTitle
                placeholderText: "Название"
                Layout.fillWidth: true
                palette.text: fieldText
                palette.placeholderText: fieldPlaceholder
                background: Rectangle {
                    color: fieldBg
                    border.color: fieldBorder
                    radius: 3
                }
            }
            TextField {
                id: addCountry
                placeholderText: "Страна"
                Layout.fillWidth: true
                palette.text: fieldText
                palette.placeholderText: fieldPlaceholder
                background: Rectangle {
                    color: fieldBg
                    border.color: fieldBorder
                    radius: 3
                }
            }
            TextField {
                id: addYear
                placeholderText: "Год"
                Layout.fillWidth: true
                validator: IntValidator { bottom: 1000; top: 9999 }
                palette.text: fieldText
                palette.placeholderText: fieldPlaceholder
                background: Rectangle {
                    color: fieldBg
                    border.color: fieldBorder
                    radius: 3
                }
            }
            TextField {
                id: addCategory
                placeholderText: "Категория"
                Layout.fillWidth: true
                palette.text: fieldText
                palette.placeholderText: fieldPlaceholder
                background: Rectangle {
                    color: fieldBg
                    border.color: fieldBorder
                    radius: 3
                }
            }
            TextField {
                id: addCount
                placeholderText: "Количество"
                Layout.fillWidth: true
                validator: IntValidator { bottom: 1; top: 9999 }
                palette.text: fieldText
                palette.placeholderText: fieldPlaceholder
                background: Rectangle {
                    color: fieldBg
                    border.color: fieldBorder
                    radius: 3
                }
            }

            ComboBox {
                id: addCollection
                model: collectionsModel
                Layout.fillWidth: true
                textRole: "name"
                valueRole: "id"

                palette.base: fieldBg
                palette.button: btnDark
                palette.text: btnText
                palette.buttonText: btnText
                palette.highlight: accent

                delegate: ItemDelegate {
                    width: parent.width
                    height: 40
                    contentItem: Text {
                        text: modelData.name
                        color: btnText
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 8
                    }
                    background: Rectangle {
                        color: btnDark
                    }
                }

                popup: Popup {
                    width: parent.width
                    implicitHeight: contentItem.implicitHeight
                    padding: 0

                    contentItem: ListView {
                        clip: true
                        implicitHeight: contentHeight
                        model: addCollection.popup.visible ? addCollection.delegateModel : null
                        currentIndex: addCollection.highlightedIndex

                        ScrollIndicator.vertical: ScrollIndicator { }
                    }

                    background: Rectangle {
                        color: btnDark
                        border.color: fieldBorder
                    }
                }
            }

            Button {
                text: "Выбрать изображение"
                Layout.fillWidth: true
                palette.button: btnDark
                palette.buttonText: btnText
                onClicked: addImageDialog.open()
            }

            Text {
                text: addDialog.imagePath ? "Изображение: " + addDialog.imagePath.split('/').pop() : "Изображение не выбрано"
                color: fieldText
                elide: Text.ElideLeft
                Layout.fillWidth: true
            }

            CheckBox {
                id: addRare
                text: "Редкая марка"
                palette.text: fieldText
                palette.base: fieldBg
                palette.button: fieldBorder
            }
        }

        onAccepted: {
            if (addTitle.text === "" || addCountry.text === "" ||
                addYear.text === "" || addCategory.text === "" ||
                addCount.text === "" || addCollection.currentIndex < 0) {
                errorDialog.text = "Заполните все обязательные поля!"
                errorDialog.open()
                return
            }

            var collectionId = addCollection.currentValue

            stamps.addStamp(
                addTitle.text,
                addCountry.text,
                parseInt(addYear.text),
                addCategory.text,
                parseInt(addCount.text),
                collectionId,
                addDialog.imagePath,
                addRare.checked ? "Yes" : "No"
            )

            forceRefreshStamps()

            // Сброс полей
            addTitle.text = ""
            addCountry.text = ""
            addYear.text = ""
            addCategory.text = ""
            addCount.text = ""
            addCollection.currentIndex = 0
            addRare.checked = false
            addDialog.imagePath = ""
        }

        onOpened: {
            if (collectionsModel.length === 0) {
                errorDialog.text = "Сначала создайте коллекцию!"
                errorDialog.open()
                close()
                return
            }

            // Сброс полей
            addTitle.text = ""
            addCountry.text = ""
            addYear.text = ""
            addCategory.text = ""
            addCount.text = ""
            addCollection.currentIndex = 0
            addRare.checked = false
            addDialog.imagePath = ""
        }
    }

    FileDialog {
        id: addImageDialog
        nameFilters: ["Изображения (*.png *.jpg *.jpeg)"]
        onAccepted: {
            var filePath = selectedFile.toString()

            addDialog.imagePath = filePath.replace(/^file:\/\//, "")
        }
    }

    // Ред. марки
    Dialog {
        id: editDialog
        title: "Редактировать марку"
        modal: true
        width: 360
        standardButtons: Dialog.Ok | Dialog.Cancel

        background: Rectangle {
            color: dialogBg
            border.color: fieldBorder
        }

        palette.base: fieldBg
        palette.text: fieldText
        palette.window: dialogBg
        palette.button: btnDark
        palette.buttonText: btnText
        palette.windowText: fieldText
        palette.highlight: accent
        palette.highlightedText: btnText

        property int stampId: -1
        property string imagePath: ""

        function openWithStamp(s) {
            stampId = s.stampId
            editTitle.text = s.title
            editCountry.text = s.country
            editYear.text = s.year
            editCategory.text = s.category
            editCount.text = s.count

            // Индекс
            var index = 0
            for (var i = 0; i < collectionsModel.length; i++) {
                if (collectionsModel[i].id === s.collectionId) {
                    index = i
                    break
                }
            }
            editCollection.currentIndex = index

            editRare.checked = s.rare === "Yes"

            // Если есть изображение, сохраняем его путь
            if (s.image && s.image !== "") {

                if (s.image.startsWith("file:///")) {
                    editDialog.imagePath = s.image.replace("file:///", "")
                } else if (s.image.startsWith("/")) {
                    editDialog.imagePath = s.image
                } else {
                    editDialog.imagePath = s.image
                }
            } else {
                editDialog.imagePath = ""
            }

            open()
        }

        ColumnLayout {
            anchors.margins: 10
            spacing: 8

            TextField {
                id: editTitle
                Layout.fillWidth: true
                palette.text: fieldText
                placeholderText: "Название"
                palette.placeholderText: fieldPlaceholder
                background: Rectangle {
                    color: fieldBg
                    border.color: fieldBorder
                    radius: 3
                }
            }
            TextField {
                id: editCountry
                Layout.fillWidth: true
                palette.text: fieldText
                placeholderText: "Страна"
                palette.placeholderText: fieldPlaceholder
                background: Rectangle {
                    color: fieldBg
                    border.color: fieldBorder
                    radius: 3
                }
            }
            TextField {
                id: editYear
                Layout.fillWidth: true
                palette.text: fieldText
                placeholderText: "Год"
                palette.placeholderText: fieldPlaceholder
                background: Rectangle {
                    color: fieldBg
                    border.color: fieldBorder
                    radius: 3
                }
            }
            TextField {
                id: editCategory
                Layout.fillWidth: true
                palette.text: fieldText
                placeholderText: "Категория"
                palette.placeholderText: fieldPlaceholder
                background: Rectangle {
                    color: fieldBg
                    border.color: fieldBorder
                    radius: 3
                }
            }
            TextField {
                id: editCount
                Layout.fillWidth: true
                palette.text: fieldText
                placeholderText: "Количество"
                palette.placeholderText: fieldPlaceholder
                background: Rectangle {
                    color: fieldBg
                    border.color: fieldBorder
                    radius: 3
                }
            }

            ComboBox {
                id: editCollection
                model: collectionsModel
                Layout.fillWidth: true
                textRole: "name"
                valueRole: "id"

                palette.base: fieldBg
                palette.button: btnDark
                palette.text: btnText
                palette.buttonText: btnText
                palette.highlight: accent

                delegate: ItemDelegate {
                    width: parent.width
                    height: 40
                    contentItem: Text {
                        text: modelData.name
                        color: btnText
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 8
                    }
                    background: Rectangle {
                        color: btnDark
                    }
                }

                popup: Popup {
                    width: parent.width
                    implicitHeight: contentItem.implicitHeight
                    padding: 0

                    contentItem: ListView {
                        clip: true
                        implicitHeight: contentHeight
                        model: editCollection.popup.visible ? editCollection.delegateModel : null
                        currentIndex: editCollection.highlightedIndex

                        ScrollIndicator.vertical: ScrollIndicator { }
                    }

                    background: Rectangle {
                        color: btnDark
                        border.color: fieldBorder
                    }
                }
            }

            Button {
                text: "Изменить изображение"
                Layout.fillWidth: true
                palette.button: btnDark
                palette.buttonText: btnText
                onClicked: editImageDialog.open()
            }

            Text {
                text: editDialog.imagePath ? "Изображение: " + editDialog.imagePath.split('/').pop() : "Изображение не выбрано"
                color: fieldText
                elide: Text.ElideLeft
                Layout.fillWidth: true
            }

            CheckBox {
                id: editRare
                text: "Редкая марка"
                palette.text: fieldText
                palette.base: fieldBg
                palette.button: fieldBorder
            }
        }

        onAccepted: {
            if (editTitle.text === "" || editCountry.text === "" ||
                editYear.text === "" || editCategory.text === "" ||
                editCount.text === "" || editCollection.currentIndex < 0) {
                errorDialog.text = "Заполните все обязательные поля!"
                errorDialog.open()
                return
            }

            var collectionId = editCollection.currentValue
            var finalImagePath = editDialog.imagePath

            stamps.updateStamp(
                stampId,
                editTitle.text,
                editCountry.text,
                parseInt(editYear.text),
                editCategory.text,
                parseInt(editCount.text),
                collectionId,
                finalImagePath,
                editRare.checked ? "Yes" : "No"
            )

            forceRefreshStamps()

            // Сброс свойств
            editDialog.stampId = -1
            editDialog.imagePath = ""
        }
    }

    FileDialog {
        id: editImageDialog
        nameFilters: ["Изображения (*.png *.jpg *.jpeg)"]
        onAccepted: {
            var filePath = selectedFile.toString()

            editDialog.imagePath = filePath.replace(/^file:\/\//, "")
        }
    }

    // Ошибка
    Dialog {
        id: errorDialog
        title: "Ошибка"
        modal: true
        standardButtons: Dialog.Ok

        property alias text: errorText.text

        width: 300
        height: 200

        background: Rectangle {
            color: dialogBg
            border.color: danger
        }

        palette.window: dialogBg
        palette.text: fieldText

        Text {
            id: errorText
            anchors.fill: parent
            anchors.margins: 20
            wrapMode: Text.WordWrap
            color: fieldText
        }
    }

    // Коллекциии
    Dialog {
        id: collectionsDialog
        title: "Коллекции"
        modal: true
        width: 400
        height: 450

        background: Rectangle {
            color: dialogBg
            border.color: fieldBorder
        }

        palette.base: fieldBg
        palette.text: fieldText
        palette.window: dialogBg
        palette.button: btnDark
        palette.buttonText: btnText
        palette.windowText: fieldText
        palette.highlight: accent
        palette.highlightedText: btnText

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8

            RowLayout {
                TextField {
                    id: newCollection
                    Layout.fillWidth: true
                    placeholderText: "Новая коллекция"
                    palette.text: fieldText
                    palette.placeholderText: fieldPlaceholder
                    background: Rectangle {
                        color: fieldBg
                        border.color: fieldBorder
                        radius: 3
                    }
                }
                Button {
                    text: "➕"
                    palette.button: btnDark
                    palette.buttonText: btnText
                    onClicked: {
                        if (newCollection.text.trim() === "") {
                            errorDialog.text = "Введите название коллекции!"
                            errorDialog.open()
                            return
                        }

                        collections.addCollection(newCollection.text)
                        newCollection.text = ""
                        updateCollections()
                        forceRefreshStamps()
                        mainCollectionCombo.model = [{ id: -1, name: "Все коллекции" }, ...collectionsModel]
                    }
                }
            }

            ListView {
                id: collectionsListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: collectionsModel

                delegate: Item {
                    width: ListView.view.width
                    height: 40

                    Row {
                        anchors.fill: parent
                        spacing: 6

                        Text {
                            text: modelData.name
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                            width: parent.width - 90
                            color: fieldText
                        }

                        Button {
                            text: "✏"
                            width: 36
                            height: 30
                            palette.button: btnDark
                            palette.buttonText: btnText
                            anchors.verticalCenter: parent.verticalCenter
                            onClicked: {
                                collectionToRenameId = modelData.id
                                collectionOldName = modelData.name
                                renameCollectionDialog.open()
                            }
                        }

                        Button {
                            text: "❌"
                            width: 36
                            height: 30
                            palette.button: danger
                            palette.buttonText: "#FFFFFF"
                            anchors.verticalCenter: parent.verticalCenter
                            onClicked: {
                                collectionToDeleteId = modelData.id
                                stampsInCollectionToDelete =
                                    collections.getStampsCountInCollection(modelData.id)

                                if (stampsInCollectionToDelete > 0)
                                    deleteCollectionWithStampsDialog.open()
                                else
                                    deleteCollectionDialog.open()
                            }
                        }
                    }
                }
            }
        }
    }

    // Переименоание коллекций
    Dialog {
        id: renameCollectionDialog
        title: "Переименовать коллекцию"
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel

        background: Rectangle {
            color: dialogBg
            border.color: fieldBorder
        }

        palette.base: fieldBg
        palette.text: fieldText
        palette.window: dialogBg
        palette.button: btnDark
        palette.buttonText: btnText
        palette.windowText: fieldText
        palette.highlight: accent
        palette.highlightedText: btnText

        ColumnLayout {
            anchors.margins: 10
            spacing: 8

            TextField {
                id: renameField
                text: collectionOldName
                Layout.fillWidth: true
                palette.text: fieldText
                palette.placeholderText: fieldPlaceholder
                background: Rectangle {
                    color: fieldBg
                    border.color: fieldBorder
                    radius: 3
                }
            }
        }

        onAccepted: {
            collections.renameCollection(collectionToRenameId, renameField.text)
            updateCollections()
            forceRefreshStamps()
            mainCollectionCombo.model = [{ id: -1, name: "Все коллекции" }, ...collectionsModel]
        }
    }

    // Удпление
    Dialog {
        id: deleteCollectionDialog
        title: "Удалить коллекцию?"
        standardButtons: Dialog.Ok | Dialog.Cancel

        background: Rectangle {
            color: dialogBg
            border.color: fieldBorder
        }

        palette.base: fieldBg
        palette.text: fieldText
        palette.window: dialogBg
        palette.button: btnDark
        palette.buttonText: btnText
        palette.windowText: fieldText
        palette.highlight: accent
        palette.highlightedText: btnText

        onAccepted: {
            collections.deleteCollection(collectionToDeleteId)
            updateCollections()
            forceRefreshStamps()
            mainCollectionCombo.model = [{ id: -1, name: "Все коллекции" }, ...collectionsModel]


            if (selectedCollectionId === collectionToDeleteId) {
                selectedCollectionId = -1
                mainCollectionCombo.currentIndex = 0
            }
        }
    }

    Dialog {
        id: deleteCollectionWithStampsDialog
        title: "В коллекции есть марки"
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel

        background: Rectangle {
            color: dialogBg
            border.color: fieldBorder
        }

        palette.base: fieldBg
        palette.text: fieldText
        palette.window: dialogBg
        palette.button: btnDark
        palette.buttonText: btnText
        palette.windowText: fieldText
        palette.highlight: accent
        palette.highlightedText: btnText

        ColumnLayout {
            anchors.margins: 10
            spacing: 10

            Text {
                text: "В коллекции есть марки. Что с ними сделать?"
                wrapMode: Text.WordWrap
                color: fieldText
            }

            RadioButton {
                id: moveStampsOption
                text: "Перенести марки в другую коллекцию"
                checked: true
                palette.text: fieldText
                palette.base: fieldBg
                palette.button: fieldBorder
            }

            ComboBox {
                id: targetCollectionCombo
                enabled: moveStampsOption.checked
                model: collectionsModel.filter(c => c.id !== collectionToDeleteId)
                textRole: "name"
                valueRole: "id"
                Layout.fillWidth: true
                palette.base: fieldBg
                palette.button: btnDark
                palette.text: btnText
                palette.buttonText: btnText
                palette.highlight: accent

                delegate: ItemDelegate {
                    width: parent.width
                    height: 40
                    contentItem: Text {
                        text: modelData.name
                        color: btnText
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 8
                    }
                    background: Rectangle {
                        color: btnDark
                    }
                }
            }

            RadioButton {
                id: deleteStampsOption
                text: "Удалить марки"
                palette.text: fieldText
                palette.base: fieldBg
                palette.button: fieldBorder
            }
        }

        onAccepted: {
            if (moveStampsOption.checked)
                stamps.moveStampsToCollection(
                    collectionToDeleteId,
                    targetCollectionCombo.currentValue
                )
            else
                stamps.deleteStampsByCollection(collectionToDeleteId)

            collections.deleteCollection(collectionToDeleteId)
            updateCollections()
            forceRefreshStamps()
            mainCollectionCombo.model = [{ id: -1, name: "Все коллекции" }, ...collectionsModel]


            if (selectedCollectionId === collectionToDeleteId) {
                selectedCollectionId = -1
                mainCollectionCombo.currentIndex = 0
            }
        }
    }

    // Отчеты
    Dialog {
        id: reportDialog
        width: 600
        height: 1000
        modal: true
        title: "Отчет"
        standardButtons: Dialog.Close

        background: Rectangle {
            color: dialogBg
            border.color: fieldBorder
        }

        palette.base: fieldBg
        palette.text: fieldText
        palette.window: dialogBg
        palette.button: btnDark
        palette.buttonText: btnText
        palette.windowText: fieldText
        palette.highlight: accent
        palette.highlightedText: btnText

        ScrollView {
            anchors.fill: parent

            Column {
                width: parent.width
                spacing: 10
                padding: 10

                Text { text: "Всего марок: " + reportData.total; color: fieldText }
                Text { text: "Уникальных: " + reportData.unique; color: fieldText }
                Text { text: "Редких (%): " + reportData.rarePercent.toFixed(2); color: fieldText }

                Text { text: "По странам"; font.bold: true; color: fieldText }

                Repeater {
                    model: reportData.byCountry
                    delegate: Text {
                        text: modelData.name + " — всего: " +
                              modelData.total + ", уникальных: " +
                              modelData.unique + ", редких: " +
                              modelData.rare
                        color: fieldText
                    }
                }

                Text { text: "По категориям"; font.bold: true; color: fieldText }

                Repeater {
                    model: reportData.byCategory
                    delegate: Text {
                        text: modelData.name + " — всего: " +
                              modelData.total + ", уникальных: " +
                              modelData.unique + ", редких: " +
                              modelData.rare
                        color: fieldText
                    }
                }
            }
        }
    }
}
