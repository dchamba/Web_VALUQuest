<%@ Page Title="" Language="C#" MasterPageFile="~/Template/ValuMaster.Master" AutoEventWireup="true" CodeBehind="Block.aspx.cs" Inherits="VALUQuest.Pages.Block" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <div class="row">
        <div class="col-12">
            <div class="page-title-box">
                <h4 class="page-title">Blocco</h4>
            </div>
        </div>

        <div id="msgAlert"></div>
        <input type="hidden" id="hiddenBlockId">
        <div class="row">
            <div class="col-12">
                <div class="card">
                    <div class="card-body">

                        <div class="row mb-3">
                            <div class="col-md-3">
                                <label class="form-label">Blocco</label>
                                <input type="text" id="txtBlockName" class="form-control form-control-sm">
                            </div>
                            <div class="col-md-3 align-self-end">
                                <button id="saveButton" class="btn btn-primary" type="button" onclick="handleSaveUpdate()">Salva</button>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-12">
                                <div class="table-responsive">
                                    <table id="basic-datatable" class="table table-striped dt-responsive nowrap w-100">
                                        <thead>
                                            <tr>
                                                <th class="d-none">blockId</th>
                                                <th>N.</th>
                                                <th>Blocco</th>
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

    </div>

    <script src="../Scripts/jquery-3.3.1.js"></script>

    <script type="text/javascript"> 


        $(document).ready(function () {


            loadDataBlocks();


        });
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



        function saveData() {

            // Check if the date textbox is empty
            if (!checkValues()) {
                return;
            }

            var blockName = $('#txtBlockName').val();

            // Data object to be sent in the AJAX request
            var data = {
                blockName: blockName
            };


            setTimeout(function () {
                $.ajax({
                    type: "POST",
                    url: "/Pages/Block.aspx/AddBlock",
                    data: JSON.stringify(data),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        if (response.d === "success") {
                            clearData();
                            showAlert('Dati inseriti correttamente', 'success');
                            loadDataBlocks();

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


        function loadDataBlocks() {
            $.ajax({
                type: "POST",
                url: "/Pages/Block.aspx/GetBlocksData",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d); // Parse the JSON string to an object

                    // Clear existing table rows
                    $('#basic-datatable').DataTable().clear().destroy();

                    var serialNo = 1;
                    var rows = [];

                    // Populate table with new data
                    $.each(data, function (index, item) {
                        var row = [];
                        row.push('<td class="d-none">' + item.blockId + '</td>');
                        row.push(item.blockId); // Serial number column
                        row.push(item.blockName);

                        // Action buttons column
                        var actionColumn = '<td class="table-action">' +
                            '<a href="javascript:void(0);" class="action-icon" data-item=\'' + JSON.stringify(item) + '\' onclick="editData(this)">' +
                            '<i class="mdi mdi-pencil"></i></a>' +
                            '<a href="javascript:void(0);" class="action-icon" data-item=\'' + JSON.stringify(item) + '\' onclick="deleteData(this)">' +
                            '<i class="mdi mdi-delete"></i></a></td>';

                        row.push(actionColumn);
                        rows.push(row);
                    });

                    // Initialize DataTable with new data
                    $('#basic-datatable').DataTable({
                        data: rows,
                        columns: [
                            { title: "blockId", visible: false },
                            { title: "N." },
                            { title: "Blocco" },
                            { title: "Azione" }
                        ],
                        responsive: true
                    });
                },
                error: function (xhr, status, error) {
                    console.error(xhr.responseText);
                }
            });
        }

        function editData(element) {
            var item = JSON.parse($(element).attr('data-item'));

            console.log(item.blockId);

            var blockId = item.blockId;
            var blockName = item.blockName;

            document.getElementById('txtBlockName').value = blockName;
            document.getElementById('hiddenBlockId').value = blockId;

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

            var hid = document.getElementById('hiddenBlockId').value;

            // Retrieve updated values from form fields
            var blockId = document.getElementById('hiddenBlockId').value;
            var blockName = document.getElementById('txtBlockName').value;

            // Prepare data object to send to the server
            var data = {
                blockId: blockId,
                blockName: blockName
            };

            setTimeout(function () {
                // Send AJAX POST request to update the record
                $.ajax({
                    type: 'POST',
                    url: '/Pages/Block.aspx/UpdateData', // Replace with your server-side endpoint
                    data: JSON.stringify(data),
                    contentType: 'application/json',
                    success: function (response) {
                        if (response.d === "success") {
                            clearData();
                            showAlert('Dati inseriti correttamente', 'update');
                            loadDataBlocks();
                            // Change the button text to "Update"
                            $('#saveButton').text('Salva');

                        } else {
                            showAlert('Errore durante aggiornamento', 'danger');
                        }
                    },
                    error: function (xhr, textStatus, errorThrown) {
                        showAlert('Errore durante aggiornamento', 'danger');
                    },
                    complete: function () {

                        hideOverlay();
                    }
                });
            }, 500);
        }

        function deleteData(element) {

            var item = JSON.parse($(element).attr('data-item'));

            showOverlay();

            var blockId = item.blockId;

            var data = {
                blockId: blockId
            };

            setTimeout(function () {

                $.ajax({
                    type: 'POST',
                    url: '/Pages/Block.aspx/DeleteData', // Replace with your server-side endpoint
                    data: JSON.stringify(data),
                    contentType: 'application/json',
                    success: function (response) {
                        if (response.d === "success") {
                            clearData();
                            showAlert('Cancellazione eseguita', 'delete');
                            loadDataBlocks();
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

        function checkValues() {

            var dateElement = document.getElementById("txtBlockName");
            var date = dateElement ? dateElement.value.trim() : "";
            if (date === "") {
                showAlert("Inserire nome blocco.", "danger");
                return false;
            }

            return true;

        }

        function clearData() {

            $('#txtBlockName').val("");

        }

    </script>


</asp:Content>
