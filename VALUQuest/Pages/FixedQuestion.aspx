<%@ Page Title="" Language="C#" MasterPageFile="~/Template/ValuMaster.Master" AutoEventWireup="true" CodeBehind="FixedQuestion.aspx.cs" Inherits="VALUQuest.Pages.FixedQuestion" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <div class="row">
        <div class="col-12">
            <div class="page-title-box">
                <h4 class="page-title">Domande fisse</h4>
            </div>
        </div>
    </div>

    <div id="msgAlert"></div>
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

                        <%-- <div class="col-md-4">
                            <label class="form-label">Sottocategoria</label>
                            <!-- Label for Sub Category dropdown -->
                            <select id="ddlSubCategory" class="form-select form-select-sm">
                            </select>
                        </div>--%>
                    </div>

                    <div class="row">
                        <div class="col-md-3">
                            <button type="button" class="btn btn-primary btn-sm" style="margin-top: 28px;" id="searchButton">Cerca</button>
                        </div>
                    </div>



                    <div class="row">
                        <div class="col-md-12">
                            <div class="table-responsive">
                                <table id="tblQuestionsData" class="table table-sm table-centered mb-0">
                                    <thead>
                                        <tr>
                                            <th class="d-none">questionId</th>
                                            <th>N.</th>
                                            <th>Blocco</th>
                                            <th>Categoria</th>
                                            <th>Domanda</th>
                                            <th>Tipo di domanda</th>
                                            <th>Statico</th>
                                            <th>Order By</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                    </div>


                    <div class="row">
                        <div class="col-md-3">
                            <button type="button" class="btn btn-primary btn-sm" style="margin-top: 28px;" onclick="saveData()" id="saveButton">Salva</button>
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


            $('#ddlBlock').change(function () {

                var blockId = document.getElementById('ddlBlock').value;
                changeCategory(blockId, -1);

            });


            $('#ddlCategory').change(function () {

                var categoryId = document.getElementById('ddlCategory').value;

            });


            $('#searchButton').click(function () {
                var blockId = $('#ddlBlock').val();
                var categoryId = $('#ddlCategory').val();


                if ($('#ddlBlock option').length === 0) {
                    blockId = '-1';
                }


                if ($('#ddlCategory option').length === 0) {
                    categoryId = '-1';
                }




                // Make the AJAX call with selected values
                loadQuestions(blockId, categoryId);
            });

        });

        function loadBlocks() {

            $.ajax({
                type: "POST",
                url: "/Pages/FixedQuestion.aspx/GetBlock",
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
                    url: "/Pages/FixedQuestion.aspx/GetCategories",
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


        function saveData() {
            $('#tblQuestionsData tbody tr').each(function () {
                var questionId = $(this).find('td:eq(0)').text(); // Get questionId from the first column
                var isChecked = $(this).find('input[type="checkbox"]').prop('checked') ? 1 : -1; // Check if the checkbox is checked
                var orderBy = $(this).find('input.order-input').val(); // Get the value of Order By input

                // Send AJAX request
                $.ajax({
                    type: "POST",
                    url: "/Pages/FixedQuestion.aspx/UpdateFixedQuestion",
                    data: JSON.stringify({ questionId: questionId, isChecked: isChecked, orderBy: orderBy }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        // Handle success
                        showAlert('Dati inseriti correttamente', 'update');
                    },
                    error: function (xhr, status, error) {
                        console.error(xhr.responseText);
                    }
                });
            });
        }

    function loadQuestions(blockId, categoryId) {
    $.ajax({
        type: "POST",
        url: "/Pages/FixedQuestion.aspx/GetQuestions",
        data: JSON.stringify({ blockId: blockId, categoryId: categoryId }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            var data = JSON.parse(response.d);
            $('#tblQuestionsData tbody').empty();

            $.each(data, function (index, item) {
                var isChecked = item.isFixed === 1;
                var isFixedOrderByValue = item.isFixedOrderBy || ''; // Get the order value or an empty string if null

                var newRow = '<tr>' +
                    '<td class="d-none">' + item.questionId + '</td>' +
                    '<td>' + (index + 1) + '</td>' +
                    '<td>' + item.blockName + '</td>' +
                    '<td>' + item.categoryName + '</td>' +
                    '<td>' + item.questionName + '</td>' +
                    '<td>' + item.quesType + '</td>' +
                    '<td>' +
                    '<input type="checkbox" class="form-check-input question-checkbox" ' + (isChecked ? 'checked' : '') + '>' +
                    '</td>' +
                    '<td>' +
                    '<input type="text" class="form-control form-control-sm order-input" value="' + isFixedOrderByValue + '" ' + (isChecked ? '' : 'disabled') + '>' +
                    '</td>' +
                    '</tr>';

                $('#tblQuestionsData tbody').append(newRow);
            });

            // Attach change event to toggle the textbox based on checkbox state
            $('#tblQuestionsData tbody').on('change', '.question-checkbox', function () {
                var $checkbox = $(this);
                var $orderInput = $checkbox.closest('tr').find('.order-input'); // Find the corresponding Order By text box

                if ($checkbox.is(':checked')) {
                    $orderInput.prop('disabled', false); // Enable the text box
                } else {
                    $orderInput.prop('disabled', true); // Disable the text box
                    $orderInput.val(''); // Clear the text box value when unchecked
                }
            });
        },
        error: function (xhr, status, error) {
            console.error(xhr.responseText);
        }
    });
}


    </script>
</asp:Content>
