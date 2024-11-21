<%@ Page Title="" Language="C#" MasterPageFile="~/Template/ValuMasterNew.Master" AutoEventWireup="true" CodeBehind="WebForm2.aspx.cs" Inherits="VALUQuest.WebForm2" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
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

        .inner-category-row td {
            padding-left: 20px;
            background-color: #FFFFE0 !important;
            font-weight: 600 !important;
        }

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
            background-color: #d3f4ff !important;
            font-weight: bold !important;
        }

        .inner-table {
            border: 1px solid #ccc;
            width: 100%;
        }

        .inner-table th,
        .inner-table td {
            border: 1px solid #ccc;
            padding: 8px;
            text-align: left;
        }

        .wrap-text {
            white-space: normal;
        }
    </style>

    <div class="container mt-4">
        <input type="text" id="searchInput" class="form-control mb-3" placeholder="Search...">
        <table id="tblQuestions" class="table table-bordered">
            <thead>
                <tr>
                    <th></th>
                    <th>Block Name</th>
                </tr>
            </thead>
            <tbody></tbody>
        </table>
    </div>
    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        $(document).ready(function () {
            loadDataQuestions();

            $('#searchInput').on('input', function () {
                searchAndExpand();
            });
        });

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
                        var row = $('<tr>').addClass('block-row');

                        var actionColumn = $('<td>').addClass('table-action');
                        var expandButton = $('<a>').attr('href', 'javascript:void(0);').addClass('action-icon expand').click(function () {
                            toggleBlockDetails(blockName, $(this));
                        }).append($('<i>').addClass('mdi mdi-plus'));
                        actionColumn.append(expandButton);

                        row.append(actionColumn);
                        row.append($('<td>').text(blockName));

                        $('#tblQuestions tbody').append(row);
                    })(blockName);
                }
            }
        }

        function toggleBlockDetails(blockName, buttonElement, isSearchFilter = false) {
            var isExpanded = buttonElement.find('i').hasClass('mdi-minus');

            if (isExpanded) {
                buttonElement.find('i').removeClass('mdi-minus').addClass('mdi-plus');
                buttonElement.removeClass('collapse').addClass('expand');
                buttonElement.closest('tr').nextUntil('tr.block-row').remove();
            } else {
                var innerTableExists = buttonElement.closest('tr').next().hasClass('inner-category-row') && buttonElement.closest('tr').next().attr('data-block') === blockName;

                if (!innerTableExists || isSearchFilter) {
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
                            (function (categoryName) {
                                var categoryRow = $('<tr>').addClass('inner-category-row').attr('data-block', blockName);

                                var actionColumn = $('<td>').addClass('table-action');
                                var expandButton = $('<a>').attr('href', 'javascript:void(0);').addClass('action-icon expand').click(function () {
                                    toggleCategoryDetails(blockName, categoryName, $(this));
                                }).append($('<i>').addClass('mdi mdi-plus'));
                                actionColumn.append(expandButton);

                                categoryRow.append(actionColumn);
                                categoryRow.append($('<td>').text(categoryName).attr('colspan', '2'));

                                var currentRow = buttonElement.closest('tr');
                                currentRow.after(categoryRow);
                            })(categoryName);
                        }
                    }

                    buttonElement.find('i').removeClass('mdi-plus').addClass('mdi-minus');
                    buttonElement.removeClass('expand').addClass('collapse');
                } else {
                    buttonElement.find('i').removeClass('mdi-plus').addClass('mdi-minus');
                    buttonElement.removeClass('expand').addClass('collapse');
                    buttonElement.closest('tr').next('.inner-category-row[data-block="' + blockName + '"]').show();
                }
            }
        }

        function toggleCategoryDetails(blockName, categoryName, buttonElement, isSearchFilter = false) {
            var isExpanded = buttonElement.find('i').hasClass('mdi-minus');

            if (isExpanded) {
                buttonElement.find('i').removeClass('mdi-minus').addClass('mdi-plus');
                buttonElement.removeClass('collapse').addClass('expand');
                buttonElement.closest('tr').nextUntil('tr.inner-category-row').remove();
            } else {
                var innerTableExists = buttonElement.closest('tr').next().hasClass('inner-table-row') && buttonElement.closest('tr').next().attr('data-category') === categoryName;

                if (!innerTableExists || isSearchFilter) {
                    var filteredData = originalData.filter(item => item.blockName === blockName && item.categoryName === categoryName);

                    var innerTable = $('<table>').addClass('table table-sm table-centered nowrap mb-0 inner-table');
                    var headerRow = $('<tr>');
                    headerRow.append('<th>Sottocategoria</th>');
                    headerRow.append('<th>Domanda</th>');
                    headerRow.append('<th>Tipo</th>');
                    headerRow.append('<th>Valore min</th>');
                    headerRow.append('<th>Valore max</th>');
                    headerRow.append('<th>Unità</th>');
                    headerRow.append('<th>Descrizione risposta</th>');
                    headerRow.append('<th>Escludi da "domande casuali"</th>');
                    headerRow.append('<th>Azione</th>');
                    innerTable.append(headerRow);

                    filteredData.forEach(function (item) {
                        var row = $('<tr>').addClass('inner-table-row').attr('data-category', categoryName);

                        row.append($('<td>').text(item.subCatName));
                        var questionNameCell = $('<td>').addClass('textQuestionName wrap-text').text(item.questionName);
                        row.append(questionNameCell);
                        row.append($('<td>').text(item.type));
                        row.append($('<td>').text(item.minValue));
                        row.append($('<td>').text(item.maxValue));
                        row.append($('<td>').text(item.unit));
                        row.append($('<td>').text(item.responseDescription));
                        row.append($('<td>').html('<label class="switch"><input type="checkbox" ' + (item.excludeFromRandom ? 'checked' : '') + '><span class="slider round"></span></label>'));

                        var actionColumn = $('<td>').addClass('table-action');
                        var editButton = $('<a>').attr('href', 'javascript:void(0);').addClass('action-icon').click(function () {
                            editData(item);
                        }).append($('<i>').addClass('mdi mdi-pencil'));
                        var deleteButton = $('<a>').attr('href', 'javascript:void(0);').addClass('action-icon').click(function () {
                            deleteQuestionData(item);
                        }).append($('<i>').addClass('mdi mdi-delete'));
                        actionColumn.append(editButton).append(deleteButton);
                        row.append(actionColumn);

                        innerTable.append(row);
                    });

                    var innerRow = $('<tr>').addClass('inner-table-row').attr('data-category', categoryName).append($('<td>').attr('colspan', '10').append(innerTable));
                    buttonElement.closest('tr').after(innerRow);

                    buttonElement.find('i').removeClass('mdi-plus').addClass('mdi-minus');
                    buttonElement.removeClass('expand').addClass('collapse');
                } else {
                    buttonElement.find('i').removeClass('mdi-plus').addClass('mdi-minus');
                    buttonElement.removeClass('expand').addClass('collapse');
                    buttonElement.closest('tr').next('.inner-table-row[data-category="' + categoryName + '"]').show();
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
                    (function (blockName) {
                        var row = $('<tr>').addClass('block-row');

                        var actionColumn = $('<td>').addClass('table-action');
                        var expandButton = $('<a>').attr('href', 'javascript:void(0);').addClass('action-icon expand').click(function () {
                            toggleBlockDetails(blockName, $(this), true);
                        }).append($('<i>').addClass('mdi mdi-plus'));
                        actionColumn.append(expandButton);

                        row.append(actionColumn);
                        row.append($('<td>').text(blockName));

                        $('#tblQuestions tbody').append(row);

                        for (var categoryName in groupedData[blockName]) {
                            if (groupedData[blockName].hasOwnProperty(categoryName)) {
                                (function (categoryName) {
                                    var categoryRow = $('<tr>').addClass('inner-category-row').attr('data-block', blockName);

                                    var actionColumn = $('<td>').addClass('table-action');
                                    var expandButton = $('<a>').attr('href', 'javascript:void(0);').addClass('action-icon expand').click(function () {
                                        toggleCategoryDetails(blockName, categoryName, $(this), true);
                                    }).append($('<i>').addClass('mdi mdi-plus'));
                                    actionColumn.append(expandButton);

                                    categoryRow.append(actionColumn);
                                    categoryRow.append($('<td>').text(categoryName).attr('colspan', '2'));

                                    row.after(categoryRow);
                                    row = categoryRow;
                                })(categoryName);
                            }
                        }
                    })(blockName);
                }
            }
        }
    </script>
</asp:Content>
