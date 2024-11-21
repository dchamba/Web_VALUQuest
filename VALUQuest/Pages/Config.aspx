<%@ Page Title="" Language="C#" MasterPageFile="~/Template/ValuMaster.Master" AutoEventWireup="true" CodeBehind="Config.aspx.cs" Inherits="VALUQuest.Pages.Config" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <div class="row">
        <div class="col-12">
            <div class="page-title-box">
                <h4 class="page-title">Defaults</h4>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-12">
            <div class="card">
                <div class="card-body">

                    <div class="row mb-3">
                        <div class="col-md-12">
                            <div class="tab-content">
                                <div class="tab-pane active show" id="justified-tabs-preview" role="tabpanel">
                                    <ul class="nav nav-pills bg-nav-pills nav-justified mb-3" role="tablist">
                                        <li class="nav-item" role="presentation">
                                            <a href="#blocks" data-bs-toggle="tab" aria-expanded="false" class="nav-link rounded-0 active" aria-selected="true" role="tab">
                                                <i class="mdi d-md-none d-block">Blocks</i>
                                                <span class="d-none d-md-block">Blocks</span>
                                            </a>
                                        </li>
                                        <li class="nav-item" role="presentation">
                                            <a href="#category" data-bs-toggle="tab" aria-expanded="true" class="nav-link rounded-0" aria-selected="false" role="tab" tabindex="-1">
                                                <i class="mdi d-md-none d-block">Category</i>
                                                <span class="d-none d-md-block">Category</span>
                                            </a>
                                        </li>
                                        <li class="nav-item" role="presentation">
                                            <a href="#subcategory" data-bs-toggle="tab" aria-expanded="false" class="nav-link rounded-0" aria-selected="false" role="tab" tabindex="-1">
                                                <i class="mdi d-md-none d-block">Sub Category</i>
                                                <span class="d-none d-md-block">Sub Category</span>
                                            </a>
                                        </li>
                                    </ul>

                                    <div class="tab-content">
                                        <div class="tab-pane active show" id="blocks" role="tabpanel">
                                            <div class="row mb-3">
                                                <div class="col-md-3">
                                                    <label class="form-label">Block</label>
                                                    <input type="text" id="txtBlockName" class="form-control form-control-sm">
                                                </div>
                                                <div class="col-md-3 align-self-end">
                                                    <button onclick="addBlock()" style="margin-top: 28px;" class="btn btn-primary btn-sm">Save</button>
                                                </div>
                                            </div>

                                            <div class="row">
                                                <div class="col-md-12">
                                                    <div class="table-responsive">
                                                        <table id="tblBlockData" class="table table-sm table-centered mb-0">
                                                            <thead>
                                                                <tr>
                                                                    <th class="d-none">blockId</th>
                                                                    <th>S.No</th>
                                                                    <th>Block</th>
                                                                    <th>Action</th>
                                                                </tr>
                                                            </thead>
                                                            <tbody>
                                                            </tbody>
                                                        </table>
                                                    </div>
                                                </div>

                                            </div>

                                        </div>
                                        <div class="tab-pane" id="category" role="tabpanel">
                                            <div class="row mb-3">

                                                <div class="col-md-3">
                                                    <label class="form-label">Block</label>
                                                    <select class="form-control select2" data-toggle="select2">
                                                        <option>Select</option>
                                                        <option value="AK">Block 1</option>
                                                        <option value="HI">Block 2</option>
                                                        <option value="CA">Block 3</option>
                                                        <option value="CA">Block 4</option>
                                                        <option value="CA">Block 5</option>
                                                    </select>
                                                </div>

                                                <div class="col-md-3">
                                                    <label class="form-label">Category</label>
                                                    <input type="text" class="form-control form-control-sm">
                                                </div>
                                                <div class="col-md-3 align-self-end">
                                                    <button type="submit" style="margin-top: 28px;" class="btn btn-primary btn-sm">Save</button>
                                                </div>
                                            </div>

                                            <div class="row">
                                                <div class="col-md-12">
                                                    <div class="table-responsive">
                                                        <table id="datatableCategory" class="table table-striped dt-responsive nowrap w-100">
                                                            <thead>
                                                                <tr>
                                                                    <th>S.No</th>
                                                                    <th>Block</th>
                                                                    <th>Category</th>
                                                                    <th>Action</th>
                                                                </tr>
                                                            </thead>
                                                            <tbody>
                                                                <tr>
                                                                    <td>1</td>
                                                                    <td>Block 1</td>
                                                                    <td>Category A</td>
                                                                    <td class="table-action">
                                                                        <a href="javascript: void(0);" class="action-icon"><i class="mdi mdi-pencil"></i></a>
                                                                        <a href="javascript: void(0);" class="action-icon"><i class="mdi mdi-delete"></i></a>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>2</td>
                                                                    <td>Block 1</td>
                                                                    <td>Category B</td>
                                                                    <td class="table-action">
                                                                        <a href="javascript: void(0);" class="action-icon"><i class="mdi mdi-pencil"></i></a>
                                                                        <a href="javascript: void(0);" class="action-icon"><i class="mdi mdi-delete"></i></a>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>3</td>
                                                                    <td>Block 2</td>
                                                                    <td>Category C</td>
                                                                    <td class="table-action">
                                                                        <a href="javascript: void(0);" class="action-icon"><i class="mdi mdi-pencil"></i></a>
                                                                        <a href="javascript: void(0);" class="action-icon"><i class="mdi mdi-delete"></i></a>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>4</td>
                                                                    <td>Block 3</td>
                                                                    <td>Category D</td>
                                                                    <td class="table-action">
                                                                        <a href="javascript: void(0);" class="action-icon"><i class="mdi mdi-pencil"></i></a>
                                                                        <a href="javascript: void(0);" class="action-icon"><i class="mdi mdi-delete"></i></a>
                                                                    </td>
                                                                </tr>

                                                            </tbody>
                                                        </table>
                                                    </div>
                                                </div>

                                            </div>
                                        </div>
                                        <div class="tab-pane" id="subcategory" role="tabpanel">

                                            <div class="row mb-3">

                                                <div class="col-md-3">
                                                    <label class="form-label">Category</label>
                                                    <select class="form-control select2" data-toggle="select2">
                                                        <option>Select</option>
                                                        <option value="AK">Category A</option>
                                                        <option value="HI">Category B</option>
                                                        <option value="CA">Category C</option>
                                                        <option value="CA">Category D</option>
                                                    </select>
                                                </div>

                                                <div class="col-md-3">
                                                    <label class="form-label">Sub Category</label>
                                                    <input type="text" class="form-control form-control-sm">
                                                </div>
                                                <div class="col-md-3 align-self-end">
                                                    <button type="submit" style="margin-top: 28px;" class="btn btn-primary btn-sm">Save</button>
                                                </div>
                                            </div>

                                            <div class="row">
                                                <div class="col-md-12">
                                                    <div class="table-responsive">
                                                        <table id="datatableSubCategory" class="table table-striped dt-responsive nowrap w-100">
                                                            <thead>
                                                                <tr>
                                                                    <th>S.No</th>
                                                                    <th>Category</th>
                                                                    <th>Sub Category</th>
                                                                    <th>Action</th>
                                                                </tr>
                                                            </thead>
                                                            <tbody>
                                                                <tr>
                                                                    <td>1</td>
                                                                    <td>Category A</td>
                                                                    <td>Sub Category A</td>
                                                                    <td class="table-action">
                                                                        <a href="javascript: void(0);" class="action-icon"><i class="mdi mdi-pencil"></i></a>
                                                                        <a href="javascript: void(0);" class="action-icon"><i class="mdi mdi-delete"></i></a>
                                                                    </td>
                                                                </tr>

                                                                <tr>
                                                                    <td>2</td>
                                                                    <td>Category A</td>
                                                                    <td>Sub Category B</td>
                                                                    <td class="table-action">
                                                                        <a href="javascript: void(0);" class="action-icon"><i class="mdi mdi-pencil"></i></a>
                                                                        <a href="javascript: void(0);" class="action-icon"><i class="mdi mdi-delete"></i></a>
                                                                    </td>
                                                                </tr>

                                                                <tr>
                                                                    <td>3</td>
                                                                    <td>Category B</td>
                                                                    <td>Sub Category C</td>
                                                                    <td class="table-action">
                                                                        <a href="javascript: void(0);" class="action-icon"><i class="mdi mdi-pencil"></i></a>
                                                                        <a href="javascript: void(0);" class="action-icon"><i class="mdi mdi-delete"></i></a>
                                                                    </td>
                                                                </tr>

                                                            </tbody>
                                                        </table>
                                                    </div>
                                                </div>

                                            </div>

                                        </div>
                                    </div>
                                </div>
                                <!-- end preview-->


                                <!-- end preview code-->
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


        function addBlock() {

            var blockName = $('#txtBlockName').val();

            // Data object to be sent in the AJAX request
            var data = {
                blockName: blockName
            };

            alert(blockName);

            setTimeout(function () {
                $.ajax({
                    type: "POST",
                    url: "/Pages/Config.aspx/AddBlock",
                    data: JSON.stringify(data),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        if (response.d === "success") {
                            //clearData();
                            showAlert('Data inserted successfully', 'success');
                            //loadData();

                        } else {
                            showAlert('Error inserting data', 'danger');
                        }
                    },
                    error: function (xhr, textStatus, errorThrown) {
                        showAlert('Error inserting data', 'danger');
                    },
                    complete: function () {
                        // Hide spinner button, show save button
                        hideOverlay();
                    }
                });

            }, 300);

        }

        function loadDataBlocks() {
            $.ajax({
                type: "POST",
                url: "/Pages/Config.aspx/GetBlocksData",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d); // Parse the JSON string to an object

                    // Clear existing table rows
                    $('#tblBlockData tbody').empty();

                    var serialNo = 1;

                    // Populate table with new data
                    $.each(data, function (index, item) {
                        var row = $('<tr>');
                        row.append($('<td>').addClass('d-none').text(item.blockId));
                        row.append($('<td>').text(serialNo++)); // Serial number column
                        row.append($('<td>').text(item.blockName));
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

                        $('#tblBlockData tbody').append(row);
                    });


                },
                error: function (xhr, status, error) {
                    console.error(xhr.responseText);
                }
            });

        }

    </script>

</asp:Content>
