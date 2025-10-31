<%@ Page Title="Question Tree" Language="C#" MasterPageFile="~/Template/ValuMaster.Master" AutoEventWireup="true" CodeBehind="QuesTree1.aspx.cs" Inherits="VALUQuest.Pages.QuesTree1" %>

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

        .custom-category-label {
            padding: 5px 10px;
            background-color: #f9f9f9;
            border-bottom: 1px solid #ddd;
            font-size: 14px;
        }

        .add-button {
            color: #007bff;
            cursor: pointer;
            font-size: 12px;
            text-decoration: underline;
        }

            .add-button:hover {
                color: #0056b3;
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




                    <div class="row mb-3 align-items-center">
                        <!-- Left Button -->
                        <div class="col-md-6 d-flex justify-content-start">
                            <button id="btnAddMasterQuestion" class="btn btn-success" data-bs-toggle="modal" data-bs-target="#masterModal">
                                <i class="fa fa-plus"></i>Aggiungi nuova ramificazione
                            </button>
                        </div>
                        <!-- Right Button -->
                        <div class="col-md-6 d-flex justify-content-end">
                            <div class="tree-controls">
                                <button id="toggleExpandCollapseBtn" class="btn btn-primary">
                                    Expand Nodes
                                </button>
                            </div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-12">
                            <div id="treeContainer" style="width: 100%; height: 500px; overflow-y: auto; border: 1px solid #ccc; padding: 10px;">
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
    <input type="hidden" id="hiddenQuestionTreeId" />
    <input type="hidden" id="hiddenNodeLevel" />
    <input type="hidden" id="hiddenStartingQuestionTreeId" />
    <input type="hidden" id="hiddenHasChildNodes" />





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
                    <h4 class="modal-title" id="childfullWidthModalLabel">Domande figlie</h4>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-hidden="true"></button>
                </div>
                <div class="modal-body">


                    <div class="row">
                        <!-- New Category Dropdown -->
                        <div class="col-md-12">
                            <label class="form-label">Seleziona Categorie</label>
                            <select id="ddlCategorySelect" class="select2 form-control select2-multiple" multiple="multiple" data-placeholder="Seleziona Categorie">
                            </select>
                        </div>
                    </div>
                    <div class="row mt-3">
                        <div class="col-md-12">
                            <button type="button" class="btn btn-primary" onclick="fetchQuestionsByCategories()">Carica Domande</button>
                        </div>
                    </div>

                    <div class="row mt-3">
                        <div class="col-md-12">
                            <label class="form-label">Seleziona Domande</label>
                            <select id="ddlMultiQuestions" class="select2 form-control select2-multiple" data-toggle="select2" multiple="multiple" data-placeholder="Cerca ..."></select>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Chiudi</button>
                    <button type="button" class="btn btn-primary" onclick="addChildQuestions()">Salva</button>
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


            loadCategories();

             $('#ddlCategorySelect').select2({
        placeholder: 'Select Categories',
        width: '100%' // Ensure it spans the full width
            });

            // Clear dropdown selection when the modal is closed
    $('#childModal').on('hidden.bs.modal', function () {
        $('#ddlCategorySelect').val(null).trigger('change'); // Clear selected values
    });
        });



        function loadFancyTree() {
            $.ajax({
                type: "POST",
                url: "/Pages/QuesTree1.aspx/GetQuestionTreeData",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    let treeData = typeof response.d === "string" ? JSON.parse(response.d) : response.d;
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

                    //console.log("Node data:", node.data);


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

                                    const hasChildNodes = node.children && node.children.length > 0 ? 1 : 0;

                                    const questionTreeId = hasChildNodes
                                        ? (node.data.treeNodeElement.fatherQuestionTreeId || null)
                                        : (node.data.treeNodeElement.questionTreeId || null);
                                    const optionId = node.data.optionID || null;
                                    const questionId = node.parent ? node.parent.data.questionId : null; // Retrieve questionId from parent node
                                    const nodeLevel = node.data.treeNodeElement && node.data.treeNodeElement.nodeLevel != null
                                        ? node.data.treeNodeElement.nodeLevel
                                        : 0;

                                    const startingQuestionTreeId = node.data.treeNodeElement.startingQuestionTreeId || null;



                                    openChildModal(optionId, questionId, questionTreeId, nodeLevel, startingQuestionTreeId, hasChildNodes);
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
                                // alert('allIds '+allIds);
                                confirmDeleteNode(allIds);
                            }
                        }).appendTo($span);
                    }
                }


            });

            let tree = $fancy("#questionTree").fancytree("getTree");
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


            // Helper function to collect questionTreeIds of the clicked node and all its child nodes recursively
            function collectChildQuestionTreeIds(node) {
                let ids = new Set(); // Use a Set to store unique IDs

                // Add the current node's questionTreeId if it exists
                if (node.data && node.data.treeNodeElement && node.data.treeNodeElement.questionTreeId) {
                    ids.add(node.data.treeNodeElement.questionTreeId);
                }

                // Recursively process child nodes
                if (node.children) {
                    node.children.forEach(child => {
                        const childIds = collectChildQuestionTreeIds(child);
                        childIds.forEach(id => ids.add(id)); // Add all child IDs to the Set
                    });
                }

                return Array.from(ids); // Convert the Set back to an array before returning
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
                const userConfirmed = confirm(`Confermi di voler cancellare?`);
                if (userConfirmed) {
                    // Track how many deletions have been processed
                    let processedCount = 0;

                    // Iterate over the questionTreeIds array and call the stored procedure for each ID
                    questionTreeIds.forEach((questionTreeId, index) => {
                        deleteNodeFromDatabase(questionTreeId, function () {
                            processedCount++;

                            // Check if all nodes have been processed
                            if (processedCount === questionTreeIds.length) {
                                alert('Ramificazione inserita correttamente');
                                reloadTree(); // Reload the tree once after all deletions
                            }
                        });
                    });
                }
            } else {
                console.error("Nessuna domanda da cancellare.");
            }
        }

        function deleteNodeFromDatabase(questionTreeId, callback) {


            $.ajax({
                type: "POST",
                url: "/Pages/QuesTree1.aspx/DeleteQuestionNode", // Ensure this matches your WebMethod URL
                contentType: "application/json; charset=utf-8",
                data: JSON.stringify({
                    questionTreeId: questionTreeId
                }),
                dataType: "json",
                success: function (response) {
                    if (response.d === "success") {
                        console.log(`Il nodo(i) è stato eliminato con successo`);
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



        function addMasterQuestion() {
            var questionId = $("#ddlQuestions").val(); // Get the selected questionId from the dropdown

            if (!questionId) {
                showAlert('Seleziona una domanda da aggiungere', 'danger');
                return;
            }

            let masterQuestionIds = [];
            let tree = $fancy("#questionTree").fancytree("getTree");

            // Traverse only the top-level nodes (master questions)
            tree.rootNode.children.forEach(function (node) {
                if (node.data && node.data.questionId) {
                    masterQuestionIds.push(node.data.questionId);
                }
            });


            if (masterQuestionIds.includes(parseInt(questionId))) {
                alert("Domanda già presente nella ramificazione");
                return; // Stop further execution to prevent adding the question
            }


            // Proceed with AJAX call to add the question without duplication check
            $.ajax({
                type: "POST",
                url: "/Pages/QuesTree1.aspx/InsertHierarchicalQuestion",
                data: JSON.stringify({ questionId: questionId, parentOptionId: null, parentQuestionId: null }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d === "success") {
                        alert("Domanda padre aggiunta correttamente");
                        $('#masterModal').modal('hide');

                        // Reload the page to show the updated data
                        location.reload();
                    } else {
                        showAlert('Impossibile aggiungere la domanda: ' + response.d, 'danger');
                    }
                },
                error: function (error) {
                    console.log("Errore nell'aggiunta della domanda:", error);
                    showAlert('Si è verificato un errore durante l aggiunta della domanda.', 'danger');
                }
            });
        }


        function openChildModal(optionId, questionId, questionTreeId, nodeLevel, startingQuestionTreeId, hasChildNodes) {
            // Set the hidden fields with the provided values
            $('#hiddenOptionId').val(optionId);
            $('#hiddenQuestionId').val(questionId);
            $('#hiddenQuestionTreeId').val(questionTreeId);
            $('#hiddenNodeLevel').val(nodeLevel);
            $('#hiddenStartingQuestionTreeId').val(startingQuestionTreeId);
            $('#hiddenHasChildNodes').val(hasChildNodes);

            // Clear only the selected items in the multi-select, not the options
            $('#ddlMultiQuestions').val(null).trigger('change'); // This clears the selection without emptying the options


            // Open the child modal
            $('#childModal').modal('show');
        }

        function addChildQuestions() {
            var parentOptionId = $('#hiddenOptionId').val();
            var parentQuestionId = $('#hiddenQuestionId').val();
            var QuestionTreeId = $('#hiddenQuestionTreeId').val();
            var NodeLevel = $('#hiddenNodeLevel').val();
            var StartingQuestionTreeId = $('#hiddenStartingQuestionTreeId').val();
            var HasChildNodes = $('#hiddenHasChildNodes').val();



            var selectedQuestionIds = $('#ddlMultiQuestions').val();

            if (!selectedQuestionIds || !parentOptionId || !parentQuestionId || !QuestionTreeId || !NodeLevel || !StartingQuestionTreeId || !HasChildNodes) {
                alert("Assicurati che tutti i campi siano compilati.");
                return;
            }

            $.ajax({
                type: "POST",
                url: "/Pages/QuesTree1.aspx/InsertChildQuestions",
                data: JSON.stringify({
                    parentOptionId: parseInt(parentOptionId),
                    parentQuestionId: parseInt(parentQuestionId),
                    QuestionTreeId: parseInt(QuestionTreeId),
                    NodeLevel: parseInt(NodeLevel),
                    StartingQuestionTreeId: parseInt(StartingQuestionTreeId),
                    HasChildNodes: parseInt(HasChildNodes),
                    questionIds: selectedQuestionIds.map(id => parseInt(id))
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d === "success") {
                        alert("Domande secondarie aggiunte correttamente!");
                        $('#childModal').modal('hide');
                        location.reload();
                    } else {
                        alert("Errore nell'aggiunta delle domande secondarie: " + response.d);
                    }
                },
                error: function (xhr, status, error) {
                    console.error("Errore nell'aggiunta delle domande secondarie:", xhr.responseText);
                }
            });
        }



        function reloadTree() {
            $.ajax({
                type: "POST",
                url: "/Pages/QuesTree1.aspx/GetQuestionTreeData", // Ensure this matches your WebMethod URL for fetching tree data
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
                    console.error("Errore durante caricamento: " + xhr.responseText);
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
                url: "/Pages/QuesTree1.aspx/GetQuestionsByCategory",
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
                            text: item.questionId + ' - ' + item.questionName
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
                url: "/Pages/QuesTree1.aspx/GetQuestions",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
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

            // Populate options in the dropdown
            $.each(questionsByCategory, function (categoryName, questions) {
                var optgroup = $('<optgroup>', { label: categoryName });

                // Create "Add" anchor
                var addAnchor = $('<a>', {
                    text: 'Add',
                    href: '#',
                    style: 'float: right; text-decoration: none; color: blue; font-size: 12px;',
                    click: function (e) {
                        e.preventDefault(); // Prevent default anchor behavior
                        alert('Add clicked for category: ' + categoryName);

                        // Automatically select all questions under this category
                        $.each(questions, function (index, question) {
                            $multiSelect.find('option[value="' + question.questionId + '"]').prop('selected', true);
                        });

                        $multiSelect.trigger('change'); // Trigger change event if needed
                    }
                });

                // Add the category name and "Add" anchor
                var categoryHeader = $('<div>', {
                    style: 'display: flex; justify-content: space-between; align-items: center;'
                }).append(
                    $('<span>', { text: categoryName }), // Category name
                    addAnchor // Add anchor
                );

                // Append category header to the dropdown (as optgroup label)
                optgroup.append(categoryHeader);

                // Add questions under the category
                $.each(questions, function (index, question) {
                    optgroup.append($('<option>', {
                        value: question.questionId,
                        text: question.questionId + ' - ' + question.questionName 
                    }));
                });

                $multiSelect.append(optgroup);
            });

            $('#multiSelectRow').show();
        }



        function loadCategories() {


            $.ajax({
                type: "POST",
                url: "/Pages/QuesTree1.aspx/GetCategories", // WebMethod to fetch categories
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d);
                    var $categorySelect = $('#ddlCategorySelect');
                    $categorySelect.empty();

                    var $categorySelect = $('#ddlCategorySelect');
                    $categorySelect.empty(); // Clear existing options

                    // Populate categories
                    $.each(data, function (index, category) {
                        $categorySelect.append($('<option>', {
                            value: category.categoryId,
                            text: category.categoryName
                        }));
                    });

                    $categorySelect.trigger('change.select2');
                },
                error: function (xhr, status, error) {
                    console.error("Error loading categories:", xhr.responseText);
                }
            });
        }


        function fetchQuestionsByCategories() {



            var selectedCategories = $('#ddlCategorySelect').val(); // Get selected categories
            if (!selectedCategories || selectedCategories.length === 0) {
                alert("Please select at least one category.");
                return;
            }

            // Fetch questions for the selected categories
            $.ajax({
                type: "POST",
                url: "/Pages/QuesTree1.aspx/GetQuestionsByCategories",
                contentType: "application/json; charset=utf-8",
                data: JSON.stringify({ categoryIds: selectedCategories }), // Send selected categories to the server
                dataType: "json",
                success: function (response) {
                    var questions = JSON.parse(response.d); // Parse the JSON response
                    var $multiSelect = $('#ddlMultiQuestions');

                    // Add the fetched questions to the dropdown without clearing existing ones
                    $.each(questions, function (index, question) {
                        // Check if the question already exists in the dropdown
                        if ($multiSelect.find('option[value="' + question.questionId + '"]').length === 0) {
                            var option = $('<option>', {
                                value: question.questionId,
                                text: question.questionName,
                                selected: true // Automatically select the new question
                            });
                            $multiSelect.append(option);
                        } else {
                            // If the question already exists, ensure it's selected
                            $multiSelect.find('option[value="' + question.questionId + '"]').prop('selected', true);
                        }
                    });

                    // Trigger change to update the Select2 UI
                    $multiSelect.trigger('change');
                },
                error: function (xhr, status, error) {
                    console.error("Error fetching questions:", xhr.responseText);
                }
            });
        }




    </script>





</asp:Content>
