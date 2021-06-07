
import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.3
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1



import MuseScore 3.0

MuseScore {
    menuPath: "Plugins.Ratiotuner"
    description: "Description goes here"
    version: "1.0"
    pluginType: "dialog"
    width: 700
    height: 400
    property var offsetTextWidth: 40;
    property var offsetLabelAlignment: 0x02 | 0x80;
    property var history: 0;
    property var rationumerator: 0
    property var ratiodenominator: 0
    property var cents: 0
    property var prevcents
    property var dir: 1

    // set true if customisations are made to the tuning
    property var modified: false

    onRun: {
        console.log("hello world")
        if (typeof curScore  === 'undefined')
        {
            Qt.quit()
        }
    }
    function get_previous_tuning()
    {
        prevcents = parseFloat(previouscents.text)
        console.log("pc="+prevcents)
    }
    function parsenumer()
    {
        rationumerator = parseFloat(rationum.text)
        console.log("rn="+rationumerator)


    }
     function applyToNotesInSelection(func) {
            var fullScore = !curScore.selection.elements.length
            if (fullScore) {
                  cmd("select-all")
                  curScore.startCmd()
            }
            for (var i in curScore.selection.elements)
                  if (curScore.selection.elements[i].pitch)
                        func(curScore.selection.elements[i])
            if (fullScore) {
                  curScore.endCmd()
                  cmd("escape")
            }
      }
    function parsedenom()
    {
        ratiodenominator = parseFloat(ratiodenom.text)
        console.log("rd="+ratiodenominator)
    }
    /*function get_previous_tuning(note)
    {
        prevcents = note.tuning
    }*/
    function logbase2 (base, number1)
    {
        return Math.log(number1)/Math.log(base)
    }

    function apply_to_nextnote(note)
    {
        var prvc = prevcents
        var ratio1 = (rationumerator/ratiodenominator)
        console.log("ratio=" +ratio1)

        var inicents = 1200 * logbase2(2,ratio1)
        var abscents = Math.abs (inicents)
        console.log("abscents=" +abscents)
        var underhun = (abscents%100).toFixed(2)
        var fin = 0
        console.log("underhun="+underhun)
        if (dir ===  1)
        {
            if (underhun<=50){
                console.log("underhun="+underhun)
                fin = underhun + prvc

                note.tuning = fin
            }
            else
                note.tuning = -(100-underhun)+ prvc

        }
        else
        {
            if (underhun<=50)
                note.tuning = prvc - underhun
            else
                note.tuning = prvc + (100-underhun)
        }

    }
    function ratio_to_cents()
    {
        console.log("I've reached here")

        prevcents = parseFloat(previouscents.text)

        applyToNotesInSelection(apply_to_nextnote)
        Qt.quit()

    }
    function func_tuneup()
    {
        dir = 1
    }
    function func_tunedown()
    {
        dir = 0
    }
    MessageDialog {
    id: errorDialog
    title: "Error"
    text: "No note Selected"

    onAccepted: {
        errorDialog.close()
    }


    }

    Rectangle
    {
        color: "lightgrey"
        anchors.fill:parent
        GridLayout {
            columns: 2


            anchors.fill: parent
            anchors.margins: 20
            GroupBox{
                title: "Enter Nnumerator"
                RowLayout {
                    TextField
                    {
                        Layout.maximumWidth: offsetTextWidth
                        id: rationum
                        text: "0"
                        readOnly: false
                        validator: DoubleValidator { bottom: 0; decimals: 0; notation: DoubleValidator.StandardNotation; top: 99 }
                        property var previousText: "0"
                        property var name: "numer"
                        onEditingFinished: { parsenumer() }
                    }
                }
            }
            GroupBox{
                title: "Enter Denominator"
                RowLayout {
                    TextField
                    {
                        Layout.maximumWidth: offsetTextWidth
                        id: ratiodenom
                        text: "0"
                        readOnly: false
                        validator: DoubleValidator { bottom: 0; decimals: 0; notation: DoubleValidator.StandardNotation; top:99 }
                        property var previousText: "0"
                        property var name: "denom"
                        onEditingFinished: {
                            parsedenom()

                        }
                    }
                }
            }
            GroupBox{
                title: "Enter Previous Note Tuning(Press enter upon Entering)"
                RowLayout {
                    TextField
                    {
                        Layout.maximumWidth: offsetTextWidth
                        id: previouscents
                        text: "0.00"
                        readOnly: false
                        validator: DoubleValidator { bottom: -99.99; decimals: 2; notation: DoubleValidator.StandardNotation; top:99.99 }
                        property var previousText: "0.00"
                        property var name: "prev"
                        onEditingFinished: {
                            parsedenom()

                        }
                    }
                }
            }
            GroupBox{
                title: "Apply Changes"
                RowLayout
                {
                    Button {
                        id: applyButton
                        text: qsTranslate("PrefsDialogBase", "Apply")
                        onClicked: {
                            ratio_to_cents()
                        }

                    }
                    Button {
                        id: quitbutton
                        text: qsTranslate("PrefsDialogBase", "Quit")
                        onClicked: {
                            Qt.quit()
                        }

                    }
                }

            }
            GroupBox{
                title: "Up/ Down Tuning"

                GridLayout
                {
                    columns: 2
                    anchors.margins: 10
                    ExclusiveGroup { id: updown}
                    RadioButton
                    {
                        text: "Tune up"
                        checked: true
                        id: tuneup
                        exclusiveGroup: updown
                        onClicked: { func_tuneup() }
                    }
                    RadioButton
                    {
                        text: "Tune Down"

                        id: tunedown
                        exclusiveGroup: updown
                        onClicked: { func_tunedown() }
                    }


                }
            }



        }





    }
}