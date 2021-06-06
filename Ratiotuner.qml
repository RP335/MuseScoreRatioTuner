
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
    width: 500
    height: 200
    property var offsetTextWidth: 40;
    property var offsetLabelAlignment: 0x02 | 0x80;
    property var history: 0;
    property var rationumerator: 0
    property var ratiodenominator: 0
    property var cents: 0
    property var prevcents

    // set true if customisations are made to the tuning
    property var modified: false

    onRun: {
        console.log("hello world")
        if (typeof curScore  === 'undefined')
        {
            Qt.quit()
        }
    }
    function parsenumer()
    {
        rationumerator = parseFloat(rationum.text)

    }
    function applyToNotesInSelection(func1,func2) {
        if (typeof curScore === 'undefined')
            return;

            var cursor     = curScore.newCursor();
            cursor.rewind(1);
            var startStaff  = cursor.staffIdx;
            cursor.rewind(2);
            var endStaff   = cursor.staffIdx;
            var endTick    = cursor.tick // if no selection, end of score
            var fullScore = false;
            if (!cursor.segment) { // no selection
                  fullScore = true;
                  startStaff = 0; // start with 1st staff
                  endStaff = curScore.nstaves; // and end with last
            }
       console.log(startStaff + " - " + endStaff + " - " + endTick)
            for (var staff = startStaff; staff <= endStaff; staff++) {
                  for (var voice = 0; voice < 4; voice++) {
                        cursor.rewind(1); // sets voice to 0
                        cursor.voice = voice; //voice has to be set after goTo
                        cursor.staffIdx = staff;

                        if (!cursor.segment)
                              cursor.rewind(0) // if no selection, beginning of score

                        while (cursor.segment && (fullScore || cursor.tick < endTick)) {
                              if (cursor.element && cursor.element.type == Element.CHORD) {
                                    var notes = cursor.element.notes;
                                    for (var i = 0; i < notes.length; i++) {
                                          var note = notes[i];
                                          if (i=0)
                                            func1(note);
                                        else
                                            func2(note)

                                    }
                              }
                              cursor.next();
                        }
                  }
            }
      }
    function parsedenom()
    {
        ratiodenominator = parseFloat(ratiodenom.text)
    }
    function get_previous_tuning(note)
    {
        prevcents = note.tuning
    }
    function logbase2 (base, number1)
    {
        return Math.log(number1)/Math.log(base)
    }

    function apply_to_nextnote(note)
    {
        var ratio = rationumerator/ratiodenominator
        var inicents = 1200 * logbase2(ratio)
        var abscents = Math.abs (inicents)
        var underhun = abscents%100
        if (inicents>=0)
        {
            if (underhun<=50)
                note.tuning = underhun+prevcents
            else
                note.tuning = 100-underhun +prevcents

        }
        else
        {
            if (underhun<50)
                note.tuning = prevcents - underhun
            else
                note.tuning = prevcents - (100-underhun)
        }

    }
    function ratio_to_cents()
    {
        applyToNotesInSelection(get_previous_tuning,apply_to_nextnote)
        Qt.quit()

    }
    MessageDialog {
    id: errorDialog
    title: "Error"
    text: ""
    onAccepted: {
        errorDialog.close()
    }


    }

    Rectangle
    {
        color: "lightgrey"
        anchors.fill:parent
        GridLayout {
            columns: 4

            anchors.fill: parent
            anchors.margins: 30
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

        }

    }
}