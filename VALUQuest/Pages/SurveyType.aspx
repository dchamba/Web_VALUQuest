<%@ Page Title="" Language="C#" MasterPageFile="~/Template/ValuMaster.Master" AutoEventWireup="true" CodeBehind="SurveyType.aspx.cs" Inherits="VALUQuest.Pages.SurveyType" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <div class="row">
        <div class="col-12">
            <div class="page-title-box">
                <h4 class="page-title">Survey Type</h4>
            </div>
        </div>
    </div>
    <div id="msgAlert"></div>
    <div class="row">
        <div class="col-12">
            <div class="card">
                <div class="card-body">
                    <div class="row mb-3">
                        <div class="col-md-12">
                            <label class="form-label">Current Status of Survey Type:</label>
                            <div class="alert alert-primary" role="alert">
                                <strong>
                                    <h3>
                                        <label id="lblSurveyStatus"></label>
                                    </h3>
                                     <h6>
                                        <label style="color:red" id="lblSurveyDateTime"></label>
                                    </h6>
                                </strong>
                            </div>
                        </div>
                   
                    </div>

                    <div class="row mb-3">
                        <div class="col-md-3">
                            <label class="form-label">Survey Type</label>
                            <select id="ddlSurveyType" class="form-select form-select-sm mb-3">
                                <option value="-1">Select</option>
                            </select>
                        </div>

                        <div class="col-md-3 align-self-end">
                            <button id="saveButton" class="btn btn-primary" type="button" onclick="saveData()">Save</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script src="../Scripts/jquery-3.3.1.js"></script>

    <script type="text/javascript"> 


        $(document).ready(function () {

            loadSurveyStatus();
            loadSurveyTypes();


        });
        function loadSurveyTypes() {

            $.ajax({
                type: "POST",
                url: "/Pages/SurveyType.aspx/GetSurveyType",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d); // Parse the JSON string to an object
                    $('#ddlSurveyType').empty().append('<option value="-1">--Select--</option>');
                    $.each(data, function (index, item) {
                        $('#ddlSurveyType').append($('<option>', {
                            value: item.surveyQuesTypeId,
                            text: item.surveyQuesTypeName
                        }));
                    });
                },
                error: function (xhr, status, error) {
                    console.error(xhr.responseText);
                }
            });

        }

          function loadSurveyStatus() {

            $.ajax({
                type: "POST",
                url: "/Pages/SurveyType.aspx/GetSurveyStatus",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {

                  var data = JSON.parse(response.d); // Parse the JSON string to an object
                 // Access the properties of the returned object
                    $("#lblSurveyStatus").text(data[0].surveyQuesTypeName);
                    $("#lblSurveyDateTime").text(data[0].surveyStatus);

                },
                error: function (xhr, status, error) {
                    console.error(xhr.responseText);
                }
            });

        }


          function saveData() {

            //if (!checkValues()) {
            //    return;
            //}

            var surveyQuesTypeId = $('#ddlSurveyType').val();
            

            // Data object to be sent in the AJAX request
            var data = {
                surveyQuesTypeId: surveyQuesTypeId,
            };


            setTimeout(function () {
                $.ajax({
                    type: "POST",
                    url: "/Pages/SurveyType.aspx/UpdateSurveyType",
                    data: JSON.stringify(data),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        if (response.d === "success") {
                            showAlert('Data updated successfully', 'update');
                            loadSurveyStatus();
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

        function checkValues() {
            var ddlSurveyTypeElement = document.getElementById("ddlSurveyType");
            var ddlSurveyType = ddlSurveyTypeElement ? ddlSurveyTypeElement.value : "";
            if (ddlSurveyType === "-1") {
                showAlert("Please select a Survey Type.", "danger");
                return false;
            }
        }
    </script>

</asp:Content>
