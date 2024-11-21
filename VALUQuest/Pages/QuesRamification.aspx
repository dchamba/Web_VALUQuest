<%@ Page Title="" Language="C#" MasterPageFile="~/Template/ValuMaster.Master" AutoEventWireup="true" CodeBehind="QuesRamification.aspx.cs" Inherits="VALUQuest.Pages.QuesRamification" %>

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
                        <div class="col-md-6">
                            <label class="form-label">Parent Question</label>
                            <select id="ddlParentQuestion" class="form-select form-select-sm"></select>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Parent Option</label>
                            <select id="ddlParentOption" class="form-select form-select-sm"></select>
                        </div>
                    </div>

                    <div class="row mb-3" style="display:none">
                        <div class="col-md-6">
                            <label class="form-label">Question</label>
                            <select id="ddlQuestion" class="form-select form-select-sm"></select>
                        </div>
                    </div>

                    <div id="multiSelectRow" class="row mb-3">
                        <div class="col-md-12">
                            <select id="ddlMultiSelect" class="select2 form-control select2-multiple" data-toggle="select2" multiple="multiple" data-placeholder="Choose ...">
                                <!-- Multi-select options will be dynamically populated here -->
                            </select>
                        </div>
                    </div>


                    <div class="row">
                        <div class="col-md-4">
                            <button id="saveButton" class="btn btn-primary" onclick="saveData()">Save</button>
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

            loadFancyTree();

            loadBlocks();
            loadQuestions();

            $('#ddlBlock').change(loadCategories);
            // Load questions when a category is selected
            $('#ddlCategory').change(function () {
                var categoryId = $(this).val();
                if (categoryId) {
                    loadQuestions(categoryId);
                    loadParentQuestions(categoryId);
                }
            });


            // Load parent options when a parent question is selected
            $('#ddlParentQuestion').change(function () {
                var parentQuestionId = $(this).val();
                if (parentQuestionId) {
                    loadParentOptions(parentQuestionId);
                }
            });

        });

        function loadBlocks() {
            $.ajax({
                type: "POST",
                url: "/Pages/QuesRamification.aspx/GetBlock",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d);
                    var $ddlBlock = $('#ddlBlock');
                    $ddlBlock.empty().append('<option value="">Select Block</option>');
                    $.each(data, function (index, item) {
                        $ddlBlock.append($('<option>', {
                            value: item.blockId,
                            text: item.blockName
                        }));
                    });
                },
                error: function (xhr, status, error) {
                    console.error("Error loading blocks:", xhr.responseText);
                }
            });
        }


        function loadCategories() {
            $.ajax({
                type: "POST",
                url: "/Pages/QuesRamification.aspx/GetCategories",
                data: JSON.stringify({ blockId: $('#ddlBlock').val() }),
                contentType: "application/json; charset=utf-8",
                success: function (response) {
                    populateDropdown('#ddlCategory', response.d, 'categoryId', 'categoryName');
                }
            });
        }

        //function loadQuestions(categoryId) {
        //    $.ajax({
        //        type: "POST",
        //        url: "/Pages/QuesRamification.aspx/GetQuestionsByCategory",
        //        data: JSON.stringify({ categoryId: categoryId }),
        //        contentType: "application/json; charset=utf-8",
        //        dataType: "json",
        //        success: function (response) {
        //            var data = JSON.parse(response.d);
        //            var $ddlQuestion = $('#ddlQuestion');
        //            $ddlQuestion.empty().append('<option value="">Select Question</option>');
        //            $.each(data, function (index, item) {
        //                $ddlQuestion.append($('<option>', {
        //                    value: item.questionId,
        //                    text: item.questionName
        //                }));
        //            });
        //        },
        //        error: function (xhr, status, error) {
        //            console.error("Error loading questions:", xhr.responseText);
        //        }
        //    });
        //}

        function loadQuestions(categoryId) {
            $.ajax({
                type: "POST",
                url: "/Pages/QuesRamification.aspx/GetQuestionsByCategory",
                data: JSON.stringify({ categoryId: categoryId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d);
                    var $ddlMultiSelect = $('#ddlMultiSelect');
                    $ddlMultiSelect.empty(); // Clear previous options

                    // Add options to the multi-select dropdown
                    $.each(data, function (index, item) {
                        $ddlMultiSelect.append($('<option>', {
                            value: item.questionId,
                            text: item.questionName
                        }));
                    });

                    // Refresh the select2 plugin to reflect new options (if using select2)
                    $ddlMultiSelect.trigger('change'); // Trigger change event for select2
                },
                error: function (xhr, status, error) {
                    console.error("Error loading questions:", xhr.responseText);
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

            // If using select2, trigger change to refresh the dropdown
            $multiSelect.trigger('change');

            $('#multiSelectRow').show(); // Ensure the multi-select row is visible
        }


     function saveData() {
    // Collect the selected question IDs from the multi-select dropdown
    var selectedQuestionIds = $('#ddlMultiSelect').val(); // This will return an array of selected question IDs
    var parentQuestionId = $('#ddlParentQuestion').val() || null; // Set to null if not selected
    var parentOptionId = $('#ddlParentOption').val() || null; // Set to null if not selected

    // Check if any questions are selected
    if (!selectedQuestionIds || selectedQuestionIds.length === 0) {
        showAlert('Please select at least one question before saving.', 'danger');
        return;
    }

    // Iterate through each selected question and make an AJAX call to insert it
    selectedQuestionIds.forEach(function (questionId) {
        $.ajax({
            type: "POST",
            url: "/Pages/QuesRamification.aspx/InsertHierarchicalQuestion",
            data: JSON.stringify({
                questionId: parseInt(questionId),
                parentOptionId: parentOptionId ? parseInt(parentOptionId) : null,
                parentQuestionId: parentQuestionId ? parseInt(parentQuestionId) : null
            }),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (response) {
                if (response.d === "success") {
                    showAlert('Data saved successfully.', 'success');
                } else {
                    showAlert('Error while saving data.', 'danger');
                }
            },
            error: function (xhr, status, error) {
                console.error(xhr.responseText);
                showAlert('Error while saving data.', 'danger');
            }
        });
    });

    // Show a success message after all insertions are done
    sessionStorage.setItem('saveSuccessMessage', 'All data saved successfully.');
    location.reload();
}

        function loadParentQuestions(categoryId) {
            $.ajax({
                type: "POST",
                url: "/Pages/QuesRamification.aspx/GetQuestionsByCategory",
                data: JSON.stringify({ categoryId: categoryId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d);
                    var $ddlParentQuestion = $('#ddlParentQuestion');
                    $ddlParentQuestion.empty().append('<option value="">Select Parent Question</option>');
                    $.each(data, function (index, item) {
                        $ddlParentQuestion.append($('<option>', {
                            value: item.questionId,
                            text: item.questionName
                        }));
                    });
                },
                error: function (xhr, status, error) {
                    console.error("Error loading parent questions:", xhr.responseText);
                }
            });
        }

        function loadParentOptions(parentQuestionId) {
            $.ajax({
                type: "POST",
                url: "/Pages/QuesRamification.aspx/GetOptions",
                data: JSON.stringify({ questionId: parentQuestionId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d);
                    var $ddlParentOption = $('#ddlParentOption');
                    $ddlParentOption.empty().append('<option value="">Select Parent Option</option>');
                    $.each(data, function (index, item) {
                        $ddlParentOption.append($('<option>', {
                            value: item.optionId,
                            text: item.optionName
                        }));
                    });
                },
                error: function (xhr, status, error) {
                    console.error("Error loading parent options:", xhr.responseText);
                }
            });
        }

        function populateDropdown(selector, data, valueField, textField) {
            var $dropdown = $(selector);
            $dropdown.empty();
            $dropdown.append('<option value="">Select</option>');
            $.each(data, function (index, item) {
                $dropdown.append($('<option>', {
                    value: item[valueField],
                    text: item[textField]
                }));
            });
        }

        function loadFancyTree() {
            $.ajax({
                type: "POST",
                url: "/Pages/QuesRamification.aspx/GetQuestionTreeData",
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
    </script>

</asp:Content>
