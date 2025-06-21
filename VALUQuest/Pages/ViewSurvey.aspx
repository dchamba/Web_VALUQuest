<%@ Page Title="" Language="C#" MasterPageFile="~/Template/ValuMaster.Master" AutoEventWireup="true" CodeBehind="ViewSurvey.aspx.cs" Inherits="VALUQuest.Pages.ViewSurvey" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">


    <style>
        .highlight-last-row {
            font-weight: bold;
            background-color: #b6ffb6; /* or any other highlight color */
            color: red; /* or any other text color */
            font-size: 1.5em; /* adjust the size as needed */
        }

        .highlight-second-last-row {
            font-weight: bold;
            background-color: yellow; /* Highlight color for the second last row */
            color: white; /* or any other text color */
            font-size: 1em; /* adjust the size as needed */
        }

        .chartRadar {
            margin-left: 10px; /* Adjust the left margin */
            margin-right: 10px; /* Adjust the right margin */
        }

        .chartLine {
        }

        /* Indentation for category rows */
        .inner-category-row td {
            padding-left: 20px;
            background-color: #fefaee !important; /* Light yellow background for category rows */
            font-weight: 600 !important; /* Light bold for category rows */
        }

        /* Further indentation for question rows */
        .inner-table-row td {
            padding-left: 10px !important;
        }

        .text-ellipsis {
            max-width: 150px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .textQuestionName {
            max-width: 400px;
            overflow: hidden;
        }

        .block-row td {
            background-color: #ebf8fc !important; /* Light green background for block rows */
            font-weight: bold !important; /* Bold text for block rows */
        }

        /* Style for the inner tables */
        .inner-table {
            border: 1px solid #ccc; /* Border around the entire inner table */
            width: 100%;
        }

            .inner-table th,
            .inner-table td {
                border: 1px solid #ccc; /* Borders for the table cells */
                padding: 8px; /* Padding inside cells */
                text-align: left; /* Align text to the left */
            }

        .mdi.mdi-plus-circle {
            font-size: 24px; /* Increase icon size */
        }

        .mdi.mdi-minus-circle {
            font-size: 24px; /* Increase icon size */
        }

        th.sortable:hover {
            cursor: pointer;
            text-decoration: underline;
        }
    </style>

    <div class="row">
        <div class="col-12">
            <div class="page-title-box">
                <h4 class="page-title">Visualizza il sondaggio</h4>
            </div>
        </div>
    </div>

    <div id="msgAlert"></div>

    <div class="row">
        <div class="col-12">
            <div class="card">
                <div class="card-body">
                    <div class="row mb-3">
                        <div class="col-md-2">
                            <label class="form-label">Da età</label>
                            <input type="number" id="txtFromAge" class="form-control form-control-sm" min="1">
                        </div>
                        <div class="col-md-2">
                            <label class="form-label">A età</label>
                            <input type="number" id="txtToAge" class="form-control form-control-sm" min="1">
                        </div>
                        <div class="col-md-8">
                            <div class="float-end">
                                <h6 class="text-uppercase mt-0">Tot. questionari nel menu tendina:</h6>
                                <h2 class="my-2" id="totalSurvey"></h2>
                            </div>
                        </div>

                    </div>
                    <div class="row mb-3">
                        <div class="col-md-8">
                            <label class="form-label">Utente</label>
                            <!-- Label for Sub Category dropdown -->
                            <select id="ddlSurveyor" class="form-control select2" data-toggle="select2">
                            </select>
                        </div>
                        <div class="col-md-4">
                            <button type="button" class="btn btn-danger btn-sm" style="margin-top: 28px;" onclick="deleteSurvey()" id="btnDelete">Elimina sondaggio</button>
                        </div>
                    </div>



                    <div class="row mb-3">
                        <div class="col-xl-12">
                            <div class="card">
                                <div class="card-body">
                                    <h4 class="header-title">Correzioni applicate</h4>

                                    <table id="tblCorrectionApplied" class="table table-sm table-centered mb-0">
                                        <thead>
                                            <tr>
                                                <th style="display:none">Id Correzione Applicata</th>
                                                <th>Id Correzione</th>
                                                <th>Nome</th>
                                                <th>Media G. prima</th>
                                                <th>Fattore Correzione applicato</th>
                                                <th>Media G. dopo</th>
                                                <th>Messagio</th>
                                                <th>Note</th>
                                                <th>Tipo condizione</th>
                                                <th>Blocco</th>
                                                <th>Operatore</th>
                                                <th>Parametro 1</th>
                                                <th>Parametro 2</th>
                                                <th>And/Or/None</th>
                                                <th>Applied</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        </tbody>
                                    </table>

                                </div>
                            </div>
                        </div>


                    </div>

                    <div class="row mb-3">
                        <div class="col-xl-6">


                            <div class="card">
                                <div class="card-body">

                                    <h4 class="header-title">Dettagli utente</h4>
                                    <div class="text-start">
                                        <p class="text-muted">
                                            <strong>Nome:</strong> <span class="ms-2">
                                                <label id="lblName"></label>
                                            </span>
                                        </p>
                                        <p class="text-muted"><strong>Cognome :</strong><span class="ms-2"><label id="lblSurname"></label></span></p>
                                        <p class="text-muted">
                                            <strong>Sesso :</strong> <span class="ms-2">
                                                <label id="lblGender"></label>
                                            </span>
                                        </p>
                                        <p class="text-muted">
                                            <strong>Data di Nascita :</strong> <span class="ms-2">
                                                <label id="lblDOB"></label>
                                            </span>
                                        </p>
                                        <p class="text-muted"><strong>Email :</strong><span class="ms-2"><label id="lblEmail"></label></span></p>
                                        <p class="text-muted"><strong>BMI :</strong><span class="ms-2"><label id="lblbmiValue"></label></span></p>
                                        <p class="text-muted"><strong>Altezza (in cm)</strong><span class="ms-2"><label id="lblHeight"></label></span></p>
                                        <p class="text-muted"><strong>Peso (in kg):</strong><span class="ms-2"><label id="lblWeight"></label></span></p>

                                        <p class="text-muted"><strong>Data/Ora Compilazione :</strong><span class="ms-2"><label id="lblSurveyDateTime"></label></span></p>

                                    </div>

                                </div>
                            </div>

                        </div>

                        <div class="col-xl-6">

                            <div class="card">
                                <div class="card-body">
                                    <h4 class="header-title">Risultato media blocchi</h4>

                                    <table id="tblBlocksCalculation" class="table table-sm table-centered mb-0">
                                        <thead>
                                            <tr>
                                                <th>Blocco</th>
                                                <th>Resultati</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        </tbody>
                                    </table>

                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="row mb-3">
                        <div class="col-xl-6">
                            <!-- Personal-Information -->
                            <div class="card">
                                <div class="card-body">
                                    <div style="width: 450px; height: 400px;" class="chartRadar" id="chartRadar"></div>
                                </div>
                            </div>
                        </div>
                        <div class="col-xl-6">
                            <!-- Personal-Information -->
                            <div class="card">
                                <div class="card-body">
                                    <div style="width: 500px; height: 400px;" class="chartLine" id="chartLine"></div>
                                </div>
                            </div>
                        </div>


                    </div>

                    <div class="row mb-3">
                        <div class="col-xl-12">
                            <div class="card">
                                <div class="card-body">
                                    <h4 class="header-title">Risposte numeriche</h4>

                                    <table id="tblQuestionNumbers" class="table table-sm table-centered mb-0">
                                        <thead>
                                            <tr>
                                                <th>Domanda</th>
                                                <th>Resultati</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        </tbody>
                                    </table>

                                </div>
                            </div>
                        </div>


                    </div>


                    <div class="row mb-3">
                        <div class="col-md-12">
                            <div class="card">
                                <div class="card-body">
                                    <h4 class="header-title">Lista risposte (tipo multiple)</h4>
                                    <br />
                                    <div class="row mb-3">
                                        <div class="col-md-3">
                                            <div class="input-group">
                                                <button id="expandCollapseBtn" onclick="toggleExpandCollapse()" class="btn btn-soft-info">Expand All</button>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                        </div>
                                        <div class="col-md-3">
                                            <div class="input-group">
                                                <input type="text" id="searchInput" class="form-control" placeholder="Search from table...">
                                            </div>
                                        </div>
                                    </div>
                                    <table id="tblSurveyorData" class="table table-sm table-centered mb-0">
                                        <thead>
                                            <tr>
                                                <th>Apri-Chiudi</th>
                                                <th>Blocco / Categoria</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <!-- Table body content will be dynamically generated -->
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>


                </div>
            </div>
        </div>
    </div>
    <script src="../Scripts/jquery-3.3.1.js"></script>

    <script src="https://cdn.jsdelivr.net/npm/echarts/dist/echarts.min.js"></script>

    <script type="text/javascript">

        $(document).ready(function () {

            // Initial load without age filter
            loadSurveyor(null, null);

            $('#txtFromAge, #txtToAge').on('input', function () {
                var value = $(this).val();
                // Remove any non-numeric characters
                $(this).val(value.replace(/\D/g, ''));
                var ageFrom = $('#txtFromAge').val();
                var ageTo = $('#txtToAge').val();

                // Call loadSurveyor with the provided age range
                loadSurveyor(ageFrom, ageTo);
                getTotalSurvey(ageFrom, ageTo);
            });
            $('#ddlSurveyor').change(function () {
                loadDataSurveyDetails();
                loadData();
                loadDataBlockCalculations();
                loadDataQuestionNumbers();
                fetchChartData();
                fetchChartDataLine();
                loadViewCorrectionsApplied();
            });

            getTotalSurvey(null, null);


            $('#searchInput').keyup(function () {
                searchAndExpand();
            });
        });


        function loadViewCorrectionsApplied() {
            var selectedSurveyorId = $('#ddlSurveyor').val();
            $.ajax({
                type: "POST",
                url: "/Pages/ViewSurvey.aspx/GetViewCorrectionsApplied",
                data: JSON.stringify({ surveyorId: selectedSurveyorId }), // Pass selectedSurveyorId as parameter
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d); // Parse the JSON string to an object

                    // Clear existing table rows
                    $('#tblCorrectionApplied tbody').empty();

                    var lastCamID = ''; // To track the last camID
                    var correctionRowspan = 0; // To track rowspan
                    var rowsToMerge = []; // Store rows to merge camID cell

                    // Populate table with new data
                    $.each(data, function (index, item) {
                        var row = $('<tr>');

                        // Check if we are in the same camID group
                        if (item.camID === lastCamID) {
                            // If in the same group, push the row to rowsToMerge
                            correctionRowspan++;
                            rowsToMerge[rowsToMerge.length - 1].push(row);
                        } else {
                            // If new camID group, handle the rowspan for the previous group
                            if (correctionRowspan > 0) {
                                // Set the rowspan attribute for the previous group
                                rowsToMerge[rowsToMerge.length - 1][0].attr('rowspan', correctionRowspan + 1);
                                rowsToMerge[rowsToMerge.length - 1][1].attr('rowspan', correctionRowspan + 1);
                                rowsToMerge[rowsToMerge.length - 1][2].attr('rowspan', correctionRowspan + 1);
                                rowsToMerge[rowsToMerge.length - 1][3].attr('rowspan', correctionRowspan + 1);
                                rowsToMerge[rowsToMerge.length - 1][4].attr('rowspan', correctionRowspan + 1);
                                rowsToMerge[rowsToMerge.length - 1][5].attr('rowspan', correctionRowspan + 1);
                                rowsToMerge[rowsToMerge.length - 1][6].attr('rowspan', correctionRowspan + 1);
                                rowsToMerge[rowsToMerge.length - 1][7].attr('rowspan', correctionRowspan + 1);
                            }

                            // Reset and prepare for the new group
                            lastCamID = item.camID;
                            correctionRowspan = 0;

                            // Create the main group cells for camID
                            var camIDCell = $('<td>').text(item.camID).css({'display':'none'});
                            var correctionIDCell = $('<td>').text(item.correctionMasterId);
                            var correctionNameCell = $('<td>').text(item.correctionName);
                            var globalValueBeforeCell = $('<td>').text(item.globalValue_before);
                            //var globalValueAddCell = $('<td>').text(item.globalValue_add).css({ 'font-weight': 'bold', 'color': 'red', 'font-size': '1.5em' }); // Adjust the size here
                            var globalValueAddCell = $('<td>')
                                .text(item.correctionApplicationType === 'N' ? 'N. A.' :
                                        item.correctionApplicationType === 'F' ? item.globalValue_add + ' (F)' :
                                        item.globalValue_add)
                                .css({
                                    'font-weight': 'bold',
                                    'color': item.correctionApplicationType === 'N' ? 'Orange' :
                                        item.correctionApplicationType === 'F' ? 'RoyalBlue' :
                                            'red', // Default color if neither 'N' nor 'F'
                                    'font-size': '1.5em'
                                });

                            var globalValueAfterCell = $('<td>').text(item.globalValue_after);
                            var messageCell = $('<td>').text(item.message);
                            var notesCell = $('<td>').text(item.notes);

                            // Append these cells for the first row of the group
                            row.append(camIDCell);
                            row.append(correctionIDCell);
                            row.append(correctionNameCell);
                            row.append(globalValueBeforeCell);
                            row.append(globalValueAddCell);
                            row.append(globalValueAfterCell);
                            row.append(messageCell);
                            row.append(notesCell);

                            // Add the first row to the list of rows to merge
                            rowsToMerge.push([camIDCell, correctionIDCell, correctionNameCell, globalValueBeforeCell, globalValueAddCell, globalValueAfterCell, messageCell, notesCell]);
                        }

                        // Add the remaining columns for each cadID (details row) excluding the cadID column
                        // row.append($('<td>').text(item.cadID)); // This line has been removed
                        row.append($('<td>').text(item.conditionType));
                        row.append($('<td>').text(item.blockName));
                        row.append($('<td>').text(item.operatr));
                        row.append($('<td>').text(item.conditionValue1));
                        row.append($('<td>').text(item.conditionValue2));
                        row.append($('<td>').text(item.conjunction));
                        row.append($('<td>').text(item.isApplied));

                        // Append the row to the table
                        $('#tblCorrectionApplied tbody').append(row);
                    });

                    // Handle the last group to set the rowspan
                    if (correctionRowspan > 0) {
                        rowsToMerge[rowsToMerge.length - 1][0].attr('rowspan', correctionRowspan + 1);
                        rowsToMerge[rowsToMerge.length - 1][1].attr('rowspan', correctionRowspan + 1);
                        rowsToMerge[rowsToMerge.length - 1][2].attr('rowspan', correctionRowspan + 1);
                        rowsToMerge[rowsToMerge.length - 1][3].attr('rowspan', correctionRowspan + 1);
                        rowsToMerge[rowsToMerge.length - 1][4].attr('rowspan', correctionRowspan + 1);
                        rowsToMerge[rowsToMerge.length - 1][5].attr('rowspan', correctionRowspan + 1);
                        rowsToMerge[rowsToMerge.length - 1][6].attr('rowspan', correctionRowspan + 1);
                        rowsToMerge[rowsToMerge.length - 1][7].attr('rowspan', correctionRowspan + 1);
                    }
                },
                error: function (xhr, status, error) {
                    console.error(xhr.responseText);
                }
            });
        }



        function getTotalSurvey(ageFrom, ageTo) {
            $.ajax({
                type: "POST",
                url: "/Pages/ViewSurvey.aspx/GetTotalSurvey",
                data: JSON.stringify({ ageFrom: ageFrom, ageTo: ageTo }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    //  console.log(response); // Log the entire response
                    if (response && response.d) { // Check if the response has a property 'd'
                        var data = JSON.parse(response.d); // Parse the JSON string
                        //   console.log(data.totalSurvey); // Log the parsed value
                        $('#totalSurvey').text(data.totalSurvey);
                    }
                },
                error: function (error) {
                    console.error("Error fetching data: ", error);
                }
            });
        }

        function fetchChartData() {
            var selectedSurveyorId = $('#ddlSurveyor').val();
            $.ajax({
                type: "POST",
                url: "/Pages/ViewSurvey.aspx/GetSurveyorGetBlockCalculationsForChart",
                data: JSON.stringify({ surveyorId: selectedSurveyorId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var jsonData = JSON.parse(response.d);
                    getChartRadar(jsonData);
                },
                error: function (error) {
                    console.error("Error fetching data: ", error);
                }
            });
        }

        function fetchChartDataLine() {
            var selectedSurveyorId = $('#ddlSurveyor').val();
            $.ajax({
                type: "POST",
                url: "/Pages/ViewSurvey.aspx/GetSurveyorGetBlockCalculationsForLineChart",
                data: JSON.stringify({ surveyorId: selectedSurveyorId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var jsonData = JSON.parse(response.d);
                    getChartLine(jsonData);
                },
                error: function (error) {
                    console.error("Error fetching data: ", error);
                }
            });
        }

        var chartRadar = echarts.init(document.querySelector('#chartRadar'), null);
        var chartRadar = echarts.init(document.querySelector('#chartRadar'), null);
        function getChartRadar(optionData) {
            // Reverse the order of indicators and the corresponding series data
            var reversedIndicators = optionData.indicators.slice().reverse();
            var reversedSeriesData = optionData.seriesData.map(series => {
                return {
                    ...series,
                    value: series.value.slice().reverse()
                };
            });

            var option = {
                title: {
                    text: 'Dynamic Radar Chart',
                    left: 'left',
                    top: '3%'
                },
                tooltip: {
                    trigger: 'item'
                },
                radar: {
                    center: ['50%', '50%'], // Adjust the center to move the chart down slightly
                    radius: '50%', // Adjust the radius to fit within the container
                    indicator: reversedIndicators, // Reverse the order of indicators
                    name: {
                        textStyle: {
                            fontSize: 12,
                            color: '#333'
                        },
                        formatter: function (name) {
                            return name.length > 10 ? name.slice(0, 10) + '\n' + name.slice(10) : name;
                        }
                    },
                    axisLabel: {
                        fontSize: 10, // Adjust font size of axis labels
                        color: '#333' // Set the color of the axis labels
                    }
                },
                series: [
                    {
                        name: 'Results',
                        type: 'radar',
                        data: reversedSeriesData,
                        label: {
                            show: true,
                            formatter: function (params) {
                                return params.value;
                            }
                        },
                        itemStyle: {
                            emphasis: {
                                areaStyle: {
                                    color: 'rgba(0,250,0,0.3)'
                                }
                            }
                        }
                    }
                ],
                grid: {
                    left: '5%', // Adjust grid left padding
                    right: '10%',
                    top: '10%',
                    bottom: '10%'
                }
            };

            if (option && typeof option === 'object') {
                chartRadar.setOption(option);
            }
        }

        var chartLine = echarts.init(document.querySelector('#chartLine'), null);


        function getChartLine(optionData) {
            var option = {
                title: {
                    text: 'Line Chart',
                    left: 'left',
                    top: '3%'
                },
                grid: {
                    left: '3%', // Adjust grid left padding
                    right: '3%', // Adjust grid right padding
                    bottom: '8%', // Adjust grid bottom padding
                    containLabel: true,
                    show: false // Hide grid lines
                },
                tooltip: {
                    trigger: 'axis'
                },
                toolbox: {
                    right: 20, // Adjust toolbox position
                    top: 10, // Adjust toolbox position
                    show: true,
                    feature: {
                        dataZoom: {
                            yAxisIndex: 'none'
                        },
                        dataView: { readOnly: false },
                        magicType: { type: ['line', 'bar'] },
                        restore: {},
                        saveAsImage: {}
                    }
                },
                legend: {
                    left: 'left',
                    bottom: 10,
                    itemGap: 20, // Gap between legend items
                    itemWidth: 20, // Legend icon width
                    itemHeight: 10, // Legend icon height
                    textStyle: {
                        fontSize: 14, // Legend text font size
                        fontWeight: 'bold', // Legend text font weight
                        color: '#333' // Legend text color
                    },
                    data: [{
                        name: 'Media Globale',
                        icon: 'line', // Use 'line' icon for 'Media Globale'
                        textStyle: {
                            color: 'red' // Legend text color
                        }
                    }],
                    selected: { // Selected to show 'Media Globale' by default
                        'Media Globale': true
                    },
                    formatter: function (name) {
                        // Custom legend formatter to display name and value
                        var value = optionData.resultLine; // Value from optionData
                        return name + ' ' + value;
                    }
                },
                xAxis: {
                    type: 'category',
                    boundaryGap: false,
                    data: optionData.xAxisData, // Assuming optionData.xAxisData is an array of categories like ['Mon', 'Tue', 'Wed', ...]
                    axisLabel: {
                        rotate: 45, // Rotate x-axis labels by 45 degrees
                        interval: 0, // Show all labels
                        formatter: function (value) {
                            // You can format the label here if needed
                            return value;
                        },
                        margin: 20 // Add margin between axis label and axis
                    },
                    splitLine: {
                        show: false // Hide x-axis split lines
                    }
                },
                yAxis: {
                    type: 'value',
                    min: 0,
                    max: 6,
                    interval: 0.5,
                    axisLabel: {
                        formatter: '{value}' // Show all values on y-axis
                    },
                    splitLine: {
                        show: false // Hide y-axis split lines
                    }
                },
                series: [
                    {
                        name: 'Resultati', // Name for the line series
                        type: 'line',
                        data: optionData.seriesData, // Assuming optionData.seriesData is an array of values like [10, 11, 13, ...]
                        label: {
                            show: true, // Show labels on data points
                            formatter: '{c}' // Show value labels as plain numbers
                        }
                    },
                    {
                        name: 'Media Globale', // Name for the red mark line
                        type: 'line',
                        markLine: {
                            symbol: ['none', 'none'], // Remove symbol at the end of the line
                            lineStyle: {
                                color: 'red', // Set mark line color to red
                                width: 5, // Set the width of the mark line to 5
                                type: 'solid' // Make the line type solid
                            },
                            data: [
                                { type: 'average', name: 'Avg' },
                                { yAxis: optionData.resultLine, lineStyle: { color: 'red', width: 5, type: 'solid' } } // New mark line based on result data column with red color
                            ]
                        },
                        label: {
                            show: true, // Show labels on the red mark line
                            position: 'end', // Position the label at the end of the line
                            formatter: function (params) {
                                return params.value; // Show original value without rounding
                            },
                            color: 'red', // Label text color
                            fontSize: 12, // Label font size
                            fontWeight: 'bold' // Label font weight
                        }
                    },
                    {
                        type: 'line',
                        markArea: {
                            silent: true,
                            itemStyle: {
                                color: 'rgba(0, 128, 0, 0.3)' // Green color with transparency
                            },
                            data: [
                                [
                                    {
                                        yAxis: 2.5
                                    },
                                    {
                                        yAxis: 5
                                    }
                                ]
                            ]
                        }
                    }
                ]
            };

            if (option && typeof option === 'object') {
                chartLine.setOption(option);
            }

            // Resize chart when window size changes
            window.addEventListener('resize', function () {
                chartLine.resize();
            });
        }

        function deleteSurvey() {

            var id = $("#ddlSurveyor").val();

            if (id === "-1") {
                showAlert('seleziona geometra valido', 'danger');
                return; // Exit the function
            }

            if (confirm("Confermi eliminazione?")) {

                showAlert('', '');

                var data = {
                    id: id
                };

                $.ajax({
                    type: "POST",
                    url: "/Pages/ViewSurvey.aspx/DeleteData",
                    data: JSON.stringify({ id: id }), // Replace `itemId` with the actual ID or data you need to send
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        if (response.d === "success") {
                            showAlert('Cancellazione eseguita', 'delete');
                            loadSurveyor(null, null);
                            clearData();

                        } else {
                            showAlert('Errore inserimento dati', 'danger');
                        }
                    },
                    error: function (xhr, textStatus, errorThrown) {
                        showAlert('Errore inserimento dati', 'danger');
                    },
                    complete: function () {
                        // Hide spinner button, show save button
                        hideOverlay();
                    }
                });
            }


        }

        function loadSurveyor(ageFrom, ageTo) {
            $.ajax({
                type: "POST",
                url: "/Pages/ViewSurvey.aspx/GetSurveyor",
                data: JSON.stringify({ ageFrom: ageFrom, ageTo: ageTo }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d);

                    $('#ddlSurveyor').empty();

                    // Add "select" option at the beginning
                    $('#ddlSurveyor').append($('<option>', {
                        value: -1,
                        text: '-- Seleziona --'
                    }));

                    $.each(data, function (index, item) {
                        $('#ddlSurveyor').append($('<option>', {
                            value: item.quesMasterId,
                            text: item.name
                        }));
                    });

                },
                error: function (xhr, status, error) {
                    console.error(xhr.responseText);
                }
            });
        }


        var originalData = [];

        function loadData() {
            var selectedSurveyorId = $('#ddlSurveyor').val();
            $.ajax({
                type: "POST",
                url: "/Pages/ViewSurvey.aspx/GetSurveyorData",
                data: JSON.stringify({ surveyorId: selectedSurveyorId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    originalData = JSON.parse(response.d);
                    populateTable(originalData);
                },
                error: function (xhr, status, error) {
                    console.error(xhr.responseText);
                }
            });
        }

        function populateTable(data) {
            $('#tblSurveyorData tbody').empty();

            var groupedData = {};
            data.forEach(function (item) {
                if (!groupedData[item.blockName]) {
                    groupedData[item.blockName] = {};
                }
                if (!groupedData[item.blockName][item.categoryName]) {
                    groupedData[item.blockName][item.categoryName] = [];
                }
                groupedData[item.blockName][item.categoryName].push(item);
            });

            for (var blockName in groupedData) {
                if (groupedData.hasOwnProperty(blockName)) {
                    (function (blockName) {
                        var row = $('<tr>').addClass('block-row').click(function () {
                            toggleBlockDetails(blockName, $(this).find('.action-icon'));
                        });

                        var actionColumn = $('<td>').addClass('table-action');
                        var expandButton = $('<a>').attr('href', 'javascript:void(0);').addClass('action-icon expand').click(function (e) {
                            e.stopPropagation();  // Prevent row click event
                            toggleBlockDetails(blockName, $(this));
                        }).append($('<i>').addClass('mdi mdi-plus-circle mdi-24px'));
                        actionColumn.append(expandButton);

                        row.append(actionColumn);
                        row.append($('<td>').text(blockName));

                        $('#tblSurveyorData tbody').append(row);
                    })(blockName);
                }
            }
        }

        function searchAndExpand() {
            var searchTerm = $('#searchInput').val().toLowerCase();

            if (searchTerm === '') {
                populateTable(originalData);
                return;
            }

            var filteredData = originalData.filter(function (item) {
                return item.blockName.toLowerCase().includes(searchTerm) ||
                    item.categoryName.toLowerCase().includes(searchTerm) ||
                    item.questionName.toLowerCase().includes(searchTerm) ||
                    item.optionName.toLowerCase().includes(searchTerm) ||
                    item.optionValue.toLowerCase().includes(searchTerm);
            });

            var groupedData = {};
            filteredData.forEach(function (item) {
                if (!groupedData[item.blockName]) {
                    groupedData[item.blockName] = {};
                }
                if (!groupedData[item.blockName][item.categoryName]) {
                    groupedData[item.blockName][item.categoryName] = [];
                }
                groupedData[item.blockName][item.categoryName].push(item);
            });

            $('#tblSurveyorData tbody').empty();

            for (var blockName in groupedData) {
                if (groupedData.hasOwnProperty(blockName)) {
                    var blockRow = createBlockRow(blockName, searchTerm);
                    $('#tblSurveyorData tbody').append(blockRow);

                    var blockExpanded = false;

                    for (var categoryName in groupedData[blockName]) {
                        if (groupedData[blockName].hasOwnProperty(categoryName)) {
                            var categoryRow = createCategoryRow(blockName, categoryName, searchTerm);
                            blockRow.after(categoryRow);

                            var innerTableRow = $('<tr>').addClass('inner-table-row').attr('data-category', categoryName);
                            innerTableRow.hide();
                            categoryRow.after(innerTableRow);

                            if (searchTerm !== '') {
                                toggleCategoryDetails(blockName, categoryName, categoryRow.find('.action-icon'), searchTerm);

                                var categoryButton = categoryRow.find('.action-icon');
                                if (categoryButton.find('i').hasClass('mdi-plus-circle')) {
                                    categoryButton.find('i').removeClass('mdi-plus-circle').addClass('mdi-minus-circle');
                                }
                            }
                        }
                    }

                    if (searchTerm !== '') {
                        var blockButton = blockRow.find('.action-icon');
                        if (blockButton.find('i').hasClass('mdi-plus-circle')) {
                            blockButton.find('i').removeClass('mdi-plus-circle').addClass('mdi-minus-circle');
                        }
                    }
                }
            }
        }

        function createBlockRow(blockName, searchTerm) {
            var row = $('<tr>').addClass('block-row').click(function () {
                toggleBlockDetails(blockName, $(this).find('.action-icon'), searchTerm);
            });

            var actionColumn = $('<td>').addClass('table-action');
            var expandButton = $('<a>').attr('href', 'javascript:void(0);').addClass('action-icon expand').click(function (e) {
                e.stopPropagation();
                toggleBlockDetails(blockName, $(this), searchTerm);
            }).append($('<i>').addClass('mdi mdi-plus-circle mdi-24px'));
            actionColumn.append(expandButton);

            row.append(actionColumn);
            row.append($('<td>').text(blockName));

            return row;
        }

        function createCategoryRow(blockName, categoryName, searchTerm) {
            var row = $('<tr>').addClass('inner-category-row').attr('data-block', blockName).attr('data-category', categoryName).click(function () {
                toggleCategoryDetails(blockName, categoryName, $(this).find('.action-icon'), searchTerm);
            });

            var actionColumn = $('<td>').addClass('table-action');
            var expandButton = $('<a>').attr('href', 'javascript:void(0);').addClass('action-icon expand').click(function (e) {
                e.stopPropagation();
                toggleCategoryDetails(blockName, categoryName, $(this), searchTerm);
            }).append($('<i>').addClass('mdi mdi-plus-circle mdi-24px'));
            actionColumn.append(expandButton);

            row.append(actionColumn);
            row.append($('<td>').text(categoryName).attr('colspan', '2'));

            return row;
        }

        function toggleBlockDetails(blockName, buttonElement, searchTerm = '') {
            var isExpanded = buttonElement.find('i').hasClass('mdi-minus-circle');

            if (isExpanded) {
                buttonElement.find('i').removeClass('mdi-minus-circle').addClass('mdi-plus-circle');
                buttonElement.removeClass('collapse').addClass('expand');
                buttonElement.closest('tr').nextUntil('tr.block-row').remove();
            } else {
                var filteredData = originalData.filter(item => item.blockName === blockName);
                var groupedByCategory = {};

                filteredData.forEach(function (item) {
                    if (!groupedByCategory[item.categoryName]) {
                        groupedByCategory[item.categoryName] = [];
                    }
                    groupedByCategory[item.categoryName].push(item);
                });

                for (var categoryName in groupedByCategory) {
                    if (groupedByCategory.hasOwnProperty(categoryName)) {
                        var categoryRow = createCategoryRow(blockName, categoryName, searchTerm);
                        buttonElement.closest('tr').after(categoryRow);

                        var innerTableRow = $('<tr>').addClass('inner-table-row').attr('data-category', categoryName);
                        innerTableRow.hide();
                        categoryRow.after(innerTableRow);

                        if (searchTerm !== '') {
                            toggleCategoryDetails(blockName, categoryName, categoryRow.find('.action-icon'), searchTerm);
                            var categoryButton = categoryRow.find('.action-icon');
                            if (categoryButton.find('i').hasClass('mdi-plus-circle')) {
                                categoryButton.find('i').removeClass('mdi-plus-circle').addClass('mdi-minus-circle');
                            }
                        }
                    }
                }

                buttonElement.find('i').removeClass('mdi-plus-circle').addClass('mdi-minus-circle');
                buttonElement.removeClass('expand').addClass('collapse');
            }
        }

        function toggleCategoryDetails(blockName, categoryName, buttonElement, searchTerm = '') {

            var isExpanded = buttonElement.find('i').hasClass('mdi-minus-circle');
            var innerTableRow = buttonElement.closest('tr').nextAll('.inner-table-row[data-category="' + categoryName + '"]').first();

            if (isExpanded) {
                buttonElement.find('i').removeClass('mdi-minus-circle').addClass('mdi-plus-circle');
                buttonElement.removeClass('collapse').addClass('expand');
                innerTableRow.hide();
            } else {
                var filteredData = originalData.filter(function (item) {
                    return item.blockName === blockName && item.categoryName === categoryName &&
                        (searchTerm === '' ||
                            item.questionName.toLowerCase().includes(searchTerm) ||
                            item.optionName.toLowerCase().includes(searchTerm) ||
                            item.optionValue.toLowerCase().includes(searchTerm)
                        );
                });

                var innerTable = $('<table>').addClass('table table-sm table-centered nowrap mb-0 inner-table');
                var headerRow = $('<tr>');
                headerRow.append('<th>Id <i class="mdi mdi-arrow-up"></i></th>');
                headerRow.append('<th>Domanda <i class="mdi mdi-arrow-up"></i></th>');
                headerRow.append('<th>Descrizione risposta <i class="mdi mdi-arrow-up"></i></th>');
                headerRow.append('<th>Valore <i class="mdi mdi-arrow-up"></i></th>');
                innerTable.append(headerRow);

                filteredData.forEach(function (item) {
                    var row = $('<tr>');
                    row.append($('<td>').text(item.questionId));
                    var questionNameCell = $('<td>').addClass('textQuestionName').text(item.questionName);
                    if (item.questionName.length > 20) {
                        questionNameCell.attr('title', item.questionName);
                    }
                    row.append(questionNameCell);
                    row.append($('<td>').text(item.optionName || ''));
                    row.append($('<td>').text(item.optionValue || ''));

                    innerTable.append(row);
                });

                innerTableRow.html($('<td>').attr('colspan', '5').append(innerTable));
                innerTableRow.show();

                // Add click event for sorting
                innerTable.find('th').click(function () {
                    var column = $(this).index();
                    var asc = !$(this).hasClass('asc');
                    sortInnerTable(innerTable, column, asc);
                    innerTable.find('th').removeClass('asc desc').find('i').removeClass('mdi-arrow-up mdi-arrow-down').addClass('mdi-arrow-up');
                    if (asc) {
                        $(this).addClass('asc').find('i').removeClass('mdi-arrow-up').addClass('mdi-arrow-down');
                    } else {
                        $(this).addClass('desc').find('i').removeClass('mdi-arrow-down').addClass('mdi-arrow-up');
                    }
                });

                buttonElement.find('i').removeClass('mdi-plus-circle').addClass('mdi-minus-circle');
                buttonElement.removeClass('expand').addClass('collapse');
            }
        }

        function sortInnerTable(table, column, asc) {
            var rows = table.find('tr:gt(0)').toArray().sort(function (a, b) {
                var cellA = $(a).children('td').eq(column).text();
                var cellB = $(b).children('td').eq(column).text();
                var comparison = cellA.localeCompare(cellB, undefined, { numeric: true });
                return asc ? comparison : -comparison;
            });
            table.append(rows);
        }
        function toggleExpandCollapse() {
            var expandAll = !$('#expandCollapseBtn').data('expanded'); // Toggle expanded state
            $('#expandCollapseBtn').data('expanded', expandAll);

            if (expandAll) {
                $('#expandCollapseText').text('Collapse All');
                $('#expandCollapseBtn').removeClass('btn-soft-info').addClass('btn-soft-warning');
            } else {
                $('#expandCollapseText').text('Expand All');
                $('#expandCollapseBtn').removeClass('btn-soft-warning').addClass('btn-soft-info');
            }

            $('#tblSurveyorData tbody tr.block-row').each(function () {
                var blockName = $(this).find('td:nth-child(2)').text();
                var buttonElement = $(this).find('.action-icon');

                if (expandAll && buttonElement.hasClass('expand')) {
                    toggleBlockDetails(blockName, buttonElement);
                } else if (!expandAll && buttonElement.hasClass('collapse')) {
                    toggleBlockDetails(blockName, buttonElement);
                }
            });

            $('#tblSurveyorData tbody tr.inner-category-row').each(function () {
                var blockName = $(this).attr('data-block');
                var categoryName = $(this).attr('data-category');
                var buttonElement = $(this).find('.action-icon');

                if (expandAll && buttonElement.hasClass('expand')) {
                    toggleCategoryDetails(blockName, categoryName, buttonElement);
                } else if (!expandAll && buttonElement.hasClass('collapse')) {
                    toggleCategoryDetails(blockName, categoryName, buttonElement);
                }
            });

            $('#expandCollapseBtn').text(expandAll ? 'Collapse All' : 'Expand All');
        }
        function loadDataSurveyDetails() {
            var selectedSurveyorId = $('#ddlSurveyor').val();
            $.ajax({
                type: "POST",
                url: "/Pages/ViewSurvey.aspx/GetSurveyorDataDetails",
                data: JSON.stringify({ surveyorId: selectedSurveyorId }), // Pass selectedSurveyorId as parameter
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {

                    var data = JSON.parse(response.d);

                    // Check if the response contains the expected properties
                    if (data && data.name) {
                        $('#lblName').text(data.name);
                        $('#lblSurname').text(data.surname);
                        $('#lblGender').text(data.gender);
                        $('#lblDOB').text(data.dob);
                        $('#lblEmail').text(data.email);
                        $('#lblbmiValue').text(data.bmiValue);
                        $('#lblHeight').text(data.height);
                        $('#lblWeight').text(data.weight);

                        $('#lblSurveyDateTime').text(data.createdDate);


                    }
                },
                error: function (xhr, status, error) {
                    console.error(xhr.responseText);
                }
            });
        }

        function loadDataBlockCalculations() {
            var selectedSurveyorId = $('#ddlSurveyor').val();
            $.ajax({
                type: "POST",
                url: "/Pages/ViewSurvey.aspx/GetSurveyorGetBlockCalculations",
                data: JSON.stringify({ surveyorId: selectedSurveyorId }), // Pass selectedSurveyorId as parameter
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {

                    var data = JSON.parse(response.d); // Parse the JSON string to an object

                    // Clear existing table rows
                    $('#tblBlocksCalculation tbody').empty();
                    var serialNo = 1;
                    // Populate table with new data
                    $.each(data, function (index, item) {
                        var row = $('<tr>');
                        row.append($('<td>').text(item.blockName));
                        row.append($('<td>').text(item.result));

                        $('#tblBlocksCalculation tbody').append(row);
                    });

                    // Select the last row and add a class to it
                    $('#tblBlocksCalculation tbody tr:last').addClass('highlight-last-row');

                    // Select the second last row and add a class to it
                    $('#tblBlocksCalculation tbody tr').eq(-2).addClass('highlight-second-last-row');


                },
                error: function (xhr, status, error) {
                    console.error(xhr.responseText);
                }
            });
        }

        function loadDataQuestionNumbers() {
            var selectedSurveyorId = $('#ddlSurveyor').val();
            $.ajax({
                type: "POST",
                url: "/Pages/ViewSurvey.aspx/GetSurveyorGetQuestionNumbers",
                data: JSON.stringify({ surveyorId: selectedSurveyorId }), // Pass selectedSurveyorId as parameter
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {

                    var data = JSON.parse(response.d); // Parse the JSON string to an object

                    // Clear existing table rows
                    $('#tblQuestionNumbers tbody').empty();
                    var serialNo = 1;
                    // Populate table with new data
                    $.each(data, function (index, item) {
                        var row = $('<tr>');
                        row.append($('<td>').text(item.questionName));
                        row.append($('<td>').text(item.optionValue));

                        $('#tblQuestionNumbers tbody').append(row);
                    });

                },
                error: function (xhr, status, error) {
                    console.error(xhr.responseText);
                }
            });
        }

        function clearData() {

            $("#tblSurveyorData tbody").empty();
            $("#tblBlocksCalculation tbody").empty();
            $("#tblQuestionNumbers tbody").empty();

            $('#lblName').text("");
            $('#lblSurname').text("");
            $('#lblGender').text("");
            $('#lblDOB').text("");
            $('#lblEmail').text("");
            $('#lblSurveyDateTime').text("");
            $('#lblbmiValue').text("");
            $('#lblHeight').text("");
            $('#lblWeight').text("");


        }


    </script>



</asp:Content>
