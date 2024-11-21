<%@ Page Title="" Language="C#" MasterPageFile="~/Template/ValuMaster.Master" AutoEventWireup="true" CodeBehind="ViewExpectedQuesForSurvey.aspx.cs" Inherits="VALUQuest.Pages.ViewExpectedQuesForSurvey" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <style>
        .highlighted-node {
            background-color: #fff9cc !important; /* Lighter yellow */
        }

        #toggleExpandCollapseBtn {
    display: none; /* Hide the button initially */
}
    </style>
    <div class="row">
        <div class="col-12">
            <div class="page-title-box">
                <h4 class="page-title">Anteprima questionario</h4>
            </div>
        </div>

        <div id="msgAlert"></div>
        <input type="hidden" id="hiddenBlockId">

        <!-- BMI Value Input -->
        <div class="row">
            <div class="col-md-3">
                <div class="form-group">
                    <label for="heightInput">Altezza (in cm):</label>
                    <input type="text" id="heightInput" class="form-control" >
                </div>
            </div>
            <div class="col-md-3">
                <div class="form-group">
                    <label for="weightInput">Peso (in kg):</label>
                    <input type="text" id="weightInput" class="form-control">
                </div>
            </div>

            <div class="col-md-3">
                <div class="form-group" style="margin-top: 20px;">
                    <button id="loadTreeButton" class="btn btn-primary" type="button" onclick="loadFancyTree()">Visulizza</button>
                </div>
            </div>
        </div>
   <div class="row">
    <div class="col-md-3">
        <div class="form-group" style="margin-top: 20px;">
            <label id="bmiLabel" style="font-size: 24px; font-weight: bold; color: black;">BMI: </label>
            <span id="bmiValue" style="font-size: 24px; font-weight: bold; color: red;">N/A</span>
        </div>
    </div>
</div>
``


        <!-- FancyTree Container -->
        <div class="row">

            <div class="col-12 mb-3">
        <button id="toggleExpandCollapseBtn" class="btn btn-primary">
    <i class="fa fa-plus"></i> Expand All
</button>
    </div>
            <div class="col-12">
                <div class="card">
                    <div class="card-body">
                        <div id="jstree-1"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- jQuery Library -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>

    <!-- FancyTree CSS and JS -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/jquery.fancytree/2.38.0/skin-win8/ui.fancytree.min.css" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.fancytree/2.38.0/jquery.fancytree-all-deps.min.js"></script>

    <script>
        var $fancy = jQuery.noConflict(true); // Use a separate jQuery instance for FancyTree
</script>


    <script type="text/javascript">

        function loadFancyTree() {


            const height = parseFloat(document.getElementById("heightInput").value);
            const weight = parseFloat(document.getElementById("weightInput").value);

            if (!height || !weight || height <= 0 || weight <= 0) {
                alert("Please enter valid values for height and weight.");
                return;
            }

            // Apply the formula with the adjustment of -3 cm
            const heightInM = (height - 3) / 100;
            const bmiValue = weight / (heightInM * heightInM);

            document.getElementById("bmiValue").innerText = bmiValue.toFixed(2);

            heightInput.value = "";
            weightInput.value = "";

            // Make AJAX call to fetch tree data based on BMI value
            $.ajax({
                type: "POST",
                url: "/Pages/ViewExpectedQuesForSurvey.aspx/GetSurveyQuestionsTree",
                contentType: "application/json; charset=utf-8",
                data: JSON.stringify({ bmiValue: bmiValue }),
                dataType: "json",
                success: function (response) {
                    //console.log(response.d);
                    initializeFancyTree(response.d);
                    $('#toggleExpandCollapseBtn').show();
                },
                error: function (xhr, status, error) {
                    console.error(xhr.responseText);
                }
            });
        }

        function initializeFancyTree(treeData) {
    // Assign icons and apply highlight only to nodes that have children
    treeData.forEach(question => {
        question.icon = false; // Remove icon for question level

        // Check if the question has options, and if any option has child questions
        if (question.children && question.children.some(option => option.children && option.children.length > 0)) {
            question.extraClasses = "highlighted-node"; // Highlight only if it has child questions
        }

        question.children.forEach(option => {
            option.icon = "fa fa-cog"; // Icon for option level

            // Only apply highlight if the option has child questions
            if (option.children && option.children.length > 0) {
                option.extraClasses = "highlighted-node";
            }

            option.children.forEach(childQuestion => {
                childQuestion.icon = false; // Remove icon for child question level
                // No highlight for child questions as they do not have further children
            });
        });
    });

    // Initialize FancyTree with structured data
    $fancy("#jstree-1").fancytree({
        source: treeData,
        checkbox: false,
        selectMode: 3,
        clickFolderMode: 2,
        extensions: ["glyph"],
        glyph: {
            map: {
                doc: "fa fa-file-o",
                docOpen: "fa fa-file",
                checkbox: "fa fa-square-o",
                checkboxSelected: "fa fa-check-square-o",
                checkboxUnknown: "fa fa-square",
                dragHelper: "fa fa-arrow-right",
                dropMarker: "fa fa-long-arrow-right",
                error: "fa fa-exclamation-triangle",
                expanderClosed: "fa fa-caret-right",
                expanderOpen: "fa fa-caret-down",
                folder: "fa fa-folder",
                folderOpen: "fa fa-folder-open",
                loading: "fa fa-spinner fa-pulse"
            }
        }
    });

    // Add event listener for the toggle button
    $('#toggleExpandCollapseBtn').off('click').on('click', function () {
        let tree = $fancy("#jstree-1").fancytree("getTree");
        let isExpanded = $(this).text().includes("Collapse");

        tree.visit(function (node) {
            node.setExpanded(!isExpanded);
        });

        // Toggle the button text, icon, and color
        if (isExpanded) {
            $(this).html('<i class="fa fa-plus"></i> Expand All');
            $(this).removeClass('btn-danger').addClass('btn-primary');
        } else {
            $(this).html('<i class="fa fa-minus"></i> Collapse All');
            $(this).removeClass('btn-primary').addClass('btn-danger');
        }
    });
}

    </script>


</asp:Content>
