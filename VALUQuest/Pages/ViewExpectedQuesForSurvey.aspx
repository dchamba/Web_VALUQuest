    <%@ Page Title="" Language="C#" MasterPageFile="~/Template/ValuMaster.Master" AutoEventWireup="true" CodeBehind="ViewExpectedQuesForSurvey.aspx.cs" Inherits="VALUQuest.Pages.ViewExpectedQuesForSurvey" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <style>
      

        .highlighted-row {
        background-color: #fff9cc !important; /* Light yellow */
    }

        #toggleExpandCollapseBtn {
            display: none; /* Hide the button initially */
        }

        #treeContainer {
            width: 100%;
            height: calc(100vh - 150px); /* Adjust based on your requirement */
            overflow-y: auto; /* Enable vertical scrolling */
            overflow-x: hidden; /* Prevent horizontal scrolling */
            border: 1px solid #ccc; /* Optional: Adds a border */
            border-radius: 5px; /* Optional: Rounds the corners */
            background-color: #f9f9f9; /* Optional: Light background for contrast */
            padding: 10px; /* Optional: Adds spacing inside the container */
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
                    <input type="text" id="heightInput" class="form-control">
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
                    <button id="loadTreeButton" class="btn btn-primary" type="button" >Visualizza</button>
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
        <div class="row mb-3">
               <div class="col-md-10">
                   </div>
            <div class="col-md-2">
                <button id="toggleExpandCollapseBtn" class="btn btn-primary">
                    <i class="fa fa-plus"></i>Espandi
                </button>
            </div>

             </div>
         <div class="row">
            <div class="col-12">
                <div class="card">
                    <div class="card-body">


                        <div id="treeContainer" style="width: 100%; height: 500px; overflow-y: auto; border: 1px solid #ccc; padding: 10px;">
                            <div id="jstree-1"></div>
                        </div>



                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- jQuery Library -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>

    <!-- FancyTree Core CSS and JS -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/jquery.fancytree/2.38.0/skin-win8/ui.fancytree.min.css" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.fancytree/2.38.0/jquery.fancytree-all-deps.min.js"></script>

    <!-- Include FancyTree DnD extension if separate -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.fancytree/2.38.0/jquery.fancytree.dnd.min.js"></script>

    <script>
        var $fancy = jQuery.noConflict(true); // Use a separate jQuery instance for FancyTree
</script>

    <script type="text/javascript">



        function loadFancyTree() {


            const heightInput = document.getElementById("heightInput").value.trim();
            const weightInput = document.getElementById("weightInput").value.trim();

            // Regular expression to match valid numeric and decimal numbers
            const validNumberRegex = /^\d+(\.\d+)?$/;

            // Check if the input values are valid
            if (!validNumberRegex.test(heightInput) || !validNumberRegex.test(weightInput)) {
                alert("Inserire valori corretti per altezza (cm) e peso (kg)");
                return;
            }



            const height = parseFloat(document.getElementById("heightInput").value);
            const weight = parseFloat(document.getElementById("weightInput").value);

            if (!height || !weight || height <= 0 || weight <= 0) {
                alert("Inserisci valori validi per altezza e peso.");
                return;
            }

            // Apply the formula with the adjustment of -3 cm
            const heightInM = (height - 3) / 100;
            const bmiValue = weight / (heightInM * heightInM);

            document.getElementById("bmiValue").innerText = bmiValue.toFixed(2);


            // Make AJAX call to fetch tree data based on BMI value
            $.ajax({
                type: "POST",
                url: "/Pages/ViewExpectedQuesForSurvey.aspx/GetSurveyQuestionsTree",
                contentType: "application/json; charset=utf-8",
                data: JSON.stringify({ bmiValue: bmiValue }),
                dataType: "json",
                success: function (response) {
                   let treeData = typeof response.d === "string" ? JSON.parse(response.d) : response.d;

                     console.log(treeData);
                    initializeFancyTree(treeData);
                    $('#toggleExpandCollapseBtn').show();
                },
                error: function (xhr, status, error) {
                    console.error(xhr.responseText);
                }
            });
        }

        function initializeFancyTree(treeData) {

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
                },

                
  renderNode: function(event, data) {
            var node = data.node;
         
       if (node.getLevel() === 1) { // Root nodes only
                if (node.data.treeNodeElement) {
                    $(node.span).css({
                        "background-color": "#fff9cc", // Highlight color
                    });
                }
            }

        },

            });

           

            let tree = $fancy("#jstree-1").fancytree("getTree");
            let expandQueue = []; // Queue to hold only nodes with children

            // Function to initialize the queue with nodes that have children
            function initializeExpandQueue() {
                expandQueue = []; // Clear the queue
                tree.visit(function (node) {
                    if (node && node.hasChildren() && !node.expanded) {
                        expandQueue.push(node); // Add only nodes with children that are not already expanded
                    }
                });
            }

            // Initialize the queue on page load
            initializeExpandQueue();

            // Add event listener for the toggle button
            $('#toggleExpandCollapseBtn').off('click').on('click', function () {
                if (expandQueue.length === 0) {
                    console.warn("No more nodes to expand!");
                    return;
                }

                // Expand the next valid node from the queue
                let node = expandQueue.shift(); // Get the next node from the queue
                if (node) {
                    node.setExpanded(true).done(function () {
                        console.log(`Node with key ${node.key} expanded.`);

                        // Reinitialize the queue to ensure the next click processes correctly
                        initializeExpandQueue();
                    });
                } else {
                    console.warn("Next node in the queue is invalid or already expanded.");
                }
            });
        }


                   function reloadTree() {

                            const heightInput = document.getElementById("heightInput").value.trim();
            const weightInput = document.getElementById("weightInput").value.trim();

            // Regular expression to match valid numeric and decimal numbers
            const validNumberRegex = /^\d+(\.\d+)?$/;

            // Check if the input values are valid
            if (!validNumberRegex.test(heightInput) || !validNumberRegex.test(weightInput)) {
                alert("Inserire valori corretti per altezza (cm) e peso (kg)");
                return;
            }



            const height = parseFloat(document.getElementById("heightInput").value);
            const weight = parseFloat(document.getElementById("weightInput").value);

            if (!height || !weight || height <= 0 || weight <= 0) {
                alert("Inserisci valori validi per altezza e peso.");
                return;
            }

            // Apply the formula with the adjustment of -3 cm
            const heightInM = (height - 3) / 100;
            const bmiValue = weight / (heightInM * heightInM);

            document.getElementById("bmiValue").innerText = bmiValue.toFixed(2);


            // Make AJAX call to fetch tree data based on BMI value
            $.ajax({
                type: "POST",
                url: "/Pages/ViewExpectedQuesForSurvey.aspx/GetSurveyQuestionsTree",
                contentType: "application/json; charset=utf-8",
                data: JSON.stringify({ bmiValue: bmiValue }),
                dataType: "json",
                success: function (response) {
                   let treeData = typeof response.d === "string" ? JSON.parse(response.d) : response.d;


                                        // Destroy the existing tree to avoid issues during re-initialization
                    $fancy("#jstree-1").fancytree("destroy");

                    initializeFancyTree(treeData);
                    $('#toggleExpandCollapseBtn').show();
                },
                error: function (xhr, status, error) {
                    console.error(xhr.responseText);
                }
            });
        }


        let isFirstClick = true; // Flag to track the first click

function handleButtonClick() {
    if (isFirstClick) {
        loadFancyTree();
        isFirstClick = false; // Update the flag after the first click
    } else {
        reloadTree();
    }
        }

        document.getElementById("loadTreeButton").addEventListener("click", handleButtonClick);

    </script>


</asp:Content>
