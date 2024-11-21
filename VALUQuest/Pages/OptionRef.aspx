<%@ Page Title="" Language="C#" MasterPageFile="~/Template/ValuMaster.Master" AutoEventWireup="true" CodeBehind="OptionRef.aspx.cs" Inherits="VALUQuest.Pages.OptionRef" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <div class="row">
        <div class="col-12">
            <div class="page-title-box">
                <h4 class="page-title">Risposta di partenza</h4>
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

                      
                    </div>
                    <div class="row">
                        <div class="col-md-9">
                            <label class="form-label">Domanda</label>
                            <select id="ddlQuestion" class="form-select form-select-sm">
                            </select>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-12">
                            <div class="table-responsive">
                                <table id="tblOptionsData" class="table table-sm table-centered mb-0">
                                    <thead>
                                        <tr>
                                            <th class="d-none">optionId</th>
                                            <th>N.</th>
                                            <th>Opzioni</th>
                                            <th>Valore</th>
                                            <th>Risposta di partenza</th>
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
                    </div>

                </div>
            </div>
        </div>
    </div>

    <script src="../Scripts/jquery-3.3.1.js"></script>


    <script>
        $(document).ready(function () {

            loadBlocks();

            // Attach change event listeners to the dropdowns
            $('#ddlBlock, #ddlCategory,  #ddlQuestion').change(function () {
                // Clear the table
                $('#tblOptionsData tbody').empty();
            });


            //$('#ddlBlock').change(function () {

            //    var blockId = document.getElementById('ddlBlock').value;
            //    changeCategory(blockId, -1);

            //});

            // Attach change event listener to the block dropdown
            $('#ddlBlock').change(function () {
                // Clear the category, subcategory, and question dropdowns
                $('#ddlCategory').empty().append('<option value="-1">--Seleziona--</option>');
                $('#ddlQuestion').empty().append('<option value="-1">--Seleziona--</option>');

                // Clear the table
                $('#tblOptionsData tbody').empty();

                // Load categories based on the selected block
                var blockId = $(this).val();
                if (blockId !== '-1') {
                     changeCategory(blockId, -1);
                }
            });

            $('#ddlCategory').change(function () {

                var categoryId = document.getElementById('ddlCategory').value;
                  loadQuestions(categoryId);

            });

           

            $('#ddlQuestion').change(function () {

                var questionId = document.getElementById('ddlQuestion').value;
                loadOptions(questionId);

            });

        });

        function loadBlocks() {

            $.ajax({
                type: "POST",
                url: "/Pages/OptionRef.aspx/GetBlock",
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
                    url: "/Pages/OptionRef.aspx/GetCategories",
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

      
        function loadQuestions(catId) {

            $.ajax({
                type: "POST",
                url: "/Pages/OptionRef.aspx/GetQuestions",
                data: JSON.stringify({ catId: catId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d);
                    $('#ddlQuestion').empty();

                    // Add "select" option at the beginning
                    $('#ddlQuestion').append($('<option>', {
                        value: -1,
                        text: '-- Seleziona --'
                    }));

                    $.each(data, function (index, item) {
                        $('#ddlQuestion').append($('<option>', {
                            value: item.questionId,
                            text: item.questionName
                        }));
                    });

                    $('#ddlQuestion').trigger('change.select2'); // Refresh dropdown
                },
                error: function (xhr, status, error) {
                    console.error(xhr.responseText);
                }
            });

        }

        function loadOptions(questionId) {
            $.ajax({
                type: "POST",
                url: "/Pages/OptionRef.aspx/GetOptions",
                data: JSON.stringify({ questionId: questionId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var options = JSON.parse(response.d);
                    $('#tblOptionsData tbody').empty(); // Clear previous rows

                    $.each(options, function (index, option) {
                        var dropdownOptionsHTML = '<option value="-1">--Seleziona--</option>'; // Add --Select-- option

                        // Populate dropdown options
                        $.each(options, function (idx, opt) {
                            dropdownOptionsHTML += '<option value="' + opt.optionId + '">' + opt.optionName + '</option>';
                        });

                        // Create a new row with a dropdown containing all options
                        var newRow = '<tr>' +
                            '<td class="d-none">' + option.optionId + '</td>' +
                            '<td>' + (index + 1) + '</td>' +
                            '<td>' + option.optionName + '</td>' +
                            '<td>' + option.optionValue + '</td>' +

                            '<td>' +

                            '<select class="form-select form-select-sm">' + dropdownOptionsHTML + '</select>' +
                            '</td>' +
                            '</tr>';

                        // Append new row to the table
                        var $newRow = $(newRow);
                        $('#tblOptionsData tbody').append($newRow);

                        // Set the selected option based on refOptionId or default to "--Select--"
                        var $select = $newRow.find('select');
                        if (option.refOptionId) {
                            $select.val(option.refOptionId);
                        } else {
                            $select.val(-1); // Set to "--Select--"
                        }

                        // Attach change event listener to the dropdown
                        $select.change(function () {
                            var selectedOptionId = $(this).val();
                            var rowOptionId = $(this).closest('tr').find('.d-none').text();

                            if (selectedOptionId == rowOptionId) {
                                showAlert('Hai già selezionatp questa risposta per questa riga', 'danger');
                                $(this).val(-1); // Reset to "--Select--"
                            }
                        });
                    });
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
            }
        }
        function saveData() {
            // Iterate over each row in the table
            $('#tblOptionsData tbody tr').each(function () {
                var optionId = $(this).find('td:eq(0)').text(); // Get the optionId from the first column
                var dropdownValue = $(this).find('select').val(); // Get the selected value from the dropdown

                // Send data for each row to the server via AJAX
                $.ajax({
                    type: "POST",
                    url: "/Pages/OptionRef.aspx/SaveData",
                    data: JSON.stringify({
                        optionId: optionId,
                        dropdownValue: dropdownValue
                    }),

                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        showAlert('Dati inseriti correttamente', 'update');

                        // Handle success response for each row
                    },
                    error: function (xhr, status, error) {
                        console.error(xhr.responseText);
                        // Handle error response for each row
                    }
                });
            });
        }




    </script>

</asp:Content>
