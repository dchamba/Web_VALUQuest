<%@ Page Title="" Language="C#" MasterPageFile="~/Template/ValuMaster.Master" AutoEventWireup="true" CodeBehind="Ramification.aspx.cs" Inherits="VALUQuest.Pages.Ramification" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

      <style>
        .add-node-btn {
            background-color: transparent;
            border: none;
            font-size: 12px; /* Smaller font size */
            cursor: pointer;
            color: #007bff; /* Blue color to match Bootstrap's primary color */
            padding: 2px 4px; /* Reduce padding */
            margin-left: 5px; /* Add some spacing from the text */
        }

            .add-node-btn:hover {
                color: #0056b3; /* Darker blue on hover */
            }

        .custom-add-btn {
            border: none; /* Remove border */
            background: transparent; /* Transparent background */
            padding: 0; /* Remove padding for a smaller size */
            font-size: 0.8em; /* Adjust the font size to make it smaller */
            cursor: pointer; /* Change cursor to pointer for better UX */
        }

        .custom-delete-btn {
            background: none; /* Remove the button background */
            border: none; /* Remove the border */
            color: red; /* Make the icon red */
            cursor: pointer; /* Change the cursor to a pointer when hovering */
            padding: 0; /* Remove padding for a tighter appearance */
        }

            .custom-delete-btn i {
                font-size: 14px; /* Adjust the icon size to make it smaller */
            }
    </style>


    <div class="row">
        <div class="col-12">
            <div class="page-title-box">
                <h4 class="page-title">Ramificazione Domande</h4>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-12">
            <div class="card">
                <div class="card-body">
                    <!-- First Row: Single Select for Questions -->




                    <div class="row">
                        <div class="col-md-12">


                            <div class="tree-controls mb-3">
                                <button id="toggleExpandCollapseBtn" class="btn btn-primary">
                                    <i class="fa fa-plus"></i>Expand All
   
                                </button>
                            </div>


                            <div id="treeContainer">

                                <div id="questionTree"></div>
                            </div>


                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>



    <!-- Hidden inputs to store optionId and questionId -->
    <input type="hidden" id="hiddenOptionId" />
    <input type="hidden" id="hiddenQuestionId" />
    <input type="hidden" id="hiddenFatherId" />

    <div id="masterModal" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="fullWidthModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-full-width">
            <div class="modal-content">
                <div class="modal-header">
                    <h4 class="modal-title" id="fullWidthModalLabel">Master Question</h4>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-hidden="true"></button>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="col-md-6">
                            <label class="form-label">Blocco</label>
                            <select id="ddlBlock" class="form-control form-control-sm" onchange="changeCategory(this.value, -1)"></select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Categoria</label>
                            <select id="ddlCategory" class="form-control form-control-sm" onchange="loadQuestions()"></select>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-12">
                            <label class="form-label">Domanda</label>
                            <select class="form-control form-control-sm" id="ddlQuestions"></select>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-primary" onclick="addMasterQuestion()">Save changes</button>
                </div>
            </div>
            <!-- /.modal-content -->
        </div>
        <!-- /.modal-dialog -->
    </div>


    <div id="childModal" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="childfullWidthModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-full-width">
            <div class="modal-content">
                <div class="modal-header">
                    <h4 class="modal-title" id="childfullWidthModalLabel">Child Questions</h4>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-hidden="true"></button>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="col-md-12">
                            <label class="form-label">Select Questions</label>
                            <select id="ddlMultiQuestions" class="select2 form-control select2-multiple" data-toggle="select2" multiple="multiple" data-placeholder="Choose ..."></select>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-primary" onclick="addChildQuestions()">Save changes</button>
                </div>
            </div>
            <!-- /.modal-content -->
        </div>
        <!-- /.modal-dialog -->
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

    <script>

        $(document).ready(function () {

            // If using other messages like save success
            var saveMessage = sessionStorage.getItem('saveSuccessMessage');
            if (saveMessage) {
                showAlert(saveMessage, 'update'); // Display the message
                sessionStorage.removeItem('saveSuccessMessage'); // Clear the message from session storage
            }


            loadFancyTree();

            loadBlocks();

            $('#ddlBlock').change(function () {

                var blockId = document.getElementById('ddlBlock').value;
                changeCategory(blockId, -1);

            });

            loadMultiSelectQuestions();
        });



        function loadFancyTree() {
            $.ajax({
                type: "POST",
                url: "/Pages/Ramifcation.aspx/GetQuestionTreeData",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    let treeData = typeof response.d === "string" ? JSON.parse(response.d) : response.d;
                    console.log("Tree Data JSON:", JSON.stringify(treeData, null, 2)); // Log full tree data
                    initializeFancyTree(treeData);
                },
                error: function (xhr, status, error) {
                    console.error("Error loading tree data:", xhr.responseText);
                }
            });
        }

   function initializeFancyTree(treeData) {
            $fancy("#questionTree").fancytree({
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

                renderNode: function (event, data) {
                    var node = data.node;

                    console.log("Node data:", node.data);


                    var $span = $(node.span);

                    // Add a "+" button to the "Ramification" node or any option node
                    if ((node.key === "root_0" || node.data.isOption) && !$span.find(".add-node-btn").length) {
                        $("<button>", {
                            html: '<i class="fa fa-plus"></i>',
                            class: "add-node-btn custom-add-btn ms-2",
                            click: function (e) {
                                e.stopPropagation(); // Prevent default node click behavior
                                if (node.key === "root_0") {
                                    $('#masterModal').modal('show'); // Show the master modal for the root node
                                } else {


                                      const optionId = node.data.optionId || null;
        const questionId = node.parent ? node.parent.data.questionId : null; // Retrieve questionId from parent node
        const fatherId = node.data.fatherId || null;

        if (!optionId) console.error("Option ID is missing!");
        if (!questionId) console.error("Question ID is missing!");
        if (!fatherId) console.error("Father ID is missing!");

                                    openChildModal(optionId, questionId, fatherId);
                                }
                            }
                        }).appendTo($span);
                    }

                  if (!node.data.isOption && node.children && node.children.length > 0 && !$span.find(".delete-node-btn").length) {
    $("<button>", {
        html: '<i class="fa fa-trash"></i>',
        class: "delete-node-btn custom-delete-btn ms-2",
        click: function (e) {
            e.stopPropagation(); // Prevent default node click behavior
            // Collect all questionTreeIds of the clicked node and its child nodes
            const allIds = collectChildQuestionTreeIds(node);
            confirmDeleteNode(allIds);
        }
    }).appendTo($span);
}
                }


            });

            // Add event listener for the toggle button
            $('#toggleExpandCollapseBtn').off('click').on('click', function () {
                let tree = $fancy("#questionTree").fancytree("getTree");
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

            // Helper function to collect questionTreeIds of the clicked node and all its child nodes recursively
            function collectChildQuestionTreeIds(node) {
                let ids = [];

                // Add the current node's questionTreeId if it exists
                if (node.data && node.data.questionTreeId) {
                    ids.push(node.data.questionTreeId);
                }

                // Recursively add the questionTreeIds of child nodes
                if (node.children) {
                    node.children.forEach(child => {
                        ids = ids.concat(collectChildQuestionTreeIds(child));
                    });
                }

                return ids;
            }
        }

// Helper function to find the root master questionId for a given node
function getRootMasterQuestionId(node) {
    let rootQuestionId = null;
    let currentNode = node;

    while (currentNode && currentNode.parent) {
        if (currentNode.parent.key === "root_0") {
            rootQuestionId = currentNode.data.questionId;
            break;
        }
        currentNode = currentNode.parent;
    }
    return rootQuestionId;
}




        function confirmDeleteNode(questionTreeIds) {
            if (questionTreeIds.length > 0) {
                const userConfirmed = confirm(`Are you sure you want to delete the following ramification?`);
                if (userConfirmed) {
                    // Track how many deletions have been processed
                    let processedCount = 0;

                    // Iterate over the questionTreeIds array and call the stored procedure for each ID
                    questionTreeIds.forEach((questionTreeId, index) => {
                        deleteNodeFromDatabase(questionTreeId, function () {
                            processedCount++;

                            // Check if all nodes have been processed
                            if (processedCount === questionTreeIds.length) {
                                alert('Node(s) have been successfully deleted');
                                reloadTree(); // Reload the tree once after all deletions
                            }
                        });
                    });
                }
            } else {
                console.error("No valid QuestionTreeIds found to delete.");
            }
        }


        function deleteNodeFromDatabase(questionTreeId, callback) {
            $.ajax({
                type: "POST",
                url: "/Pages/Ramifcation.aspx/DeleteQuestionNode", // Ensure this matches your WebMethod URL
                contentType: "application/json; charset=utf-8",
                data: JSON.stringify({
                    questionTreeId: questionTreeId
                }),
                dataType: "json",
                success: function (response) {
                    if (response.d === "success") {
                        console.log(`Node with QuestionTreeId ${questionTreeId} has been successfully deleted`);
                    } else {
                        console.error(`Failed to delete node with QuestionTreeId ${questionTreeId}: ${response.d}`);
                    }

                    // Call the callback function to indicate completion
                    if (callback) callback();
                },
                error: function (xhr, status, error) {
                    console.error(`Error occurred while deleting node with QuestionTreeId ${questionTreeId}: ${xhr.responseText}`);

                    // Call the callback function to indicate completion even if there was an error
                    if (callback) callback();
                }
            });
        }

        function reloadTree() {
            $.ajax({
                type: "POST",
                url: "/Pages/Ramifcation.aspx/GetQuestionTreeData", // Ensure this matches your WebMethod URL for fetching tree data
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    let treeData = typeof response.d === "string" ? JSON.parse(response.d) : response.d;

                    // Destroy the existing tree to avoid issues during re-initialization
                    $fancy("#questionTree").fancytree("destroy");

                    // Re-initialize the tree with the new data
                    initializeFancyTree(treeData);
                },
                error: function (xhr, status, error) {
                    console.error("Error occurred while reloading the tree: " + xhr.responseText);
                }
            });
        }

        // Call loadFancyTree when the document is ready



        function addMasterQuestion() {
            var questionId = $("#ddlQuestions").val(); // Get the selected questionId from the dropdown

            if (!questionId) {
                showAlert('Please select a question to add.', 'danger');
                return;
            }

            // Proceed with AJAX call to add the question without duplication check
            $.ajax({
                type: "POST",
                url: "/Pages/Ramifcation.aspx/InsertHierarchicalQuestion",
                data: JSON.stringify({ questionId: questionId, parentOptionId: null, parentQuestionId: null }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d === "success") {
                        alert("Master question added successfully");
                        $('#masterModal').modal('hide');

                        // Reload the page to show the updated data
                        location.reload();
                    } else {
                        showAlert('Failed to add the question: ' + response.d, 'danger');
                    }
                },
                error: function (error) {
                    console.log("Error adding question:", error);
                    showAlert('An error occurred while adding the question.', 'danger');
                }
            });
        }


        function openChildModal(optionId, questionId, fatherId) {
            console.log("Opening child modal with values:");
            console.log("Option ID:", optionId || "No Option");
            console.log("Question ID:", questionId || "No Question");
            console.log("Father ID:", fatherId || "No Father");

            // Set the hidden fields with the provided values
            $('#hiddenOptionId').val(optionId);
            $('#hiddenQuestionId').val(questionId);
            $('#hiddenFatherId').val(fatherId);

            // Open the child modal
            $('#childModal').modal('show');
        }

        function addChildQuestions() {
            var parentOptionId = $('#hiddenOptionId').val();
            var parentQuestionId = $('#hiddenQuestionId').val();
            var fatherId = $('#hiddenFatherId').val();

            var selectedQuestionIds = $('#ddlMultiQuestions').val();
            console.log("Selected Question IDs:", selectedQuestionIds);

            if (!selectedQuestionIds || !parentOptionId || !parentQuestionId || !fatherId) {
                alert("Please ensure all fields are filled.");
                return;
            }

            $.ajax({
                type: "POST",
                url: "/Pages/Ramifcation.aspx/InsertChildQuestions",
                data: JSON.stringify({
                    parentOptionId: parseInt(parentOptionId),
                    parentQuestionId: parseInt(parentQuestionId),
                    fatherId: parseInt(fatherId),
                    questionIds: selectedQuestionIds.map(id => parseInt(id))
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d === "success") {
                        alert("Child questions added successfully!");
                        $('#childModal').modal('hide');
                        location.reload();
                    } else {
                        alert("Error adding child questions: " + response.d);
                    }
                },
                error: function (xhr, status, error) {
                    console.error("Error adding child questions:", xhr.responseText);
                }
            });
        }







        function loadBlocks() {
            $.ajax({
                type: "POST",
                url: "/Pages/Question.aspx/GetBlock",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d);
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
                    url: "/Pages/Question.aspx/GetCategories",
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

        // Load questions based on the selected category
        function loadQuestions() {
            var selectedCategoryId = $('#ddlCategory').val();
            $.ajax({
                type: "POST",
                url: "/Pages/Ramifcation.aspx/GetQuestionsByCategory",
                data: JSON.stringify({ categoryId: selectedCategoryId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d);
                    var $ddlQuestions = $('#ddlQuestions');
                    $ddlQuestions.empty().append('<option value="-1" selected disabled>Select Question</option>');
                    $.each(data, function (index, item) {
                        $ddlQuestions.append($('<option>', {
                            value: item.questionId,
                            text: item.questionName
                        }));
                    });
                },
                error: function (xhr, status, error) {
                    console.error(xhr.responseText);
                }
            });
        }






        var allQuestions = {}; // To store all the question data by category

        // Function to load all multi-select questions grouped by category
        function loadMultiSelectQuestions() {
            $.ajax({
                type: "POST",
                url: "/Pages/Ramifcation.aspx/GetQuestions",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    console.log('Loading new questions...');
                    var data = JSON.parse(response.d);
                    allQuestions = {}; // Reset all question data

                    var $multiSelect = $('#ddlMultiQuestions');
                    $multiSelect.empty(); // Clear existing options

                    // Group questions by category and store in allQuestions
                    $.each(data, function (index, item) {
                        if (!allQuestions[item.categoryName]) {
                            allQuestions[item.categoryName] = [];
                        }
                        allQuestions[item.categoryName].push({
                            questionId: item.questionId,
                            questionName: item.questionName
                        });
                    });

                    populateMultiSelect(allQuestions);
                },
                error: function (xhr, status, error) {
                    console.error(xhr.responseText);
                }
            });
        }

        function populateMultiSelect(questionsByCategory) {
            var $multiSelect = $('#ddlMultiQuestions');
            $multiSelect.empty(); // Clear existing options

            // Populate options in the multi-select
            $.each(questionsByCategory, function (categoryName, questions) {
                var optgroup = $('<optgroup>', { label: categoryName });

                $.each(questions, function (index, question) {
                    optgroup.append($('<option>', {
                        value: question.questionId,
                        text: question.questionName
                    }));
                });

                $multiSelect.append(optgroup);
            });

            $('#multiSelectRow').show();
        }



    </script>





</asp:Content>
