<%@ Page Title="" Language="C#" MasterPageFile="~/Template/ValuMaster.Master" AutoEventWireup="true" CodeBehind="QuestionsTreeNew.aspx.cs" Inherits="VALUQuest.Pages.QuestionsTreeNew" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">


    <div class="row">
        <div class="col-12">
            <div class="page-title-box">
                <h4 class="page-title">Ramificazione Domande</h4>
            </div>
        </div>
    </div>

    <div id="msgAlert"></div>
    <div class="row">
        <div class="col-12">
            <div class="card">
                <div class="card-body">
                    <!-- First Row: Single Select for Questions -->


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

                    <div class="row mb-3">
                        <div class="col-md-12">
                            <div class="col-lg-12">
                                <p class="mb-1 fw-bold text-muted">Question</p>
                                <select id="ddlQuestions" class="form-control select2" data-toggle="select2">
                                    <!-- Options will be dynamically populated here -->
                                </select>
                            </div>
                        </div>
                    </div>

                    <!-- Second Row: Radio Buttons -->
                    <div class="row mb-3">
                        <div class="col-md-12">
                            <div class="col-lg-12">
                                <div id="optionsContainer"></div>
                            </div>
                        </div>
                    </div>


                    <div class="row mb-3">
    <div class="col-md-4">
        <label class="form-label">Parent Option</label>
        <select id="ddlParentOption" class="form-select form-select-sm mb-3">
            <!-- Options will be populated dynamically -->
        </select>
    </div>
    <div class="col-md-4">
        <label class="form-label">Parent Question</label>
        <select id="ddlParentQuestion" class="form-select form-select-sm mb-3">
            <!-- Options will be populated dynamically -->
        </select>
    </div>
</div>

                    <!-- Third Row: Multi-select Dropdown (Populated after Radio Selection) -->
                    <div id="multiSelectRow" class="row mb-3">
                        <div class="col-md-12">
                            <div class="col-lg-12 d-flex justify-content-between align-items-center">
                                <p class="mb-1 fw-bold text-muted">Select Multiple Questions</p>
                                <!-- Delete All hyperlink aligned to the top-right corner -->
                                <a href="javascript:void(0);" id="deleteAllLink" onclick="deleteAllQuestions()" class="text-danger">Delete All</a>
                            </div>
                            <select id="ddlMultiSelect" class="select2 form-control select2-multiple" data-toggle="select2" multiple="multiple" data-placeholder="Choose ...">
                                <!-- Multi-select options will be dynamically populated here -->
                            </select>
                        </div>
                    </div>


                    <div class="row mb-3">
                        <div class="col-md-3 align-self-end">
                            <button id="saveButton" class="btn btn-primary" onclick="saveData()" type="button">Save</button>
                        </div>
                    </div>


                    <div class="row mb-3">
                        <div class="col-md-12 align-self-end">

                            <div id="fancytree"></div>
                        </div>
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
        $(document).ready(function () {

            var deleteMessage = sessionStorage.getItem('deleteSuccessMessage');
            if (deleteMessage) {
                showAlert(deleteMessage, 'update'); // Display the message
                sessionStorage.removeItem('deleteSuccessMessage'); // Clear the message from session storage
            }

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

            // Initially hide the multi-select
            $('#multiSelectRow').hide();

            $(document).on('change', 'input[name="customRadio"]', function () {
                var selectedOptionId = $(this).val(); // Get the selected optionId
                loadMultiSelectQuestions(selectedOptionId); // Call the function and pass optionId
            });
            // Search in category name or question text
            $('#categorySearch').on('input', function () {
                var searchText = $(this).val();
                filterQuestions(searchText); // Search by category name or question text
            });

            // Change event for the questions dropdown (ddlQuestions)
            $('#ddlQuestions').change(function () {
                var selectedQuestionId = $(this).val();
                if (selectedQuestionId != -1) {
                    loadOptions(selectedQuestionId); // Load radio buttons for the selected question
                }
            });

            // Load the questions dropdown on page load
            //            loadQuestions();

            $('#ddlCategory').change(function () {
                loadQuestions(); // Call loadQuestions when the category changes
            });

            $('#ddlBlock, #ddlCategory').change(function () {
                loadOptions(null); // Call loadOptions with null to clear options
            });

            $('#ddlBlock').change(function () {
                $('#ddlQuestions').val(null).trigger('change'); // Clear the Question dropdown
            });

        });


        function loadFancyTree() {
            $.ajax({
                type: "POST",
                url: "/Pages/QuestionsTreeNew.aspx/GetQuestionTreeData",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    initializeFancyTree(response.d);
                },
                error: function (xhr, status, error) {
                    console.error(xhr.responseText);
                }
            });
        }





      function initializeFancyTree(treeData) {
    // Assign custom icons for each level
    treeData.forEach(block => {
        block.icon = "fa fa-building"; // Icon for block level
        block.children.forEach(category => {
            category.icon = "fa fa-folder"; // Icon for category level
            category.children.forEach(question => {
                question.icon = "fa fa-question-circle"; // Icon for question level
                question.children.forEach(option => {
                    option.icon = "fa fa-cog"; // Icon for option level
                    option.children.forEach(childQuestion => {
                        childQuestion.icon = "fa fa-comment"; // Icon for child question level
                        // Add another level for the child question's options
                        if (childQuestion.children) {
                            childQuestion.children.forEach(childOption => {
                                childOption.icon = "fa fa-circle"; // Icon for child option level
                            });
                        }
                    });
                });
            });
        });
    });

    // Initialize FancyTree with structured data
    $fancy("#fancytree").fancytree({
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
}

        // Function to enter edit mode on double-click
        function enterEditMode(node) {
            // Retrieve the data hierarchy up to the root to set block, category, and question name
            let optionName = node.title;
            let questionName = node.getParent().title;
            let categoryName = node.getParent().getParent().title;
            let blockName = node.getParent().getParent().getParent().title;

            // Populate Block dropdown
            $("#ddlBlock").val(blockName).trigger("change");

            // Set a timeout or promise to wait for categories to load based on selected block
            setTimeout(() => {
                // Populate Category dropdown
                $("#ddlCategory").val(categoryName).trigger("change");

                // After category loads, populate the question dropdown
                setTimeout(() => {
                    $("#ddlQuestions").val(questionName).trigger("change");

                    // After setting the question dropdown, load the options and select the relevant option name
                    loadOptions($("#ddlQuestions").val());

                    setTimeout(() => {
                        // Select the specific option in the optionsContainer
                        $("#optionsContainer input[value='" + optionName + "']").prop("checked", true);

                        // Load the multi-select dropdown for the children questions of the selected option
                        loadMultiSelectQuestions(optionName);
                    }, 500);

                }, 500);
            }, 500);
        }




        function loadBlocks() {

            $.ajax({
                type: "POST",
                url: "/Pages/Question.aspx/GetBlock",
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


        // Function to load the questions dropdown (ddlQuestions)
        function loadQuestions() {
            // Get the selected categoryId from ddlCategory
            var selectedCategoryId = $('#ddlCategory').val();

            $.ajax({
                type: "POST",
                url: "/Pages/QuestionsTreeNew.aspx/GetQuestionsByCategory", // Updated WebMethod URL
                data: JSON.stringify({ categoryId: selectedCategoryId }), // Pass the selected categoryId as a parameter
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d);
                    var $ddlQuestions = $('#ddlQuestions');
                    $ddlQuestions.empty(); // Clear existing options

                    // Add the first "Select Question" option
                    $ddlQuestions.append($('<option>', {
                        value: -1, // Use -1 as a non-valid value
                        text: 'Select Question',
                        selected: true,
                        disabled: true // Make it non-selectable
                    }));
                    // Populate the ddlQuestions dropdown
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

        // Function to load all multi-select questions grouped by category and auto-select based on optionId
        function loadMultiSelectQuestions(optionId) {
            $.ajax({
                type: "POST",
                url: "/Pages/QuestionsTreeNew.aspx/GetQuestions", // Fetch all questions
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d);
                    allQuestions = {}; // Reset all question data

                    var $multiSelect = $('#ddlMultiSelect');
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

                    // Populate the multi-select dropdown
                    populateMultiSelect(allQuestions);

                    // After populating, fetch the questionIds that are already inserted in tbl_question_tree
                    loadSelectedQuestions(optionId);
                },
                error: function (xhr, status, error) {
                    console.error(xhr.responseText);
                }
            });
        }

        // Function to populate the multi-select dropdown grouped by categories
        function populateMultiSelect(questionsByCategory) {
            var $multiSelect = $('#ddlMultiSelect');
            $multiSelect.empty(); // Clear existing options

            // Loop through each category and populate the options in the multi-select dropdown
            $.each(questionsByCategory, function (categoryName, questions) {
                // Create optgroup for each category
                var optgroup = $('<optgroup>', { label: categoryName });

                // Add each question under its category
                $.each(questions, function (index, question) {
                    optgroup.append($('<option>', {
                        value: question.questionId,
                        text: question.questionName
                    }));
                });

                // Append the optgroup to the multi-select
                $multiSelect.append(optgroup);
            });

            $('#multiSelectRow').show(); // Ensure the multi-select is shown
        }

        // Function to load selected questions from tbl_question_tree and auto-select them in the multi-select dropdown
        function loadSelectedQuestions(optionId) {
            $.ajax({
                type: "POST",
                url: "/Pages/QuestionsTreeNew.aspx/GetQuestionIdsByOptionId", // WebMethod to get questionIds from tbl_question_tree
                data: JSON.stringify({ optionId: optionId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var selectedQuestionIds = response.d; // This will be an array of questionIds

                    // Toggle "Delete All" visibility based on whether there are selected question IDs
                    if (selectedQuestionIds && selectedQuestionIds.length > 0) {
                        $('#deleteAllLink').show(); // Show "Delete All" if there are selected questions
                    } else {
                        $('#deleteAllLink').hide(); // Hide "Delete All" if there are no selected questions
                    }

                    // Iterate through the multi-select options and auto-select matching questions
                    $('#ddlMultiSelect option').each(function () {
                        var questionId = $(this).val();
                        if (selectedQuestionIds.includes(parseInt(questionId))) {
                            $(this).prop('selected', true); // Select the option if it matches
                        }
                    });

                    // Refresh the select2 dropdown if you are using it
                    $('#ddlMultiSelect').trigger('change');
                },
                error: function (xhr, status, error) {
                    console.error(xhr.responseText);
                }
            });
        }
        // Function to filter based on category name or question name
        function filterQuestions(searchText) {
            var filteredCategories = {}; // Will hold categories that match the search term
            var matchedQuestions = {};   // Will hold individual questions that match the search term

            // Clear the multi-select before filtering
            var $multiSelect = $('#ddlMultiSelect');
            $multiSelect.empty(); // Clear existing options

            // Step 1: Check if search text matches any category name
            $.each(allQuestions, function (category, questions) {
                if (category.toLowerCase().includes(searchText.toLowerCase())) {
                    filteredCategories[category] = questions; // Add all questions in the matching category
                }
            });

            // Step 2: Check for individual questions that match the search term
            $.each(allQuestions, function (category, questions) {
                $.each(questions, function (index, question) {
                    if (question.questionName.toLowerCase().includes(searchText.toLowerCase())) {
                        if (!matchedQuestions[category]) {
                            matchedQuestions[category] = [];
                        }
                        matchedQuestions[category].push(question); // Add all matching individual questions
                    }
                });
            });

            // Step 3: Merge category and individual question matches (keep categories distinct)
            var finalFilteredResults = { ...filteredCategories }; // Start with matching categories

            // Now merge in matched individual questions without overwriting existing categories
            $.each(matchedQuestions, function (category, questions) {
                if (!finalFilteredResults[category]) {
                    finalFilteredResults[category] = questions; // Add new category if not already in finalFilteredResults
                } else {
                    finalFilteredResults[category] = finalFilteredResults[category].concat(questions); // Combine with existing category
                }
            });

            // Step 4: Populate the multi-select with the final combined results
            populateMultiSelect(finalFilteredResults);
        }

        // Function to populate multi-select with questions based on categories

        function saveData() {
            // Collect the selected option ID (assuming it's from a radio button)
            var optionId = $('input[name="customRadio"]:checked').val();

            // Collect the selected question IDs from the multi-select dropdown
            var selectedQuestionIds = [];
            $('#ddlMultiSelect option:selected').each(function () {
                selectedQuestionIds.push($(this).val());
            });

            // Get the selected question ID from the ddlQuestions dropdown
            var questionIdOrg = $('#ddlQuestions').val();

            // Check if optionId, questionIdOrg, and questionIds are present
            if (selectedQuestionIds.length > 0 && optionId && questionIdOrg) {
                // Call the WebMethod
                $.ajax({
                    type: "POST",
                    url: "/Pages/QuestionsTreeNew.aspx/InsertIntoQuestionTree",
                    data: JSON.stringify({ optionId: optionId, questionIds: selectedQuestionIds, questionIdOrg: questionIdOrg }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        if (response.d === "success") {

                            sessionStorage.setItem('saveSuccessMessage', 'Dati inseriti correttamente');

                            // Reload the page to show the updated data
                            location.reload();
                        } else {
                            showAlert('Errore durante aggiornamento', 'danger');
                        }
                    },
                    error: function (xhr, status, error) {
                        console.error(xhr.responseText);
                    }
                });
            } else {
                showAlert('Please select an option, a question, and at least one multi-select question.', 'danger');
            }
        }


        // Function to load options for the selected question (radio buttons)
        // Function to load options for the selected question (radio buttons)
        function loadOptions(questionId) {
            var $optionsContainer = $('#optionsContainer');
            $optionsContainer.empty(); // Clear existing radio buttons

            // If questionId is null or empty, exit the function
            if (!questionId) {
                return;
            }

            $.ajax({
                type: "POST",
                url: "/Pages/QuestionsTreeNew.aspx/GetOptions",
                data: JSON.stringify({ questionId: questionId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d);

                    $.each(data, function (index, item) {
                        var radioButton = `
                <div class="form-check">
                    <input type="radio" id="option${item.optionId}" name="customRadio" class="form-check-input" value="${item.optionId}">
                    <label class="form-check-label" for="option${item.optionId}">${item.optionName}</label>
                </div>`;
                        $optionsContainer.append(radioButton);
                    });
                },
                error: function (xhr, status, error) {
                    console.error(xhr.responseText);
                }
            });
        }


        function deleteAllQuestions() {
            // Confirmation prompt
            if (confirm("Are you sure you want to delete all selected questions for this option?")) {
                // Get the selected option ID (assuming it's from a radio button)
                var optionId = $('input[name="customRadio"]:checked').val();

                if (optionId) {
                    // Call the WebMethod
                    $.ajax({
                        type: "POST",
                        url: "/Pages/QuestionsTreeNew.aspx/DeleteAllQuestionsForOption",
                        data: JSON.stringify({ optionId: optionId }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (response) {
                            if (response.d === "success") {

                                sessionStorage.setItem('deleteSuccessMessage', 'All questions have been successfully deleted for the selected option.');
                                location.reload();

                            } else {
                                showAlert('Error during deletion.', 'danger');
                            }
                        },
                        error: function (xhr, status, error) {
                            console.error(xhr.responseText);
                        }
                    });
                } else {
                    showAlert('Please select an option before deleting.', 'danger');
                }
            }
        }





    </script>


</asp:Content>
