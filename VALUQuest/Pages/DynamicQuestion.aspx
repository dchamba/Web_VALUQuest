<%@ Page Title="" Language="C#" MasterPageFile="~/Template/ValuMaster.Master" AutoEventWireup="true" CodeBehind="DynamicQuestion.aspx.cs" Inherits="VALUQuest.Pages.DynamicQuestion" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <div class="row">
        <div class="col-12">
            <div class="page-title-box">
                <h4 class="page-title">Domande casuali</h4>
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
                            <label class="form-label">Tipo</label>
                            <select id="ddlQuesFrom" class="form-select form-select-sm mb-3">
                                <option value="-1">Seleziona</option>
                                <option value="1">Categoria</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Dato</label>
                            <select id="ddlColumnData" class="form-select form-select-sm mb-3">
                            </select>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label">Totale domande</label>
                            <input type="text" class="form-control" id="txtTotalQuestion" value="" disabled />
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Qtà domande da visualizzare</label>
                            <input type="text" class="form-control" id="txtCount" value="" disabled />
                        </div>



                    </div>

                    <div class="row">
                        <div class="col-md-3">
                            <button type="button" class="btn btn-primary btn-sm" style="margin-top: 28px;" onclick="handleSaveUpdate()" id="saveButton">Salva</button>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-12">
                            <div class="table-responsive">
                                <table id="tblDynamicQuestionsData" class="table table-sm table-centered mb-0">
                                    <thead>
                                        <tr>
                                            <th class="d-none">questionId</th>
                                            <th class="d-none">quesFromId</th>
                                            <th class="d-none">tableId</th>
                                            <th>N.</th>
                                            <th>Blocco</th>
                                            <th>Categoria</th>
                                            <th>Qtà domande da visualizzare</th>
                                            <th>Azione</th>
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

    <script>

        $(document).ready(function () {
            loadQuestionsDynamicData();

            $('#ddlQuesFrom').change(function () {

                var quesFrom = document.getElementById('ddlQuesFrom').value;
                changeColumnData(quesFrom, -1);

            });

            $('#ddlColumnData').change(function () {

                var tableId = document.getElementById('ddlColumnData').value;
                var quesFrom = document.getElementById('ddlQuesFrom').value;
                getTotalQuestion(quesFrom, tableId);

            });

            $('#txtCount').keypress(function (event) {
                var keyCode = event.which;

                // Check if the pressed key is a numeric character or a control key (e.g., backspace, delete, arrow keys)
                if ((keyCode < 48 || keyCode > 57) && (keyCode !== 8 && keyCode !== 0 && keyCode !== 9 && keyCode !== 37 && keyCode !== 39)) {
                    // If not a numeric character or control key, prevent the default action (i.e., prevent typing)
                    event.preventDefault();
                }
            });


            $('#txtCount').on('input', function () {
                var totalCount = parseInt($('#txtTotalQuestion').val());
                var count = parseInt($(this).val());

                // Check if count is greater than total question count
                if (!isNaN(totalCount) && !isNaN(count) && count > totalCount) {
                    // Show alert
                    showAlert('Conteggio domande ha superato il conteggio domande max', 'danger');
                    // Clear input value
                    $(this).val('');
                }
            });

        });

        function handleSaveUpdate() {
            var saveButton = $('#saveButton');

            // Check the current text of the button
            if (saveButton.text().trim() === 'Salva') {
                // Call saveData function
                saveData();
            }
        }

        function saveData() {


            var quesFrom = $('#ddlQuesFrom').val();
            var tableId = $('#ddlColumnData').val();
            var questCount = $('#txtCount').val();


            // Data object to be sent in the AJAX request
            var data = {
                quesFrom: quesFrom,
                tableId: tableId,
                questCount: questCount,
            };


            setTimeout(function () {
                $.ajax({
                    type: "POST",
                    url: "/Pages/DynamicQuestion.aspx/AddDynamicQuestions",
                    data: JSON.stringify(data),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        if (response.d === "success") {
                            clearData();
                            showAlert('Dati inseriti correttamente', 'success');
                            loadQuestionsDynamicData();

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

            }, 300);

            showOverlay();
        }

        function changeColumnData(quesFrom, tableId) {

            setTimeout(function () {
                $.ajax({
                    type: "POST",
                    url: "/Pages/DynamicQuestion.aspx/GetTableColumnData",
                    data: JSON.stringify({ quesFrom: quesFrom }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        var data = JSON.parse(response.d);
                        $('#ddlColumnData').empty();

                        // Add "select" option at the beginning
                        $('#ddlColumnData').append($('<option>', {
                            value: -1,
                            text: '-- Seleziona --'
                        }));

                        $.each(data, function (index, item) {
                            $('#ddlColumnData').append($('<option>', {
                                value: item.tableId,
                                text: item.tableData
                            }));
                        });

                        // Set the value of ddlCOA after options are populated
                        $('#ddlColumnData').val(tableId);
                        $('#ddlColumnData').trigger('change.select2'); // Refresh dropdown
                    },
                    error: function (xhr, status, error) {
                        console.error(xhr.responseText);
                    }
                });

            }, 500);
        }

        function getTotalQuestion(quesFrom, tableId) {

            setTimeout(function () {
                $.ajax({
                    type: "POST",
                    url: "/Pages/DynamicQuestion.aspx/GetTotalQuestions",
                    data: JSON.stringify({ quesFrom: quesFrom, tableId: tableId }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        var totalCount = parseInt(response.d);
                        toggleTxtCount(totalCount);
                        $("#txtTotalQuestion").val(response.d);
                    },
                    error: function (xhr, status, error) {
                        console.error(xhr.responseText);
                    }
                });

            }, 500);
        }

        function toggleTxtCount(totalCount) {
            var txtCount = $('#txtCount');
            if (totalCount > 0) {
                txtCount.prop('disabled', false);
            } else {
                txtCount.prop('disabled', true);
            }
        }


        function loadQuestionsDynamicData() {
            $.ajax({
                type: "POST",
                url: "/Pages/DynamicQuestion.aspx/GetQuestionDynamicData",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d); // Parse the JSON string to an object

                    // Clear existing table rows
                    $('#tblDynamicQuestionsData tbody').empty();

                    var serialNo = 1;

                    // Populate table with new data
                    $.each(data, function (index, item) {
                        var row = $('<tr>');
                        row.append($('<td>').addClass('d-none').text(item.dynamicId));
                        row.append($('<td>').addClass('d-none').text(item.quesFromId));
                        row.append($('<td>').addClass('d-none').text(item.tableId));

                        row.append($('<td>').text(serialNo++)); // Serial number column
                        row.append($('<td>').text(item.quesFrom));
                        row.append($('<td>').text(item.columnData));
                        row.append($('<td>').text(item.questCount));

                        // Action buttons column
                        var actionColumn = $('<td>').addClass('table-action');
                        var deleteButton = $('<a>').attr('href', 'javascript:void(0);').addClass('action-icon').click(function () {
                            deleteData(item); // Pass the entire item object to the editData function
                        }).append($('<i>').addClass('mdi mdi-delete'));
                        actionColumn.append(deleteButton);

                        row.append(actionColumn);

                        $('#tblDynamicQuestionsData tbody').append(row);
                    });


                },
                error: function (xhr, status, error) {
                    console.error(xhr.responseText);
                }
            });

        }

        function deleteData(item) {

            showOverlay();

            var dynamicId = item.dynamicId;

            var data = {
                dynamicId: dynamicId
            };

            setTimeout(function () {

                $.ajax({
                    type: 'POST',
                    url: '/Pages/DynamicQuestion.aspx/DeleteData', // Replace with your server-side endpoint
                    data: JSON.stringify(data),
                    contentType: 'application/json',
                    success: function (response) {
                        if (response.d === "success") {
                            clearData();
                            showAlert('Cancellazione eseguita', 'delete');
                            loadQuestionsDynamicData();
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
            }, 1000);

        }


        function clearData() {

            $('#txtTotalQuestion').val("");
            $('#txtCount').val("");
            $('#ddlQuesFrom').val("-1");

            $('#ddlColumnData').val('');
            $('#ddlColumnData').empty();

        }


        function checkValues() {
            var ddlQuesFromElement = document.getElementById("ddlQuesFrom");
            var ddlQuesFrom = ddlQuesFromElement ? ddlQuesFromElement.value : "";
            if (ddlQuesFrom === "-1") {
                showAlert("Seleziona domande di partenza", "danger");
                return false;
            }

            var ddlColumnDataElement = document.getElementById("ddlColumnData");
            var ddlColumnData = ddlColumnDataElement ? ddlColumnDataElement.value : "";
            if (ddlColumnData === "-1") {
                showAlert("Selezionare colonna dato.", "danger");
                return false;
            }

            var txtCountElement = document.getElementById("txtCount");
            var txtCount = txtCountElement ? txtCountElement.value.trim() : "";
            if (txtCount === "") {
                showAlert("Inserire totale domande.", "danger");
                return false;
            }
            else if (parseInt(txtCount) == 0) {
                showAlert("nseriee valore totale domande maggiore di 0.", "danger");
                return false;
            }
        }

    </script>

</asp:Content>
