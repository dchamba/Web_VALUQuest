<%@ Page Title="" Language="C#" MasterPageFile="~/Template/ValuMaster.Master" AutoEventWireup="true" CodeBehind="SubCategory.aspx.cs" Inherits="VALUQuest.Pages.SubCategory" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="col-12">
        <div class="page-title-box">
            <h4 class="page-title">Sottocategoria</h4>
        </div>
    </div>



    <div id="msgAlert"></div>
    <input type="hidden" id="hiddenSubCategoryId">
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
                            <select id="ddlCategory" class="form-select form-select-sm mb-3">
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Sottocategoria</label>
                            <input type="text" id="txtSubCategoryName" class="form-control form-control-sm">
                        </div>
                        <div class="col-md-3 align-self-end">
                            <button id="saveButton" class="btn btn-primary" type="button" onclick="handleSaveUpdate()">Salva</button>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-12">
                            <div class="table-responsive">
                                <table id="tblSubCategoryData" class="table table-sm table-centered mb-0">
                                    <thead>
                                        <tr>
                                            <th class="d-none">subcategoryId</th>
                                            <th class="d-none">blockId</th>
                                            <th class="d-none">categoryId</th>

                                            <th>N.</th>
                                            <th>Blocco</th>
                                            <th>Categoria</th>
                                            <th>Sottocategoria</th>
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

            loadDataSubCategory();
            loadBlocks();

            $('#ddlBlock').change(function () {

                var blockId = document.getElementById('ddlBlock').value;
                changeCategory(blockId, -1);

            });

        });

        function changeCategory(blockId, catId) {


            $.ajax({
                type: "POST",
                url: "/Pages/SubCategory.aspx/GetCategories",
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

        function loadBlocks() {

            $.ajax({
                type: "POST",
                url: "/Pages/SubCategory.aspx/GetBlock",
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

            var categoryId = $('#ddlCategory').val();
            var subcategoryName = $('#txtSubCategoryName').val();


            // Data object to be sent in the AJAX request
            var data = {
                categoryId: categoryId,
                subcategoryName: subcategoryName
            };


            setTimeout(function () {
                $.ajax({
                    type: "POST",
                    url: "/Pages/SubCategory.aspx/AddSubCategory",
                    data: JSON.stringify(data),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        if (response.d === "success") {
                            clearData();
                            showAlert('Dati inseriti correttamente', 'success');
                            loadDataSubCategory();

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

        function loadDataSubCategory() {
            $.ajax({
                type: "POST",
                url: "/Pages/SubCategory.aspx/GetSubCategoryData",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d); // Parse the JSON string to an object

                    // Clear existing table rows
                    $('#tblSubCategoryData tbody').empty();

                    var serialNo = 1;

                    // Populate table with new data
                    $.each(data, function (index, item) {
                        var row = $('<tr>');
                        row.append($('<td>').addClass('d-none').text(item.subCatId));
                        row.append($('<td>').addClass('d-none').text(item.blockId));
                        row.append($('<td>').addClass('d-none').text(item.categoryId));


                        row.append($('<td>').text(serialNo++)); // Serial number column
                        row.append($('<td>').text(item.blockName));
                        row.append($('<td>').text(item.categoryName));
                        row.append($('<td>').text(item.subCatName));


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

                        $('#tblSubCategoryData tbody').append(row);
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
            var subCatId = item.subCatId;
            var subcategoryName = item.subCatName;


            document.getElementById('txtSubCategoryName').value = subcategoryName;
            document.getElementById('hiddenSubCategoryId').value = subCatId;
            //document.getElementById('ddlBlock').value = blockId;
            $('#ddlBlock').val(blockId);

            changeCategory(blockId, categoryId);

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

            var hid = document.getElementById('hiddenSubCategoryId').value;

            // Retrieve updated values from form fields
            var subcatId = document.getElementById('hiddenSubCategoryId').value;
            var subcategoryName = document.getElementById('txtSubCategoryName').value;
            var blockId = document.getElementById('ddlBlock').value;
            var categoryId = document.getElementById('ddlCategory').value;


            // Prepare data object to send to the server
            var data = {
                subcatId:subcatId,
                categoryId: categoryId,
                subcategoryName: subcategoryName
            };

            setTimeout(function () {
                // Send AJAX POST request to update the record
                $.ajax({
                    type: 'POST',
                    url: '/Pages/SubCategory.aspx/UpdateData', // Replace with your server-side endpoint
                    data: JSON.stringify(data),
                    contentType: 'application/json',
                    success: function (response) {
                        if (response.d === "success") {
                            clearData();
                            showAlert('Dati inseriti correttamente', 'update');
                            loadDataSubCategory();
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

            var subCatId = item.subCatId;

            var data = {
                subCatId: subCatId
            };

            setTimeout(function () {

                $.ajax({
                    type: 'POST',
                    url: '/Pages/SubCategory.aspx/DeleteData', // Replace with your server-side endpoint
                    data: JSON.stringify(data),
                    contentType: 'application/json',
                    success: function (response) {
                        if (response.d === "success") {
                            clearData();
                            showAlert('Cancellazione eseguita', 'delete');
                            loadDataSubCategory();
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
            }, 300);

        }

        function checkValues() {

            // Check if ddlCOA is selected with a value of -1
            var ddlBlockElement = document.getElementById("ddlBlock");
            var ddlBlock = ddlBlockElement ? ddlBlockElement.value : "";
            if (ddlBlock === "-1") {
                showAlert("Seleziona blocco", "danger");
                return false;
            }


            // Check if ddlCOA is selected with a value of -1
            var ddlCategoryElement = document.getElementById("ddlCategory");
            var ddlCategory = ddlCategoryElement ? ddlCategoryElement.value : "";
            if (ddlCategory === "-1") {
                showAlert("Seleziona Categoria", "danger");
                return false;
            }
            var dateElement = document.getElementById("txtSubCategoryName");
            var date = dateElement ? dateElement.value.trim() : "";
            if (date === "") {
                showAlert("Inserire nome sottocategoria", "danger");
                return false;
            }

            return true;

        }

        function clearData() {

            $('#txtSubCategoryName').val("");
            $('hiddenSubCategoryId').val("");
            $('#ddlBlock').val("-1");
            $('#ddlCategory').val('');
            $('#ddlCategory').empty();
        }

    </script>

</asp:Content>
