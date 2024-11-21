<%@ Page Title="" Language="C#" MasterPageFile="~/Template/ValuMaster.Master" AutoEventWireup="true" CodeBehind="Category.aspx.cs" Inherits="VALUQuest.Pages.Category" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="col-12">
        <div class="page-title-box">
            <h4 class="page-title">Categoria</h4>
        </div>
    </div>



    <div id="msgAlert"></div>
    <input type="hidden" id="hiddenCategoryId">
    <div class="row">
        <div class="col-12">
            <div class="card">
                <div class="card-body">

                    <div class="row mb-3">
                        <div class="col-md-3">
                            <label class="form-label">Blocco</label>
                            <select id="ddlBlock" class="form-select form-select-sm mb-3">
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Categoria</label>
                            <input type="text" id="txtCategoryName" class="form-control form-control-sm">
                        </div>
                        <div class="col-md-3 align-self-end">
                            <button id="saveButton" class="btn btn-primary" type="button" onclick="handleSaveUpdate()">Salva</button>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-12">
                            <div class="table-responsive">
                                <table id="tblCategoryData" class="table table-sm table-centered mb-0">
                                    <thead>
                                        <tr>
                                            <th class="d-none">categoryId</th>
                                            <th class="d-none">blockId</th>
                                            <th>N.</th>
                                            <th>Blocco</th>
                                            <th>Categoria</th>
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

    <script type="text/javascript"> 


        $(document).ready(function () {

            loadDataCategory();
            loadBlocks();
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

        function loadBlocks() {

            $.ajax({
                type: "POST",
                url: "/Pages/Category.aspx/GetBlock",
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


        function saveData() {

            // Check if the date textbox is empty
            if (!checkValues()) {
                return;
            }

            var blockId = $('#ddlBlock').val();
            var categoryName = $('#txtCategoryName').val();


            // Data object to be sent in the AJAX request
            var data = {
                blockId: blockId,
                categoryName: categoryName
            };


            setTimeout(function () {
                $.ajax({
                    type: "POST",
                    url: "/Pages/Category.aspx/AddCategory",
                    data: JSON.stringify(data),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        if (response.d === "success") {
                            clearData();
                            showAlert('Dati inseriti correttamente', 'success');
                            loadDataCategory();

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


        function loadDataCategory() {
            $.ajax({
                type: "POST",
                url: "/Pages/Category.aspx/GetCategoryData",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d); // Parse the JSON string to an object

                    // Clear existing table rows
                    $('#tblCategoryData tbody').empty();

                    var serialNo = 1;

                    // Populate table with new data
                    $.each(data, function (index, item) {
                        var row = $('<tr>');
                        row.append($('<td>').addClass('d-none').text(item.categoryId));
                        row.append($('<td>').addClass('d-none').text(item.blockId));

                        row.append($('<td>').text(serialNo++)); // Serial number column
                        row.append($('<td>').text(item.blockName));
                        row.append($('<td>').text(item.categoryName));

                        // Action buttons column
                        var actionColumn = $('<td>').addClass('table-action');
                        var editButton = $('<a>').attr('href', 'javascript:void(0);').addClass('action-icon').click(function () {
                            editData(item); // Pass the entire item object to the editData function
                        }).append($('<i>').addClass('mdi mdi-pencil'));
                        var deleteButton = $('<a>').attr('href', 'javascript:void(0);').addClass('action-icon').click(function () {
                            deleteData(item); // Pass the entire item object to the editData function
                        }).append($('<i>').addClass('mdi mdi-delete'));
                        actionColumn.append(editButton, deleteButton);

                        row.append(actionColumn);

                        $('#tblCategoryData tbody').append(row);
                    });


                },
                error: function (xhr, status, error) {
                    console.error(xhr.responseText);
                }
            });

        }

        function editData(item) {
            // Extract data from the item object


            var blockId = item.blockId;
            var categoryId = item.categoryId;
            var categoryName = item.categoryName;


            document.getElementById('txtCategoryName').value = categoryName;
            document.getElementById('hiddenCategoryId').value = categoryId;
            //document.getElementById('ddlBlock').value = blockId;
            $('#ddlBlock').val(item.blockId);

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

            var hid = document.getElementById('hiddenCategoryId').value;

            // Retrieve updated values from form fields
            var categoryId = document.getElementById('hiddenCategoryId').value;
            var categoryName = document.getElementById('txtCategoryName').value;
            var blockId = document.getElementById('ddlBlock').value;

            // Prepare data object to send to the server
            var data = {
                categoryId: categoryId,
                blockId: blockId,
                categoryName: categoryName
            };

            setTimeout(function () {
                // Send AJAX POST request to update the record
                $.ajax({
                    type: 'POST',
                    url: '/Pages/Category.aspx/UpdateData', // Replace with your server-side endpoint
                    data: JSON.stringify(data),
                    contentType: 'application/json',
                    success: function (response) {
                        if (response.d === "success") {
                            clearData();
                            showAlert('Dati inseriti correttamente', 'update');
                            loadDataCategory();
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

        function deleteData(item) {

            showOverlay();

            var categoryId = item.categoryId;

            var data = {
                categoryId: categoryId
            };

            setTimeout(function () {

                $.ajax({
                    type: 'POST',
                    url: '/Pages/Category.aspx/DeleteData', // Replace with your server-side endpoint
                    data: JSON.stringify(data),
                    contentType: 'application/json',
                    success: function (response) {
                        if (response.d === "success") {
                            clearData();
                            showAlert('Cancellazione eseguita', 'delete');
                            loadDataCategory();
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

            // Check if ddlCOA is selected with a value of -1
            var ddlBlockElement = document.getElementById("ddlBlock");
            var ddlBlock = ddlBlockElement ? ddlBlockElement.value : "";
            if (ddlBlock === "-1") {
                showAlert("Seleziona Blocco", "danger");
                return false;
            }

            var dateElement = document.getElementById("txtCategoryName");
            var date = dateElement ? dateElement.value.trim() : "";
            if (date === "") {
                showAlert("Seleziona Categoria", "danger");
                return false;
            }

            return true;

        }

        function clearData() {

            $('#txtCategoryName').val("");

        }


    </script>

</asp:Content>
