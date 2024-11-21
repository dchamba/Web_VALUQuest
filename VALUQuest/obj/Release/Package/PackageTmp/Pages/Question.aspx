<%@ Page Title="" Language="C#" MasterPageFile="~/Template/ValuMaster.Master" AutoEventWireup="true" CodeBehind="Question.aspx.cs" Inherits="VALUQuest.Pages.Question" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" integrity="sha384-k6RqeWeci5ZR/Lv4MR0sA0FfDOMUdeFrHGk5Uo9G6M2MSkHj/EZWzBe3pS/uHnZy" crossorigin="anonymous">


    <style>
        .hidden {
            display: none;
        }

        .switch {
            position: relative;
            display: inline-block;
            width: 34px;
            height: 20px;
        }

            .switch input {
                opacity: 0;
                width: 0;
                height: 0;
            }

        .slider {
            position: absolute;
            cursor: pointer;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: #ccc;
            transition: .4s;
            border-radius: 34px;
        }

            .slider:before {
                position: absolute;
                content: "";
                height: 14px;
                width: 14px;
                left: 3px;
                bottom: 3px;
                background-color: white;
                transition: .4s;
                border-radius: 50%;
            }

        input:checked + .slider {
            background-color: #FF0000;
        }

            input:checked + .slider:before {
                transform: translateX(14px);
            }

        .slider.round {
            border-radius: 34px;
        }

            .slider.round:before {
                border-radius: 50%;
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
                <h4 class="page-title">Domande</h4>
            </div>
        </div>
    </div>

    <div id="msgAlert"></div>
    <input type="hidden" id="hiddenQuestionId">
    <div class="row">
        <div class="col-12">
            <div class="card">
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-4">
                            <label class="form-label">Blocco</label>
                            <select id="ddlBlock" class="form-select form-select-sm mb-3">
                            </select>
                        </div>

                        <div class="col-md-4">
                            <label class="form-label">Categoria</label>
                            <select id="ddlCategory" class="form-select form-select-sm mb-3">
                            </select>
                        </div>

                        <div class="col-md-4">
                            <label class="form-label">Sottocategoria</label>
                            <!-- Label for Sub Category dropdown -->
                            <select id="ddlSubCategory" class="form-select form-select-sm">
                            </select>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-6">
                            <label class="form-label">Domanda</label>
                            <input type="text" class="form-control form-control-sm" id="txtQuestion">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Tipo di domanda</label>
                            <select id="quesType" class="form-select form-select-sm mb-3">
                                <option value="-1">Seleziona</option>
                                <option value="2">Risposte multiple</option>
                                <option value="1">Numerica</option>
                            </select>
                        </div>
                    </div>

                    <!-- Panel for Number Question Type -->
                    <div id="pnlNumberQuesType" style="display: none;">
                        <div class="row mb-3">
                            <div class="col-md-3">
                                <label class="form-label">Valore min</label>
                                <input type="text" class="form-control form-control-sm" id="txtMinValue">
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">Valore max</label>
                                <input type="text" class="form-control form-control-sm" id="txtMaxValue">
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">Unità</label>
                                <input type="text" class="form-control form-control-sm" id="txtUnit">
                            </div>
                        </div>
                    </div>

                    <!-- Panel for MCQS Question Type -->
                    <div id="pnlMCQ" style="display: none;">
                        <div class="row mb-3">
                            <div class="col-md-3">
                                <label class="form-label">Descrizione risposta</label>
                                <input type="text" class="form-control form-control-sm" id="txtOption">
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">Valore</label>
                                <input type="text" class="form-control form-control-sm" id="txtScore">
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">Contentuto</label>
                                <!-- New label for Option Message -->
                                <input type="text" class="form-control form-control-sm" id="txtOptionMessage">
                                <!-- New textbox for Option Message -->
                            </div>
                            <div class="col-md-3">
                                <button type="button" class="btn btn-primary btn-sm" style="margin-top: 28px;" id="btnAddNew">Aggiungi risposta</button>
                            </div>
                        </div>

                        <!-- Table to store MCQS options and scores -->
                        <div class="row">
                            <div class="col-md-12">
                                <table class="table" id="tblMCQSOptions">
                                    <thead>
                                        <tr>
                                            <th class="d-none">optionId</th>
                                            <th>N.</th>
                                            <th>Descrizione risposta</th>
                                            <th>Valore</th>
                                            <th>Contentuto</th>
                                            <th>Azione</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>

                    <div class="row mb-3">
                        <div class="col-md-3">
                            <button type="button" class="btn btn-primary btn-sm" style="margin-top: 28px;" onclick="handleSaveUpdate()" id="saveButton">Salva</button>
                        </div>
                        <div class="col-md-6">
                        </div>
                        <div class="col-md-3">
                            <button type="button" class="btn btn-warning btn-sm" style="margin-top: 28px;" id="downloadButton">Download</button>
                            <button id="expandCollapseBtn" onclick="toggleExpandCollapse()" style="margin-top: 28px;" class="btn btn-soft-info btn-sm">
                                        Expand All
                                    </button>
                        </div>
                    </div>

                    <div class="row">

                        <div class="row">
                            <div class="col-md-3">
                                <div class="input-group">
                                    
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

                        <div class="col-md-12">
                            <div class="table-responsive">
                                <table id="tblQuestions" class="table table-sm table-centered mb-0">
                                    <thead>
                                        <tr>
                                            <th>Apri-Chiudi</th>
                                            <th>Blocco / Categoria</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                    </div>


                </div>
            </div>
        </div>
    </div>
    <script src="../Scripts/jquery-3.3.1.js"></script>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.16.2/xlsx.full.min.js"></script>

    <script>
        $(document).ready(function () {
            loadDataQuestions();

            loadBlocks();

            $('#ddlBlock').change(function () {

                var blockId = document.getElementById('ddlBlock').value;
                changeCategory(blockId, -1);

            });

            $('#ddlCategory').change(function () {

                var categoryId = document.getElementById('ddlCategory').value;
                changeSubCategory(categoryId, -1);

            });



            // Dropdown change event
            $('#quesType').change(function () {
                var selectedType = $(this).val();

                // Hide both panels initially
                $('#pnlNumberQuesType').hide();
                $('#pnlMCQ').hide();

                // Display the appropriate panel based on selected question type
                if (selectedType === "1") {
                    $('#pnlNumberQuesType').show();
                } else if (selectedType === "2") {
                    $('#pnlMCQ').show();
                }


            });

            // Add New button click event
            $('#btnAddNew').click(function () {
                // Get option, score, and option message values from text boxes
                var optionText = $('#txtOption').val();
                var scoreText = $('#txtScore').val();
                var optionMessageText = $('#txtOptionMessage').val(); // Capture the Option Message value

                // Calculate the serial number based on the current row count
                var serialNumber = $('#tblMCQSOptions tbody tr').length + 1;

                // Create a new table row
                var newRow = $('<tr></tr>');
                newRow.append($('<td>').addClass('hidden').append($('<input>').attr('type', 'hidden').val(""))); // Hidden input for optionId

                newRow.append('<td>' + serialNumber + '</td>'); // Add the serial number cell
                newRow.append('<td>' + optionText + '</td>'); // Add the option cell
                newRow.append('<td>' + scoreText + '</td>'); // Add the score cell
                newRow.append('<td >' + optionMessageText + '</td>'); // Add the Option Message cell

                // Create delete button and action column
                var deleteButton = $('<a>').attr('href', 'javascript:void(0);').addClass('action-icon').click(function () {
                    $(this).closest('tr').remove(); // Remove the closest row to the clicked delete button
                }).append($('<i>').addClass('mdi mdi-delete'));

                var actionColumn = $('<td>').addClass('table-action').append(deleteButton);

                // Append the action column to the new row
                newRow.append(actionColumn);

                // Append the new row to the table
                $('#tblMCQSOptions tbody').append(newRow);

                // Clear the input text boxes for the next entry
                $('#txtOption').val('');
                $('#txtScore').val('');
                $('#txtOptionMessage').val(''); // Clear the Option Message textbox


            });
            // Load initial data


            $('#searchInput').on('input', function () {
                searchAndExpand();
            });

        });


        function exportToExcel(data) {
            // Filter the data to include only the specified fields
            var filteredData = data.map(item => ({
                questionId: item.questionId,
                blockName: item.blockName,
                categoryName: item.categoryName, // Assuming this should be included based on context
                subCatName: item.subCatName,
                questionName: item.questionName,
                options: item.options
            }));

            // Convert JSON to a worksheet
            var ws = XLSX.utils.json_to_sheet(filteredData);

            // Create a new workbook
            var wb = XLSX.utils.book_new();
            XLSX.utils.book_append_sheet(wb, ws, "Questions");

            // Export the workbook to a file
            XLSX.writeFile(wb, "QuestionsData.xlsx");
        }


        function toggleExpandCollapse() {

            var expandAll = !$('#expandCollapseBtn').data('expanded'); // Toggle expanded state
            $('#expandCollapseBtn').data('expanded', expandAll);

            if (expandAll) {
                $('#expandCollapseText').text('Collapse All');
                $('#expandCollapseBtn').removeClass('btn btn-soft-info').addClass('btn btn-soft-warning');
            } else {
                $('#expandCollapseText').text('Expand All');
                $('#expandCollapseBtn').removeClass('btn btn-soft-warning').addClass('btn btn-soft-info');
            }

            $('#tblQuestions tbody tr.block-row').each(function () {
                var blockName = $(this).find('td:nth-child(2)').text();
                var buttonElement = $(this).find('.action-icon');

                if (expandAll && buttonElement.hasClass('expand')) {
                    toggleBlockDetails(blockName, buttonElement);
                } else if (!expandAll && buttonElement.hasClass('collapse')) {
                    toggleBlockDetails(blockName, buttonElement);
                }
            });

            $('#tblQuestions tbody tr.inner-category-row').each(function () {
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


        var originalData = [];

        function loadDataQuestions() {
            $.ajax({
                type: "POST",
                url: "/Pages/Question.aspx/GetQuestionData",
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


        function downloadQuestions() {
            $.ajax({
                type: "POST",
                url: "/Pages/Question.aspx/GetQuestionData",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    originalData = JSON.parse(response.d);
                    exportToExcel(originalData);
                },
                error: function (xhr, status, error) {
                    console.error(xhr.responseText);
                }
            });
        }

        function populateTable(data) {
            $('#tblQuestions tbody').empty();
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
                        }).append($('<i>').addClass('mdi mdi-plus-circle'));
                        actionColumn.append(expandButton);

                        row.append(actionColumn);
                        row.append($('<td>').text(blockName));

                        $('#tblQuestions tbody').append(row);
                    })(blockName);
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
            }).append($('<i>').addClass('mdi mdi-plus-circle'));
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
            }).append($('<i>').addClass('mdi mdi-plus-circle'));
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
                                categoryButton.removeClass('expand').addClass('collapse');
                            }
                        }
                    }
                }

                buttonElement.find('i').removeClass('mdi-plus-circle').addClass('mdi-minus-circle');
                buttonElement.removeClass('expand').addClass('collapse');
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
                    item.questionName.toLowerCase().includes(searchTerm);
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

            $('#tblQuestions tbody').empty();

            for (var blockName in groupedData) {
                if (groupedData.hasOwnProperty(blockName)) {
                    var blockRow = createBlockRow(blockName, searchTerm);
                    $('#tblQuestions tbody').append(blockRow);

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
                                    categoryButton.removeClass('expand').addClass('collapse');
                                }
                            }
                        }
                    }

                    if (searchTerm !== '') {
                        var blockButton = blockRow.find('.action-icon');
                        if (blockButton.find('i').hasClass('mdi-plus-circle')) {
                            blockButton.find('i').removeClass('mdi-plus-circle').addClass('mdi-minus-circle');
                            blockButton.removeClass('expand').addClass('collapse');
                        }
                    }
                }
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
                            item.blockName.toLowerCase().includes(searchTerm) ||
                            item.categoryName.toLowerCase().includes(searchTerm) ||
                            item.questionName.toLowerCase().includes(searchTerm)
                        );
                });


                var innerTable = $('<table>').addClass('table table-sm table-centered nowrap mb-0 inner-table');
                var headerRow = $('<tr>');
                headerRow.append('<th>Id<i class="mdi mdi-arrow-up"></th>');
                headerRow.append('<th>Sottocategoria<i class="mdi mdi-arrow-up"></th>');
                headerRow.append('<th>Domanda<i class="mdi mdi-arrow-up"></th>');
                headerRow.append('<th>Tipo<i class="mdi mdi-arrow-up"></th>');
                headerRow.append('<th>Valore min<i class="mdi mdi-arrow-up"></th>');
                headerRow.append('<th>Valore max<i class="mdi mdi-arrow-up"></th>');
                headerRow.append('<th>Unità<i class="mdi mdi-arrow-up"></th>');
                headerRow.append('<th>Descrizione risposta<i class="mdi mdi-arrow-up"></th>');
                headerRow.append('<th>Escludi da "domande casuali" <i class="mdi mdi-arrow-up"></th>');
                headerRow.append('<th>Azione <i class="mdi mdi-arrow-up"></th>');
                innerTable.append(headerRow);

                // Add data rows for the inner table
                filteredData.forEach(function (item) {
                    var row = $('<tr>');

                    row.append($('<td>').addClass('d-none').text(item.blockId));
                    row.append($('<td>').addClass('d-none').text(item.questionId));
                    row.append($('<td>').addClass('d-none').text(item.catId));
                    row.append($('<td>').addClass('d-none').text(item.subCatId));
                    row.append($('<td>').addClass('d-none').text(item.quesType));
                    row.append($('<td>').addClass('d-none').text(item.isExcludeFromDynamicQuestion));
                    row.append($('<td>').text(item.questionId));
                    row.append($('<td>').text(item.subCatName));
                    var questionNameCell = $('<td>').addClass('textQuestionName').text(item.questionName);
                    if (item.questionName.length > 20) {
                        questionNameCell.attr('title', item.questionName);
                    }
                    row.append(questionNameCell);
                    row.append($('<td>').text(item.quesTypeName || ''));
                    row.append($('<td>').text(item.minValue || ''));
                    row.append($('<td>').text(item.maxValue || ''));
                    row.append($('<td>').text(item.unit || ''));
                    var optionsCell = $('<td>').addClass('text-ellipsis').text(item.options || '');
                    if (item.options && item.options.length > 20) {
                        optionsCell.attr('title', item.options);
                    }
                    row.append(optionsCell);

                    var excludeCell = $('<td>');
                    var isChecked = item.isExcludeFromDynamicQuestion == 1 ? 'checked' : '';
                    var toggleButton = `
                    <label class="switch">
                        <input type="checkbox" ${isChecked} onclick="toggleExcludeFromDynamicQuestion(${item.questionId}, this)">
                        <span class="slider round"></span>
                    </label>`;
                    excludeCell.html(toggleButton);
                    row.append(excludeCell);

                    var actionColumn = $('<td>').addClass('table-action');
                    var editButton = $('<a>').attr('href', 'javascript:void(0);').addClass('action-icon').click(function () {
                        editData(item); // Pass the entire item object to the editData function
                    }).append($('<i>').addClass('mdi mdi-pencil'));
                    var deleteButton = $('<a>').attr('href', 'javascript:void(0);').addClass('action-icon').click(function () {
                        deleteQuestionData(item); // Pass the entire item object to the deleteQuestionData function
                    }).append($('<i>').addClass('mdi mdi-delete'));
                    actionColumn.append(editButton).append(deleteButton);
                    row.append(actionColumn);

                    innerTable.append(row);
                });

                innerTableRow.html($('<td>').attr('colspan', '10').append(innerTable));
                innerTableRow.show();

                // Add click event for sorting
                // Add click event for sorting
                innerTable.find('th').click(function () {
                    var column = $(this).index();
                    var asc = !$(this).hasClass('asc');
                    sortInnerTable(innerTable, column, asc);

                    // Reset all headers to default state
                    innerTable.find('th').removeClass('asc desc').find('i').removeClass('mdi-arrow-up mdi-arrow-down').addClass('mdi mdi-arrow-up');

                    // Set the current header's sorting icon
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
                var cellA = $(a).children('td').eq(column).text().trim();
                var cellB = $(b).children('td').eq(column).text().trim();

                // Check if the cells contain numeric values
                var isNumeric = !isNaN(cellA) && !isNaN(cellB);

                if (isNumeric) {
                    cellA = parseFloat(cellA);
                    cellB = parseFloat(cellB);
                }

                // Perform comparison
                var comparison = isNumeric ? (cellA - cellB) : cellA.localeCompare(cellB, undefined, { numeric: true });

                return asc ? comparison : -comparison;
            });

            table.append(rows);
        }

        function loadBlocks() {

            $.ajax({
                type: "POST",
                url: "/Pages/Question.aspx/GetBlock",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d); // Parse the JSON string to an object
                    $('#ddlBlock').empty().append('<option value="-1">--Seleziona--</option>');
                    $.each(data, function (index, item) {
                        $('#ddlBlock').append($('<option>', {
                            value: item.blockId,
                            text: item.blockName
                        }));
                    });
                },
                error: function (xhr, status, error) {
                    console.error(xhr.responseText);
                }
            });

        }

        function changeCategory(blockId, catId) {

            setTimeout(function () {
                $.ajax({
                    type: "POST",
                    url: "/Pages/Question.aspx/GetCategories",
                    data: JSON.stringify({ blockId: blockId }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        var data = JSON.parse(response.d);
                        $('#ddlCategory').empty();

                        // Add "select" option at the beginning
                        $('#ddlCategory').append($('<option>', {
                            value: -1,
                            text: '-- Seleziona --'
                        }));

                        $.each(data, function (index, item) {
                            $('#ddlCategory').append($('<option>', {
                                value: item.categoryId,
                                text: item.categoryName
                            }));
                        });

                        // Set the value of ddlCOA after options are populated
                        $('#ddlCategory').val(catId);
                        $('#ddlCategory').trigger('change.select2'); // Refresh dropdown
                    },
                    error: function (xhr, status, error) {
                        console.error(xhr.responseText);
                    }
                });

            }, 500);
        }

        function changeSubCategory(catId, subcatId) {


            setTimeout(function () {
                $.ajax({
                    type: "POST",
                    url: "/Pages/Question.aspx/GetSubCategories",
                    data: JSON.stringify({ catId: catId }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        var data = JSON.parse(response.d);
                        $('#ddlSubCategory').empty();

                        // Add "select" option at the beginning
                        $('#ddlSubCategory').append($('<option>', {
                            value: -1,
                            text: '-- Seleziona --'
                        }));

                        $.each(data, function (index, item) {
                            $('#ddlSubCategory').append($('<option>', {
                                value: item.subCatId,
                                text: item.subCatName
                            }));
                        });

                        // Set the value of ddlCOA after options are populated
                        $('#ddlSubCategory').val(subcatId);
                        $('#ddlSubCategory').trigger('change.select2'); // Refresh dropdown
                    },
                    error: function (xhr, status, error) {
                        console.error(xhr.responseText);
                    }
                });
            }, 500);
        }

        function handleSaveUpdate() {
            var saveButton = $('#saveButton');

            // Check the current text of the button
            if (saveButton.text().trim() === 'Salva') {
                // Call saveData function
                saveData();
            } else {
                // Call updateData function
                updateData();
            }
        }
        // Function to save question data
        function saveData() {


            if (!checkValues()) {
                return;
            }


            // Get values from input controls
            var catId = $('#ddlCategory').val();
            var subCatId = $('#ddlSubCategory').val();
            var questionName = $('#txtQuestion').val();
            var quesType = $('#quesType').val();
            var minValue = $('#txtMinValue').val();
            var maxValue = $('#txtMaxValue').val();
            var unit = $('#txtUnit').val();

            setTimeout(function () {

                // AJAX call to save question data
                $.ajax({
                    type: "POST",
                    url: "/Pages/Question.aspx/SaveQuestionData",
                    data: JSON.stringify({
                        catId: catId,
                        subCatId: subCatId,
                        questionName: questionName,
                        quesType: quesType,
                        minValue: minValue,
                        maxValue: maxValue,
                        unit: unit
                    }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {

                        if (parseInt(response.d) == "0") {
                            showAlert('Errore inserimento dati', 'danger');
                        }
                        if (parseInt(response.d) == "-1") {
                            showAlert('Dati inseriti correttamente', 'success');
                            loadDataQuestions();
                        }
                        else {
                            saveOptions(response.d);

                        }
                    },
                    error: function (xhr, textStatus, errorThrown) {
                        showAlert('Errore inserimento dati', 'danger');
                    },
                    complete: function () {
                        clearData();
                        // Hide spinner button, show save button
                        hideOverlay();
                    }
                });

            }, 1000);

            showOverlay();
        }

        function saveOptions(questionId) {
            var saveButton = $('#saveButton');
            if (saveButton.text().trim() === 'Aggiorna') {
                var optionRowCount = $('#tblMCQSOptions tbody tr').length;
                if (optionRowCount === 0) {
                    showAlert("Dati inseriti correttamente", "success");
                    return false;
                }
            }

            // Create an array to store AJAX promises
            var ajaxPromises = [];

            // Iterate through each row in the table
            $('#tblMCQSOptions tbody tr').each(function () {
                var optionId = $(this).find('td:first-child input[type="hidden"]').val(); // Retrieve optionId from hidden input
                var optionName = "";
                var optionValue = "";
                var optionMsg = "";

                if (optionId === "") {
                    // If optionId is empty, get values from .text()
                    optionName = $(this).find('td:nth-child(3)').text();
                    optionValue = $(this).find('td:nth-child(4)').text();
                    optionMsg = $(this).find('td:nth-child(5)').text();
                } else {
                    // If optionId has a value, get values from .val()
                    optionName = $(this).find('td:nth-child(3) input').val();
                    optionValue = $(this).find('td:nth-child(4) input').val();
                    optionMsg = $(this).find('td:nth-child(5) input').val();
                }
                // Push the AJAX call promise to the array
                ajaxPromises.push(new Promise(function (resolve, reject) {
                    $.ajax({
                        type: "POST",
                        url: "/Pages/Question.aspx/SaveOptionData",
                        data: JSON.stringify({
                            optionId: optionId,
                            optionName: optionName,
                            optionValue: optionValue,
                            questionId: questionId,
                            optionMsg: optionMsg
                        }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (response) {
                            // Check if the option data was saved successfully
                            if (response.d) {
                                resolve('Dati inseriti correttamente');
                            } else {
                                reject('Errore inserimento dati');
                            }
                        },
                        error: function (xhr, textStatus, errorThrown) {
                            reject('Errore inserimento dati');
                        }
                    });
                }));
            });

            // Wait for all AJAX promises to resolve
            Promise.all(ajaxPromises)
                .then(function (successMessages) {
                    // Show success message if all options are saved successfully
                    showAlert('Dati inseriti correttamente', 'success');
                })
                .catch(function (errorMessage) {
                    // Show error message if any option fails to save
                    showAlert(errorMessage, 'danger');
                })
                .finally(function () {
                    // After all options are saved, reload question data
                    loadDataQuestions();
                    // Clear the input fields and hide the spinner button
                    clearData();
                    hideOverlay();
                });
        }




        function editData(item) {
            // Extract data from the item object

            console.log(item);

            var blockId = item.blockId;
            var questionId = item.questionId;
            var catId = item.catId;
            var subCatId = item.subCatId;
            var quesType = item.quesType;


            document.getElementById('txtQuestion').value = item.questionName;
            document.getElementById('hiddenQuestionId').value = item.questionId;
            //document.getElementById('ddlBlock').value = blockId;
            $('#ddlBlock').val(blockId);
            $('#quesType').val(quesType);

            changeCategory(blockId, catId);
            changeSubCategory(catId, subCatId);

            $('#pnlNumberQuesType').hide();
            $('#pnlMCQ').hide();

            if (parseInt(quesType) == 1) {
                $('#pnlNumberQuesType').show();
                document.getElementById('txtMinValue').value = item.minValue;
                document.getElementById('txtMaxValue').value = item.maxValue;
                document.getElementById('txtUnit').value = item.unit;


            } else if (parseInt(quesType) == 2) {
                $('#pnlMCQ').show();

                var questionId = item.questionId;

                $.ajax({
                    url: '/Pages/Question.aspx/GetOptionsData', // Replace with your server-side endpoint URL
                    method: 'POST',
                    data: JSON.stringify({ questionId: questionId }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {

                        try {
                            // Parse the response.d string into a JavaScript object
                            var responseData = JSON.parse(response.d);

                            // Check if responseData is an array
                            if (Array.isArray(responseData)) {
                                // Clear existing option rows
                                $('#tblMCQSOptions tbody').empty();

                                // Populate options in edit mode
                                var serialNumber = 1; // Counter for serial numbers
                                $.each(responseData, function (index, option) {
                                    var optionRow = $('<tr>');
                                    optionRow.append($('<td>').addClass('hidden').append($('<input>').attr('type', 'hidden').val(option.optionId))); // Hidden input for optionId
                                    optionRow.append($('<td>').text(serialNumber++)); // Append serial number
                                    optionRow.append($('<td>').append($('<input>').addClass('form-control').val(option.optionName)));
                                    optionRow.append($('<td>').append($('<input>').addClass('form-control').val(option.optionValue)));
                                    optionRow.append($('<td>').append($('<input>').addClass('form-control').val(option.optionMsg)));

                                    var deleteButton = $('<a>').attr('href', 'javascript:void(0);').addClass('action-icon').click(function () {
                                        deleteOption(option.optionId); // Call the deleteOption method with the optionId
                                    }).append($('<i>').addClass('mdi mdi-delete'));
                                    var actionColumn = $('<td>').addClass('table-action').append(deleteButton);
                                    optionRow.append(actionColumn);

                                    $('#tblMCQSOptions tbody').append(optionRow);
                                });
                            } else {
                                console.error("Invalid or unexpected response format - responseData is not an array:", responseData);
                            }
                        } catch (error) {
                            console.error("Error parsing response:", error);
                        }
                    },
                    error: function (xhr, status, error) {
                        // Handle error
                        console.error(error);
                    }
                });

            }

            // Change the button text to "Update"
            $('#saveButton').text('Aggiorna');

            // Additional logic for editing data...
        }

        function updateData() {
            // Check if the date textbox is empty
            // Check if the date textbox is empty
            if (!checkValues()) {
                return;
            }

            showOverlay();

            // Get values from input controls
            var questionId = document.getElementById('hiddenQuestionId').value;
            var catId = $('#ddlCategory').val();
            var subCatId = $('#ddlSubCategory').val();
            var questionName = $('#txtQuestion').val();
            var quesType = $('#quesType').val();
            var minValue = $('#txtMinValue').val();
            var maxValue = $('#txtMaxValue').val();
            var unit = $('#txtUnit').val();




            setTimeout(function () {
                // Send AJAX POST request to update the record
                $.ajax({
                    type: 'POST',
                    url: '/Pages/Question.aspx/UpdateData', // Replace with your server-side endpoint
                    data: JSON.stringify({
                        questionId: questionId,
                        catId: catId,
                        subCatId: subCatId,
                        questionName: questionName,
                        quesType: quesType,
                        minValue: minValue,
                        maxValue: maxValue,
                        unit: unit
                    }),
                    contentType: 'application/json',
                    success: function (response) {

                        if (parseInt(response.d) == "0") {
                            showAlert('Errore durante aggiornamento', 'danger');
                        }
                        if (parseInt(response.d) == "-1") {
                            showAlert('Dati inseriti correttamente', 'update');
                        }
                        else {
                            saveOptions(response.d);
                        }
                    },
                    error: function (xhr, textStatus, errorThrown) {
                        showAlert('Errore durante aggiornamento', 'danger');
                    },
                    complete: function () {
                        $('#saveButton').text('Salva');
                        clearData();
                        loadDataQuestions();
                        hideOverlay();
                    }
                });
            }, 500);
        }

        function deleteQuestionData(item) {

            showOverlay();

            var questionId = item.questionId;

            var data = {
                questionId: questionId
            };

            $.ajax({
                type: 'POST',
                url: '/Pages/Question.aspx/DeleteQuestionData', // Replace with your server-side endpoint
                data: JSON.stringify(data),
                contentType: 'application/json',
                success: function (response) {
                    if (response.d === "success") {
                        clearData();
                        showAlert('Cancellazione eseguita', 'delete');
                        loadDataQuestions();
                    } else {
                        showAlert('Errore durante cancellazione', 'danger');
                    }
                },
                error: function (xhr, textStatus, errorThrown) {
                    showAlert('Errore durante cancellazione', 'danger');
                },
                complete: function () {
                    // Hide spinner button, show save button
                    hideOverlay();
                }
            });

        }

        function deleteOption(optionId) {

            showOverlay();

            var optionId = optionId;


            var data = {
                optionId: optionId
            };

            $.ajax({
                type: 'POST',
                url: '/Pages/Question.aspx/DeleteOptionData', // Replace with your server-side endpoint
                data: JSON.stringify(data),
                contentType: 'application/json',
                success: function (response) {
                    if (response.d === "success") {
                        clearData();
                        showAlert('Cancellazione eseguita', 'delete');
                        loadDataQuestions();
                    } else {
                        showAlert('Errore durante cancellazione', 'danger');
                    }
                },
                error: function (xhr, textStatus, errorThrown) {
                    showAlert('Errore durante cancellazione', 'danger');
                },
                complete: function () {
                    // Hide spinner button, show save button
                    hideOverlay();
                }
            });

        }

        function checkValues() {
            var ddlBlockElement = document.getElementById("ddlBlock");
            var ddlBlock = ddlBlockElement ? ddlBlockElement.value : "";
            if (ddlBlock === "-1") {
                showAlert("Seleziona blocco", "danger");
                return false;
            }

            var ddlCategoryElement = document.getElementById("ddlCategory");
            var ddlCategory = ddlCategoryElement ? ddlCategoryElement.value : "";
            if (ddlCategory === "-1") {
                showAlert("Seleziona categoria", "danger");
                return false;
            }

            var ddlSubCategoryElement = document.getElementById("ddlSubCategory");
            var ddlSubCategory = ddlSubCategoryElement ? ddlSubCategoryElement.value : "";
            if (ddlSubCategory === "-1") {
                showAlert("Seleziona Sottocategoria", "danger");
                return false;
            }

            var txtQuestionElement = document.getElementById("txtQuestion");
            var txtQuestion = txtQuestionElement ? txtQuestionElement.value.trim() : "";
            if (txtQuestion === "") {
                showAlert("Inserire nome domanda", "danger");
                return false;
            }

            var quesTypeElement = document.getElementById("quesType");
            var quesType = quesTypeElement ? quesTypeElement.value : "";
            if (quesType === "-1") {
                showAlert("Selezionare tipo domanda", "danger");
                return false;
            }

            if (quesType === "1") {
                var txtMinValueElement = document.getElementById("txtMinValue");
                var txtMinValue = txtMinValueElement ? txtMinValueElement.value.trim() : "";
                if (txtMinValue === "") {
                    showAlert("Inserire valore min", "danger");
                    return false;
                }

                var txtMaxValueElement = document.getElementById("txtMaxValue");
                var txtMaxValue = txtMaxValueElement ? txtMaxValueElement.value.trim() : "";
                if (txtMaxValue === "") {
                    showAlert("Inserire valore max", "danger");
                    return false;
                }

                var txtUnitElement = document.getElementById("txtUnit");
                var txtUnit = txtUnitElement ? txtUnitElement.value.trim() : "";
                if (txtUnit === "") {
                    showAlert("Inserire unita misura", "danger");
                    return false;
                }
            }

            if (quesType === "2") {
                var saveButton = $('#saveButton');
                if (saveButton.text().trim() === 'Save') {
                    var optionRowCount = $('#tblMCQSOptions tbody tr').length;
                    if (optionRowCount === 0) {
                        showAlert("Inserire almeno una risposta", "danger");
                        return false;
                    }
                }
            }

            return true;
        }

        function toggleExcludeFromDynamicQuestion(questionId, checkbox) {
            var isExclude = checkbox.checked ? 1 : 0;

            console.log(isExclude);
            console.log(questionId);


            $.ajax({
                type: "POST",
                url: "/Pages/Question.aspx/UpdateExcludeFromDynamicQuestion",
                data: JSON.stringify({ questionId: questionId, isExcludeFromDynamicQuestion: isExclude }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d == 1) {
                        console.log("Update successful");
                    } else {
                        console.error("Update failed");
                    }
                },
                error: function (xhr, status, error) {
                    console.error(xhr.responseText);
                }
            });
        }

        function clearData() {

            $('#txtQuestion').val("");
            $('hiddenQuestionId').val("");
            $('#ddlBlock').val("-1");
            $('#ddlCategory').val('');
            $('#ddlCategory').empty();

            $('#ddlSubCategory').val('');
            $('#ddlSubCategory').empty();

            $('#quesType').val('');
            $('#txtMinValue').val('');
            $('#txtMaxValue').val('');
            $('#txtUnit').val('');
            $('#txtOption').val('');
            $('#txtScore').val('');
            $('#txtOptionMessage').val('');

            $('#tblMCQSOptions tbody').empty();

        }

        function isValidDecimalInput(input) {
            return /^\d*\.?\d*$/.test(input);
        }

        // Attach event listeners to the input fields
        document.getElementById("txtMinValue").addEventListener("input", function () {
            var value = this.value.trim();
            if (!isValidDecimalInput(value)) {
                this.value = value.slice(0, -1); // Remove the last character if it's non-numeric
            }
        });

        document.getElementById("txtMaxValue").addEventListener("input", function () {
            var value = this.value.trim();
            if (!isValidDecimalInput(value)) {
                this.value = value.slice(0, -1); // Remove the last character if it's non-numeric
            }
        });

        document.getElementById("txtScore").addEventListener("input", function () {
            var value = this.value.trim();
            if (!isValidDecimalInput(value)) {
                this.value = value.slice(0, -1); // Remove the last character if it's non-numeric
            }
        });

        document.getElementById("downloadButton").addEventListener("click", function () {

            downloadQuestions();
        });


    </script>
</asp:Content>
