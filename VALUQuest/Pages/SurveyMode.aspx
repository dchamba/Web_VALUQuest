<%@ Page Title="" Language="C#" MasterPageFile="~/Template/ValuMaster.Master" AutoEventWireup="true" CodeBehind="SurveyMode.aspx.cs" Inherits="VALUQuest.Pages.SurveyMode" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">


    <style>
    /* Container for the toggle */
    .switch {
        position: relative;
        display: inline-block;
        width: 60px; /* Adjust width */
        height: 34px;
    }

    /* Hide the default checkbox */
    .switch input {
        opacity: 0;
        width: 0;
        height: 0;
    }

    /* Slider */
    .slider {
        position: absolute;
        cursor: pointer;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background-color: #ccc; /* Default gray background for OFF */
        transition: 0.4s;
        border-radius: 34px; /* Make the slider rounded */
    }

    /* The circle inside the toggle */
    .slider:before {
        position: absolute;
        content: "";
        height: 26px;
        width: 26px;
        left: 4px;
        bottom: 4px;
        background-color: white;
        transition: 0.4s;
        border-radius: 50%;
    }

    /* ON state: Move the circle and change background to green */
    input:checked + .slider {
        background-color: green; /* Green background for ON */
    }

    input:checked + .slider:before {
        transform: translateX(26px); /* Move the circle to the right */
    }
</style>




    <div class="row">
        <div class="col-12">
            <div class="page-title-box">
                <h4 class="page-title">Impostazioni questionario</h4>
            </div>
        </div>
    </div>
    <div id="msgAlert"></div>
    <div class="row">
        <div class="col-12">
            <div class="card">
                <div class="card-body">
                    <div class="row mb-3">
                        <div class="col-md-10">
                            <label class="form-label">Stato attuale della modalità di sondaggio:</label>
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
                   
                        <div class="col-md-2 d-flex justify-content-center align-items-center">
                            <label class="switch">
                                <input type="checkbox" id="surveyToggle" onchange="toggleSurveyMode(this)">
                                <span class="slider round"></span>
                            </label>
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </div>
    <div class="row">
        <div class="col-12">
            <div class="card">
                <div class="card-body">
                    <div class="row mb-3">
                        <div class="col-md-10">
                            <label class="form-label">Versione attuale del sondaggio:</label>
                            <div class="alert alert-primary" role="alert">
                                <strong>
                                    <h3>
                                        <label id="lblSurveyVersion"></label>
                                    </h3>
                                     <h6>
                                        <label style="color:red" id="lblSurveyVersionDateTime"></label>
                                    </h6>
                                </strong>
                            </div>
                        </div>
                   
                        <div class="col-md-2 d-flex justify-content-center align-items-center">
                            <label class="switch">
                                <input type="checkbox" id="surveyVersionToggle" onchange="toggleSurveyVersion(this)">
                                <span class="slider round"></span>
                            </label>
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </div>
    <script src="../Scripts/jquery-3.3.1.js"></script>

    <script type="text/javascript">
    $(document).ready(function () {
        // Load the current survey mode status on page load
        loadSurveyStatus();
        loadSurveyVersion();
    });


    function loadSurveyStatus() {
        $.ajax({
            type: "POST",
            url: "/Pages/SurveyMode.aspx/GetSurveyStatus",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (response) {
                var data = JSON.parse(response.d); // Parse the JSON response

                $("#lblSurveyStatus").text(data[0].surveyModeName);

                const surveyToggle = document.getElementById("surveyToggle");

                // Set the toggle state based on the survey mode
                const surveyMode = parseInt(data[0].surveyMode);
                surveyToggle.checked = surveyMode === 1; // Checked if ON
            },
            error: function (xhr, status, error) {
                console.error(xhr.responseText);
            }
        });
        }

    function toggleSurveyMode(element) {
        const surveyMode = element.checked ? 1 : 0;

        // Send AJAX request to update the server
        $.ajax({
            type: "POST",
            url: "/Pages/SurveyMode.aspx/UpdateSurveyMode",
            data: JSON.stringify({ surveyMode: surveyMode }),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (response) {
                if (response.d === "success") {
                    loadSurveyStatus(); // Reload the survey status
                } else {
                    console.error("Error updating survey mode");
                }
            },
            error: function (xhr, textStatus, errorThrown) {
                console.error("Error updating survey mode:", xhr.responseText);
            }
        });
    }

    function loadSurveyVersion() {
        $.ajax({
            type: "POST",
            url: "/Pages/SurveyMode.aspx/GetSurveyVersion",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (response) {
                var data = JSON.parse(response.d); // Parse the JSON response

                $("#lblSurveyVersion").text(data[0]);

                const surveyToggle = document.getElementById("surveyVersionToggle");

                surveyToggle.checked = !data.includes("Stadard"); // Checked if ON
            },
            error: function (xhr, status, error) {
                console.error(xhr.responseText);
            }
        });
    }

    function toggleSurveyVersion(element) {
        const surveyVersion = element.checked ? 1 : 0;

        // Send AJAX request to update the server
        $.ajax({
            type: "POST",
            url: "/Pages/SurveyMode.aspx/UpdateSurveyVersion",
            data: JSON.stringify({ surveyVersion: surveyVersion }),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (response) {
                if (response.d === "success") {
                    loadSurveyVersion(); // Reload the survey status
                } else {
                    console.error("Error updating survey version");
                }
            },
            error: function (xhr, textStatus, errorThrown) {
                console.error("Error updating survey mode:", xhr.responseText);
            }
        });
    }
    </script>



</asp:Content>
