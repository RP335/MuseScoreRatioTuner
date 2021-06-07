
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
    width: 400
    height: 400
    property var offsetTextWidth: 40;
    property var offsetLabelAlignment: 0x02 | 0x80;
    property var history: 0;
    property var rationumerator: 1
    property var ratiodenominator: 1
    property var cents: 0
    property var prevcents
    property var dir: 1
    property var givenchoice: 0
    property var prevtuning_entered: 0

    property var unison:
    {
        'num': 1,
        'den': 1,
        'name': "unison"
    }

    property var minorsecond:
    {
        'num': 16,
        'den': 15,
        'name': "minorsecond"
    }
    property var majorsecond:
    {
        'num': 9,
        'den': 8,
        'name': "majrsecond"
    }
    property var minorthird:
    {
        'num': 6,
        'den': 5,
        'name': "minorthird"
    }
    property var majorthird:
    {
        'num': 5,
        'den': 4,
        'name': "majorthird"
    }
    property var perfectfourth:
    {
        'num': 4,
        'den': 3,
        'name': "perfectfourth"
    }
    property var perfectfifth:
    {
        'num': 3,
        'den': 2,
        'name': "perfectfifth"
    }
    property var tritone:
    {
        'num': 45,
        'den': 32,
        'name': "tritone"
    }
    property var minorsixth:
    {
        'num': 8,
        'den': 5,
        'name': "minorsixth"
    }
    property var majorsixth:
    {
        'num': 5,
        'den': 3,
        'name': "majorsixth"
    }
    property var minorseventh:
    {
        'num': 7,
        'den': 4,
        'name': "minorseventh"
    }
    property var majorseventh:
    {
        'num': 15,
        'den': 8,
        'name': "majorseventh"
    }
    property var customratio:
    {
        'num': 1,
        'den': 1,
        'name': "customratio"
    }



    // set true if customisations are made to the tuning
    property var modified: false

    onRun: {
        console.log("hello world")
        if (typeof curScore  === 'undefined')
        {
            Qt.quit()
        }
    }
    function assignratioclick(ratio)
    {
        rationumerator = ratio.num
        console.log("ratnum="+rationumerator)

        ratiodenominator = ratio.den
        console.log("ratdenom="+ratiodenominator)
        if (ratio.name === "customratio")
            givenchoice =0
        else
            givenchoice = 1

    }
    function get_previous_tuning()
    {
        prevcents = parseFloat(previouscentstxt.text)
        console.log("pc="+prevcents)
        prevtuning_entered = 1
    }
    function parsenumer()
    {
        if (givenchoice ===1)
            return;
        rationumerator = parseFloat(rationum.text)
        console.log("rn="+rationumerator)


    }
    function applyToNotesInSelection(func)
    {
        var fullScore = !curScore.selection.elements.length
        if (fullScore)
        {
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
        if (givenchoice ===1)
            return;
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

        var ratio1 = (rationumerator/ratiodenominator)


        console.log("ratio=" +ratio1)
        console.log("prevcents1="+prevcents)

        var inicents = 1200 * logbase2(2,ratio1)
        var abscents = Math.abs (inicents)
        console.log("abscents=" +abscents)
        var underhun = parseFloat((abscents%100).toFixed(2))
        var fin = 0
        console.log("underhun="+underhun)
        if (dir ===  1)
        {
            if (underhun<=50){
                console.log("underhun="+underhun)
                fin = (underhun+prevcents).toFixed(2)
                console.log("fin="+fin)


                note.tuning = fin
            }
            else
                note.tuning = (-(100-underhun)+prevcents).toFixed(2)

        }
        else
        {
            if (underhun<=50)
                note.tuning = prvc-underhun
            else
                note.tuning = prvc+(100-underhun)
        }

    }


    function ratio_to_cents()
    {

        prevcents = parseFloat(previouscentstxt.text)
        if (prevtuning_entered===0 &&prevcents===0)
            prevcents = 0.00
        else
            prevcents = parseFloat(previouscentstxt.text)



        console.log("I've reached here 3")
        console.log("pc="+prevcents)

        if (givenchoice ===1)
        {
            applyToNotesInSelection(apply_to_nextnote)
        }
        else
        {
            rationumerator = parseFloat(rationum.text)
            ratiodenominator = parseFloat(ratiodenom.text)
            applyToNotesInSelection(apply_to_nextnote)
        }





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
    text: ""

    onAccepted: {
        errorDialog.close()
    }
    function error(errorMessage) {
        errorDialog.text = qsTr(errorMessage)
        errorDialog.open()
    }



    }
    Rectangle
    {
        color: "lightgrey"
        anchors.fill: parent
        GridLayout
        {
            columns: 2
            anchors.fill: parent
            anchors.margins: 10
            GroupBox
            {
                title: "Select Ratios"
                ColumnLayout
                {
                    ExclusiveGroup {id: availableratios}
                    RadioButton{
                        id: unsison_button
                        text: "unison (1/1)"
                        checked: true
                        exclusiveGroup: availableratios
                        onClicked: {assignratioclick(unison)}
                    }
                    RadioButton{
                        id: minorsecond_button
                        text: "Minor Second (16/15)"
                        exclusiveGroup: availableratios
                        onClicked: { assignratioclick(minorsecond)}

                    }
                    RadioButton{
                        id: majorsecond_button
                        text: "Major Second (9/8)"
                        exclusiveGroup: availableratios
                        onClicked: { assignratioclick(majorsecond)}

                    }
                    RadioButton{
                        id: minorthird_button
                        text: "Minor Third (6/5)"
                        exclusiveGroup: availableratios
                        onClicked: { assignratioclick(minorthird)}

                    }
                    RadioButton{
                        id: majorthird_button
                        text: "Major Third (5/4)"
                        exclusiveGroup: availableratios
                        onClicked: { assignratioclick(majorthird)}

                    }
                    RadioButton{
                        id: perfectfourth_button
                        text: "Perfect Fourth (4/3)"
                        exclusiveGroup: availableratios
                        onClicked: { assignratioclick(perfectfourth)}

                    }
                    RadioButton{
                        id: tritone_button
                        text: "Tritone (45/32)"
                        exclusiveGroup: availableratios
                        onClicked: { assignratioclick(tritone)}

                    }
                    RadioButton{
                        id: perfectfifth_button
                        text: "Perfect Fifth (3/2)"
                        exclusiveGroup: availableratios
                        onClicked: { assignratioclick(perfectfifth)}

                    }
                    RadioButton{
                        id: minorsixth_button
                        text: "Minor Sixth (8/5)"
                        exclusiveGroup: availableratios
                        onClicked: { assignratioclick(minorsixth)}

                    }
                    RadioButton{
                        id: majorsixth_button
                        text: "Major Sixth (5/3)"
                        exclusiveGroup: availableratios
                        onClicked: { assignratioclick(majorsixth)}

                    }
                    RadioButton{
                        id: minorseventh_button
                        text: "Minor Seventh (7/4)"
                        exclusiveGroup: availableratios
                        onClicked: { assignratioclick(minorseventh)}

                    }
                    RadioButton{
                        id: majorseventh_button
                        text: "Major Seventh (15/8)"
                        exclusiveGroup: availableratios
                        onClicked: { assignratioclick(majorseventh)}

                    }
                    RadioButton{
                        id: customratio_button
                        text: "Custon Ratio (x/y)"
                        exclusiveGroup: availableratios
                        onClicked: { assignratioclick(custonratio)}

                    }


                }
            }
            ColumnLayout
            {
                GroupBox
                {
                    title: "Custom Ratios"
                    ColumnLayout
                    {
                        GroupBox
                        {
                            title: "Enter Numerator"
                            RowLayout
                            {
                                TextField
                                {
                                    Layout.maximumWidth: offsetTextWidth
                                    id: rationum
                                    text: "1"
                                    readOnly: false
                                    validator: DoubleValidator { bottom: 0; decimals: 0; notation: DoubleValidator.StandardNotation; top:99 }
                                    property var previousText: "1"
                                    property var name: "numer"
                                    onEditingFinished:
                                    {
                                        parsenumer()
                                        customratio_button.checked = true
                                    }
                                }
                            }
                        }
                        GroupBox
                        {
                            title: "Enter Denominator"
                            RowLayout
                            {
                                TextField
                                {
                                    Layout.maximumWidth: offsetTextWidth
                                    id: ratiodenom
                                    text: "1"
                                    readOnly: false
                                    validator: DoubleValidator { bottom: 0; decimals: 0; notation: DoubleValidator.StandardNotation; top:99 }
                                    property var previousText: "1"
                                    property var name: "denom"
                                    onEditingFinished:
                                    {
                                        parsedenom()
                                    }
                                }
                            }
                        }
                    }

                }
                GroupBox
                {
                    title: "Enter Previous Note Tuning (in cents)"
                    RowLayout
                    {
                        TextField
                        {
                            Layout.maximumWidth: offsetTextWidth
                            id: previouscentstxt
                            text: "0.00"
                            readOnly: false
                            validator: DoubleValidator { bottom: -99.99; decimals: 2; notation: DoubleValidator.StandardNotation; top:99.99 }
                            property var previousText: "0.00"
                            property var name: "prev"
                            onEditingFinished:
                            {
                                get_previous_tuning()

                            }
                        }
                    }


                }
            GroupBox
            {
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


}