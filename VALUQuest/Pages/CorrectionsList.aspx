<%@ Page Title="" Language="C#" MasterPageFile="~/Template/ValuMaster.Master" AutoEventWireup="true" CodeBehind="CorrectionsList.aspx.cs" Inherits="VALUQuest.Pages.CorrectionsList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <link rel="stylesheet" href="https://cdn.datatables.net/1.11.5/css/jquery.dataTables.min.css">
    <style>
        .switch { position: relative; display: inline-block; width: 40px; /* Reduced width */ height: 20px; /* Reduced height */ }

            .switch input { opacity: 0; width: 0; height: 0; }

        .slider { position: absolute; cursor: pointer; top: 0; left: 0; right: 0; bottom: 0; background-color: #ccc; -webkit-transition: .4s; transition: .4s; border-radius: 20px; /* To maintain rounded edges */ }

            .slider:before { position: absolute; content: ""; height: 16px; /* Reduced height */ width: 16px; /* Reduced width */ left: 2px; bottom: 2px; background-color: white; -webkit-transition: .4s; transition: .4s; border-radius: 50%; }

        input:checked + .slider { background-color: #2196F3; }

        input:focus + .slider { box-shadow: 0 0 1px #2196F3; }

        input:checked + .slider:before { -webkit-transform: translateX(20px); -ms-transform: translateX(20px); transform: translateX(20px); }
        /* Style for child rows (details) */
        .child-row { font-size: 0.85rem !important; }
    </style>
    <div class="row">
        <div class="col-12">
            <div class="page-title-box">
                <h4 class="page-title">Corrections List</h4>
            </div>
        </div>
        <div class="col-12">
            <div class="card">
                <div class="card-body">
                    <div id="loading-image" class="text-center">
                        <img src="../images/loading.gif" width="100" height="100" alt="loading..." />
                    </div>
                    <table id="correctionsTable" class="display table table-borderless table-sm">
                        <thead style="white-space:nowrap">
                            <tr>
                                <th class="d-none">Correction ID</th>
                                <th>Correction Name</th>
                                <th>Value to Add</th>
                                <th>Message</th>
                                <th>Created Date</th>
                                <th>Is Active</th>
                                <th>Action </th>
                            </tr>
                        </thead>
                        <tbody></tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
    <%--<script src="../Scripts/jquery-3.3.1.js"></script>--%>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.datatables.net/1.11.5/js/jquery.dataTables.min.js"></script>
    <script type="text/javascript">
        $('#loading-image').hide();
        function editCorrection(correctionId) {
            //alert(correctionId);
            window.location.href = `Corrections.aspx?ID=${correctionId}`;
        }

        $(document).ready(function () {
            loadDataQuestions(); // Load data on page load
        });
        function loadDataQuestions() {
            $.ajax({
                type: "POST",
                url: "/Pages/CorrectionsList.aspx/GetCorrectionsWithConditions",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    const originalData = JSON.parse(response.d);
                    initializeDataTable(originalData);
                    $('#loading-image').hide();
                },
                error: function (xhr, status, error) {
                    console.error(xhr.responseText);
                    $('#loading-image').hide();
                }
            });
        }
        function initializeDataTable(data) {
            const groupedData = {};
            // Group data by correctionId
            data.forEach(item => {
                if (!groupedData[item.correctionId]) {
                    groupedData[item.correctionId] = {
                        master: item,
                        details: []
                    };
                }
                groupedData[item.correctionId].details.push(item);
            });
            const tableBody = $('#correctionsTable tbody');
            tableBody.empty(); // Clear existing rows

            Object.values(groupedData).forEach(group => {
                const masterRow = group.master;

                // Append the master row
                const masterRowHtml = `
                        <tr class="master-row" data-id="${masterRow.correctionId}">
                            <td class="d-none">${masterRow.correctionId}</td>
                            <td>${masterRow.correctionName}</td>
                            <td class="text-center">${masterRow.valueToAdd}</td>
                            <td>${masterRow.message}</td>
                            <td>${formatDate(masterRow.createdDate)}</td>
                            <td class="text-center">
                            <label class="switch">
                                <input type="checkbox" class="toggle-active" data-id="${masterRow.correctionId}" ${masterRow.isActive ? 'checked' : ''}>
                                <span class="slider"></span>
                            </label>
                            </td>
                            <td class="text-center" style="white-space:nowrap">
                                <button title="Show Details" class="toggle-details btn btn-info btn-sm" type="button"><i class="fa-solid fa-eye"></i></button>
                                <button title="Edit" class="btn btn-danger btn-sm" onclick="editCorrection(${masterRow.correctionId})" type="button"><i class="fa-solid fa-edit"></i></button>
                            </td>
                        </tr>`;
                tableBody.append(masterRowHtml);

                // Append details header row
                //const detailsHeaderHtml = `
                //        <tr class="child-row" data-parent-id="${masterRow.correctionId}" style="display:none;white-space:nowrap">
                //            <th>Condition Type</th>
                //            <th>Operator</th>
                //            <th>Condition Value 1</th>
                //            <th>Condition Value 2</th>
                //            <th>Conjunction</th>
                //            <th>Block Info</th>
                //        </tr>`;
                //tableBody.append(detailsHeaderHtml);
                // Append details rows
                group.details.forEach(detail => {
                    const detailRowHtml = `
                        <tr class="child-row" data-parent-id="${masterRow.correctionId}" style="display:none;background-color: rgb(213 241 253)">
                            <td colspan="7">&nbsp;&nbsp;&nbsp; <i class='fas fa-arrows-turn-right'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</i> ${detail.Conditions}</td>
                        </tr>`;
                    tableBody.append(detailRowHtml);
                });
            });

            // Initialize DataTable
            const dataTable = $('#correctionsTable').DataTable();
        }

        // Event delegation for toggle details button
        $('#correctionsTable tbody').off('click', '.toggle-details').on('click', '.toggle-details', function () {
            const parentId = $(this).closest('tr').data('id');
            const childRows = $(`.child-row[data-parent-id="${parentId}"]`);

            // Toggle the visibility of child rows
            childRows.toggle();

            // Update button with icons and title
            if (childRows.is(':visible')) {
                $(this).html('<i class="fas fa-eye-slash"></i>').attr('title', 'Hide Details'); // Update button to hide details
            } else {
                $(this).html('<i class="fas fa-eye"></i>').attr('title', 'Show Details'); // Update button to show details
            }
        });

        // Function to convert Microsoft JSON date format to a standard date format
        function formatDate(dateString) {
            const matches = dateString.match(/\/Date\((\d+)\)\//);
            if (matches) {
                const date = new Date(parseInt(matches[1], 10));
                return date.toLocaleString(); // Format the date as needed
            }
            return dateString; // Return the original string if it doesn't match
        }

        $('#correctionsTable tbody').on('change', 'input[type="checkbox"]', function () {
            const checkbox = $(this); // Store the reference to the current checkbox
            const correctionId = checkbox.data('id');
            const isActive = checkbox.is(':checked'); // This will give true or false
            // Show the loading image
            $('#loading-image').show();
            $.ajax({
                url: 'CorrectionsList.aspx/UpdateCorrectionStatus',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                data: JSON.stringify({
                    correctionId: correctionId,
                    isActive: isActive
                }),
                dataType: 'json',
                success: function (response) {
                    $('#loading-image').hide();
                    if (response.d) {
                        console.info("Status successfully changed...");
                    } else {
                        alert("Status not changed...");
                        checkbox.prop('checked', !isActive);
                    }

                },
                error: function (xhr, status, error) {
                    $('#loading-image').hide();
                    console.error("Error updating correction ID " + correctionId + ": " + xhr.responseText);
                    checkbox.prop('checked', !isActive);
                }
            });
        });


    </script>


</asp:Content>
