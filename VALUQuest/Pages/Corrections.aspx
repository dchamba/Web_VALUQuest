<%@ Page Title="" Language="C#" MasterPageFile="~/Template/ValuMaster.Master" AutoEventWireup="true" CodeBehind="Corrections.aspx.cs" Inherits="VALUQuest.Pages.Corrections" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <style>
        .switch {
            position: relative;
            display: inline-block;
            width: 40px; /* Reduced width */
            height: 20px; /* Reduced height */
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
            -webkit-transition: .4s;
            transition: .4s;
            border-radius: 20px; /* To maintain rounded edges */
        }

            .slider:before {
                position: absolute;
                content: "";
                height: 16px; /* Reduced height */
                width: 16px; /* Reduced width */
                left: 2px;
                bottom: 2px;
                background-color: white;
                -webkit-transition: .4s;
                transition: .4s;
                border-radius: 50%;
            }

        input:checked + .slider {
            background-color: #2196F3;
        }

        input:focus + .slider {
            box-shadow: 0 0 1px #2196F3;
        }

        input:checked + .slider:before {
            -webkit-transform: translateX(20px); /* Adjust for smaller size */
            -ms-transform: translateX(20px);
            transform: translateX(20px);
        }
    </style>
    <div class="row">
        <div class="col-12">
            <div class="page-title-box">
                <h4 class="page-title" id="pageTitle" runat="server">Add Correction</h4>
            </div>
        </div>

        <div id="msgAlert"></div>
        <input type="hidden" id="hiddenBlockId">
        <input type="hidden" id="txtId" runat="server" clientidmode="Static" />
        <!-- Main Form Row -->
        <div class="row">
            <!-- Left Side: Correction Details -->
            <div class="col-md-6">
                <div class="card">
                    <div class="card-body">
                        <div class="row mb-3">
                            <div class="col-md-12">
                                <label for="correctionName">Nome Correzione:</label>
                                 <span class="text-danger">*</span>
                                <input type="text" id="correctionName" class="form-control" placeholder="Enter Correction Name..." />
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-md-12">
                                <label for="message">Massaggio da mostrare in report finale:</label>
                                <textarea id="message" class="form-control" placeholder="Enter Correction Message..."></textarea>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-md-12">
                                <label for="notes">Note:</label>
                                <textarea id="notes" class="form-control" placeholder="Enter Note..."></textarea>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-md-12">
                                <label for="notes">Fattore di correzione della media globale</label>
                                 <span class="text-danger">*</span>
                                <input type="text" id="valueToAdd" class="form-control form-control-sm " oninput="validateNumber(this)" placeholder="Enter Value to add..." />
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-md-6">
                <div class="card">
                    <div class="card-body">
                        <div class="row mb-3">
                            <div class="col-md-12">
                                <input type="hidden" id="rowNo" />
                                <label for="conditionType">Tipo condizione: </label>
                                <span class="text-danger">*</span>
                                <select id="conditionType" class="form-select form-select-sm conditionType">
                                    <option value="-1">--- Seleziona il tipo di condizione ---</option>
                                    <option value="Block">Block</option>
                                    <option value="Global Value">Global Value</option>
                                    <option value="BMI Value">BMI Value</option>
                                </select>
                            </div>
                        </div>
                        <div class="row mb-3 blockConditionGroup">
                            <div class="col-md-12">
                                <label for="blockCondition">Blocco: </label>
                                <select id="blockCondition" class="form-select form-select-sm blockCondition"></select>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="operator">Operatore:</label><span class="text-danger"> *</span>
                                <select id="operator" class="form-select form-select-sm operator">
                                    <option value="-1">--- Seleziona operatore ---</option>
                                    <option value="=">=</option>
                                    <option value="!=">!=</option>
                                    <option value=">">></option>
                                    <option value="<"><</option>
                                    <option value=">=">>=</option>
                                    <option value="<="><=</option>
                                    <option value="between">Between</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label for="conditionValue1">Parametro 1:</label>
                                 <span class="text-danger">*</span>
                                <input type="text" id="conditionValue1" class="form-control form-control-sm conditionValue1" oninput="validateNumber(this)" placeholder="Enter Value One..." />
                            </div>
                        </div>
                        <div class="row mb-3 conditionValue2Group" style="display: none;">
                            <div class="col-md-12">
                                <label for="conditionValue2">Parametro 2:</label>
                                 <span class="text-danger">*</span>
                                <input type="text" id="conditionValue2" class="form-control conditionValue2" oninput="validateNumber(this)" placeholder="Enter Value Two..." />
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-md-12">
                                <label for="conjunction">And/Or/None:</label><span class="text-danger"> *</span>
                                <select id="conjunction" class="form-select form-select-sm conjunction">
                                    <option value="-1">--- Seleziona congiunzione ---</option>

                                    <option value="AND">And</option>
                                    <option value="OR">Or</option>
                                    <option value="None">None</option>
                                </select>
                            </div>
                        </div>
                        <div class="row text-center">
                            <div class="col-md-12">
                                <button type="button" id="addCondition" class="btn btn-secondary">Aggiungi condizione</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Conditions Table -->
        <div class="row mb-3">
            <div class="col-md-12">
                <div class="card">
                    <div class="card-body">
                        <table class="table table-sm table-centered mb-0" id="conditionsTable">
                            <thead>
                                <tr>
                                    <th>Tipo condizione</th>
                                    <th>Blocco</th>
                                    <th>Operatore</th>
                                    <th>Parametro 1</th>
                                    <th>Parametro 2</th>
                                    <th>And/Or/None</th>
                                    <th class="text-center">Attivo | Modifica | Elimina</th>
                                </tr>
                            </thead>
                            <tbody>
                                <!-- Dynamic conditions will be added here -->
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <!-- Save Button -->
        <div class="row mb-3">
            <div class="col-md-3">
                <button type="button" id="saveCorrection" class="btn btn-primary">Salva</button>
            </div>
        </div>
    </div>
    <script type="text/javascript">

        function validateNumber(input) {
            // Allow numbers, a single decimal point, and a minus sign
            input.value = input.value.replace(/[^0-9.-]/g, ''); // Remove anything that's not a digit, dot, or minus sign

            // Ensure only one decimal point is allowed
            if ((input.value.match(/\./g) || []).length > 1) {
                input.value = input.value.substring(0, input.value.length - 1); // Allow only one dot
            }

            // Ensure the minus sign is at the beginning (if present)
            if (input.value.indexOf('-') > 0) {
                input.value = input.value.replace('-', ''); // Remove the minus sign if it's not at the beginning
            }

            // Ensure only one minus sign is allowed
            if ((input.value.match(/-/g) || []).length > 1) {
                input.value = input.value.replace(/-+$/, ''); // Remove additional minus signs
            }
        }

        // The same JavaScript code you provided earlier
        $(document).ready(function () {



            function getUrlParameter(name) {
                const urlParams = new URLSearchParams(window.location.search);
                return urlParams.has(name) ? urlParams.get(name) : null;
            }

            // Check if the 'ID' parameter exists in the URL
            const idParam = getUrlParameter("ID");

            if (idParam) {
                // If ID exists, show the saveCorrection button
                $('#saveCorrection').show();
            } else {
                // If no ID, hide the saveCorrection button initially
                $('#saveCorrection').hide();
            }

            //Edit corrrection code started...
            var correctionId = $("#txtId").val();
            if (correctionId) {
                // Make AJAX call to get data
                $.ajax({
                    url: 'Corrections.aspx/getCorrectionsById',
                    type: 'POST',
                    contentType: 'application/json; charset=utf-8',
                    data: JSON.stringify({
                        _corretionId: correctionId
                    }),
                    dataType: 'json',
                    success: function (response) {
                        console.info(response);
                        debugger;
                        $('#correctionName').val(response.d.masterData.correctionName);
                        $('#message').val(response.d.masterData.message);
                        $('#notes').val(response.d.masterData.notes);
                        $('#valueToAdd').val(response.d.masterData.valueToAdd);
                        $('#conditionsTable tbody').empty();
                        response.d.conditions.forEach(function (condition) {
                            var newRow = `
                            <tr>
                                <td>${condition.conditionType}</td>
                                <td>${condition.block}</td>
                                <td class="d-none">${condition.blockId}</td>
                                <td>${condition.operators}</td>
                                <td>${condition.conditionValue1}</td>
                                <td>${condition.conditionValue2 ? condition.conditionValue2 : '-'}</td>
                                <td>${condition.conjunction}</td>
                                <td class="text-center">
                                    <label class="switch">
                                        <input type="checkbox" class="toggle-active" data-id="${condition.conditionId}" ${condition.conditionActive ? 'checked' : ''}>
                                        <span class="slider"></span>
                                    </label>
                                    <button type="button" class="btn btn-info btn-sm editCondition" data-id="${condition.conditionId}" ><i class="fa fa-edit" aria-hidden="true"></i></button>
                                    <button type="button" class="btn btn-danger btn-sm removeCondition" title="Delete" ><i class="fa fa-trash" aria-hidden="true"></i></button>
                                </td>
                            </tr>`;
                            $('#conditionsTable tbody').append(newRow);
                        });
                    },
                    error: function (xhr, status, error) {
                        console.error("Error updating correction ID " + correctionId + ": " + xhr.responseText);
                    }
                });
            }
            // Function to populate fields
            $(document).on('click', '.removeCondition', function () {
                $(this).closest('tr').remove();
            });
            // Function to populate fields for editing
            $(document).on('click', '.editCondition', function () {
                var currentRow = $(this).closest('tr');
                var rowNo = currentRow.index();
                var conditionType = currentRow.find('td:eq(0)').text();
                var block = currentRow.find('td:eq(1)').text();
                var blockId = currentRow.find('td:eq(2)').text(); // Assuming blockId is in the third column
                var operator = currentRow.find('td:eq(3)').text();
                var conditionValue1 = currentRow.find('td:eq(4)').text();
                var conditionValue2 = currentRow.find('td:eq(5)').text() !== '-' ? currentRow.find('td:eq(5)').text() : '';
                var conjunction = currentRow.find('td:eq(6)').text();
                $('#rowNo').val(rowNo);
                $('#conditionType').val(conditionType);
                $('#blockCondition').val(blockId); // Ensure block options are populated before setting
                $('#operator').val(operator);
                $('#conditionValue1').val(conditionValue1);
                $('#conditionValue2').val(conditionValue2);
                $('#conjunction').val(conjunction);
                if (blockId === '0') {
                    $('.blockConditionGroup').hide(); // Hide if blockId is 0
                } else {
                    $('.blockConditionGroup').show(); // Show if blockId is not 0
                }
                if (operator === 'between' && conditionValue2) {
                    $('.conditionValue2Group').show(); // Show if operator is 'between' and conditionValue2 has a value
                } else {
                    $('.conditionValue2Group').hide(); // Hide otherwise
                }
            });

            //Edit corrrection code ended...

            loadBlocks();
            $('#addCondition').on('click', function () {
                addConditionToTable();
            });

            $('#saveCorrection').on('click', function () {
                saveCorrection();
            });

            $(document).on('change', '.conditionType', function () {
                toggleConditionFields($(this));
            });

            $(document).on('change', '.operator', function () {
                toggleBetweenFields($(this));
            });

            $(document).on('click', '.removeCondition', function () {
                $(this).closest('tr').remove();
            });
        });
        //Edit corrrection code started...
        //Edit corrrection code ended...
        function loadBlocks() {
            $.ajax({
                type: "POST",
                url: "/Pages/Corrections.aspx/GetBlock",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d);
                    $('.blockCondition').empty().append('<option value="-1">--Select--</option>');
                    $.each(data, function (index, item) {
                        $('.blockCondition').append($('<option>', {
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


        function addConditionToTable1() {
            debugger
            var rowNo = $('#rowNo').val(); // Get the row number from the hidden input
            var conditionType = $('.conditionType').val();
            var blockId = conditionType === 'Block' ? $('.blockCondition').val() : '';
            var blockText = conditionType === 'Block' ? $('.blockCondition option:selected').text() : '-';
            var operator = $('.operator').val();
            var value1 = $('.conditionValue1').val();
            var value2 = $('.conditionValue2').val();
            var conjunction = $('.conjunction').val();
            if (conditionType == "-1" || operator == "-1" || conjunction == "-1") {
                alert("please select all mandatory fields....")
                return;
            }
            var newRowContent = `
                <td>${conditionType}</td>
                <td>${blockText}</td>
                <td style="display:none;">${blockId}</td>
                <td>${operator}</td>
                <td>${value1}</td>
                <td>${operator === 'between' ? value2 : '-'}</td>
                <td>${conjunction}</td><td class="text-center">`
            if (rowNo) {
                newRowContent += `
                <label class="switch">
                    <input type="checkbox" class="toggle-active" data-id="${blockId}" checked>
                    <span class="slider"></span>
                </label>
            `;
            }
            newRowContent += `
                    <button type="button" class="btn btn-info btn-sm editCondition" title="Edit"><i class="fa fa-edit" aria-hidden="true"></i></button>
                    <button type="button" class="btn btn-danger btn-sm removeCondition" title="Delete"><i class="fa fa-trash" aria-hidden="true"></i></button>
                </td>
                
            `;

            if (rowNo) {
                // Update existing row if rowNo is provided
                var currentRow = $('#conditionsTable tbody tr').eq(rowNo); // Row numbers are 1-based
                currentRow.html(newRowContent); // Replace the current row content
                alert("Record Updated Successfully...");
            } else {
                // Add new row if rowNo is empty
                var newRow = `<tr>${newRowContent}</tr>`;
                $('#conditionsTable tbody').append(newRow);
            }



            // Clear the rowNo input after adding/updating
            $('#rowNo').val('');
        }
        function addConditionToTable() {
            debugger
            // Get the values from the form
            var rowNo = $('#rowNo').val();
            var conditionType = $('.conditionType').val();
            var blockId = conditionType === 'Block' ? $('.blockCondition').val() : '';
            var blockText = conditionType === 'Block' ? $('.blockCondition option:selected').text() : '-';
            var operator = $('.operator').val();
            var value1 = $('.conditionValue1').val();
            var value2 = $('.conditionValue2').val();
            var conjunction = $('.conjunction').val();

            // Validate required fields
            var errors = [];

            if (conditionType === "-1") {
                errors.push("Seleziona un tipo di condizione valido.");
            }
            if (conditionType === "Block") {
                if (blockId === null || blockId === "-1") {
                    errors.push("Seleziona un blocco valido");
                }
            }
            if (operator === "-1") {
                errors.push("Seleziona un operatore valido.");
            }
            if (value1 === "") {
                errors.push("Il valore 1 è obbligatorio.");
            }
            if (operator === "between" && value2 === "") {
                errors.push("Il valore 2 è obbligatorio quando l'operatore è 'between'.");
            }
            if (conjunction === "-1") {
                errors.push("Seleziona una congiunzione valida.");
            }

            // If there are any errors, display them and return early
            if (errors.length > 0) {
                alert(errors.join("\n"));
                return;
            }

            // Prepare the new row content
            var newRowContent = `
        <td>${conditionType}</td>
        <td>${blockText}</td>
        <td style="display:none;">${blockId}</td>
        <td>${operator}</td>
        <td>${value1}</td>
        <td>${operator === 'between' ? value2 : '-'}</td>
        <td>${conjunction}</td>
        <td class="text-center">`;

            // If updating an existing row
            if (rowNo) {
                newRowContent += `
        <label class="switch">
            <input type="checkbox" class="toggle-active" data-id="${blockId}" checked>
            <span class="slider"></span>
        </label>`;
            }

            newRowContent += `
            <button type="button" class="btn btn-info btn-sm editCondition" title="Edit"><i class="fa fa-edit" aria-hidden="true"></i></button>
            <button type="button" class="btn btn-danger btn-sm removeCondition" title="Delete"><i class="fa fa-trash" aria-hidden="true"></i></button>
        </td>`;

            if (rowNo) {
                // Update the existing row if rowNo is provided
                var currentRow = $('#conditionsTable tbody tr').eq(rowNo); // Row numbers are 1-based
                currentRow.html(newRowContent); // Replace the current row content
            } else {
                // Add a new row if rowNo is empty
                var newRow = `<tr>${newRowContent}</tr>`;
                $('#conditionsTable tbody').append(newRow);
            }

            // Clear the form after adding/updating
            $('#rowNo').val('');
            $('.conditionType').val('-1');
            $('#blockCondition').val('-1');
            $('.operator').val('-1');
            $('.conditionValue1').val('');
            $('.conditionValue2').val('');
            $('.conjunction').val('-1');


            $('#saveCorrection').show();
        }

        function toggleConditionFields(selector) {
            var selectedType = selector.val();
            if (selectedType === "Block") {
                $('.blockConditionGroup').show();
            } else {
                $('.blockConditionGroup').hide();
            }
        }

        function toggleBetweenFields(selector) {
            var selectedOperator = selector.val();
            if (selectedOperator === "between") {
                $('.conditionValue2Group').show();
            } else {
                $('.conditionValue2Group').hide();
            }
        }

        function saveCorrection() {

             debugger

            var correctionId = $('#txtId').val();
            var correctionName = $('#correctionName').val();
            var message = $('#message').val();
            var notes = $('#notes').val();
            var valueToAdd = $('#valueToAdd').val();

             var errors = [];
             if (correctionName === "") {
                errors.push("Inserisci la correzione del nome");
            }
             if (valueToAdd === "") {
                errors.push("per favore inserisci Fattore di correzione della media globale");
            }
             // If there are any errors, display them and return early
            if (errors.length > 0) {
                alert(errors.join("\n"));
                return;
            }

            var conditions = [];
            $('#conditionsTable tbody tr').each(function () {
                var condition = {
                    conditionType: $(this).find('td:eq(0)').text(),
                    blockText: $(this).find('td:eq(1)').text(),
                    blockId: $(this).find('td:eq(2)').text(),
                    operators: $(this).find('td:eq(3)').text(),
                    conditionValue1: $(this).find('td:eq(4)').text(),
                    conditionValue2: $(this).find('td:eq(5)').text(),
                    conjunction: $(this).find('td:eq(6)').text()
                };
                conditions.push(condition);
            });

            $.ajax({
                type: "POST",
                url: "/Pages/Corrections.aspx/SaveCorrection",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    correctionId: correctionId,
                    correctionName: correctionName,
                    message: message,
                    notes: notes,
                    valueToAdd: valueToAdd,
                    conditions: conditions
                }),
                success: function (response) {
                    if (response.d === "Success") {
                        if (correctionId) {
                            $('#txtId').val('');
                            window.location.href = `CorrectionsList.aspx`;
                        }
                        $('#msgAlert').html('<div class="alert alert-success alert-dismissible fade show" role="alert">' +
                            'Correction saved successfully.' +
                            '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>' +
                            '</div>');

                        setTimeout(function () {
                            $('#msgAlert').html('');
                            $('#conditionsTable tbody').empty();
                            $('#correctionName').val('');
                            $('#message').val('');
                            $('#notes').val('');
                            $('#valueToAdd').val('');
                        }, 3000);
                    } else {
                        $('#msgAlert').html('<div class="alert alert-danger alert-dismissible fade show" role="alert">' +
                            'Error: ' + response.d +
                            '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>' +
                            '</div>');
                    }
                },
                error: function (xhr, status, error) {
                    $('#msgAlert').html('<div class="alert alert-danger alert-dismissible fade show" role="alert">' +
                        'An error occurred: ' + xhr.responseText +
                        '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>' +
                        '</div>');
                }
            });
        }

        function updateConditionStatus(conditionId, isActive, isDelete) {
            $.ajax({
                url: 'Corrections.aspx/UpdateCorrectionStatus', // URL to the server-side method
                type: 'POST', // Method of request
                contentType: 'application/json; charset=utf-8', // Content type for the request
                data: JSON.stringify({
                    conditionId: conditionId,
                    isActive: isActive,
                    isDelete: isDelete
                }),
                dataType: 'json', // Expecting a JSON response
                success: function (response) {
                    // Hide the loading image once the response is received
                    $('#loading-image').hide();
                    // Check the response from the server
                    if (response.d) {
                        alert("Status successfully changed...");

                    } else {
                        // If the server indicates failure, alert the user and revert the checkbox
                        alert("Status not changed...");
                        checkbox.prop('checked', !isActive); // Revert the checkbox to its previous state
                    }
                },
                error: function (xhr, status, error) {
                    // Hide the loading image in case of an error
                    $('#loading-image').hide();

                    // Log the error for debugging purposes
                    console.error("Error updating correction ID " + conditionId + ": " + xhr.responseText);

                    // Revert the checkbox in case of an error
                    checkbox.prop('checked', !isActive);
                }
            });
        }
        $('#conditionsTable tbody').on('change', 'input[type="checkbox"]', function () {
            const checkbox = $(this); // Store the reference to the current checkbox
            const conditionId = checkbox.data('id'); // Get the ID of the record from data attribute
            const isActive = checkbox.is(':checked'); // Get the current checked status (true/false)
            const confirmationMessage = isActive
                ? "Are you sure you want to activate this condition?"
                : "Are you sure you want to deactivate this condition?";

            if (confirm(confirmationMessage)) {
                // If the user confirms, show the loading image and proceed with the AJAX request
                $('#loading-image').show();
                updateConditionStatus(conditionId, isActive, false);
            } else {
                // If the user cancels, revert the checkbox to its previous state
                checkbox.prop('checked', !isActive);
            }
        });


    </script>
</asp:Content>
