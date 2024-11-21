<%@ Page Title="" Language="C#" MasterPageFile="~/Template/ValuMaster.Master" AutoEventWireup="true" CodeBehind="QuestionsTree.aspx.cs" Inherits="VALUQuest.Pages.QuestionsTree" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">


    <div class="row">
        <div class="col-12">
            <div class="page-title-box">
                <h4 class="page-title">Tree Questions</h4>
            </div>
        </div>
    </div>

    <div id="msgAlert"></div>
    <div class="row">
        <div class="col-12">
            <div class="card">
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-12">
                            <div>


                                     <div id="questionTreeContainer"></div>

                            
                                <!-- Button to save the current tree structure -->
                                <button id="btnSaveStructure" type="button">Save Structure</button>


                            </div>
                        </div>
                    </div>

                    <br />
                    

                </div>
            </div>
        </div>
    </div>
    <link href="../Template/modern/assets/vendor/jstree/themes/default/style.min.css" rel="stylesheet" />


    <!-- jstree js -->
    <script src="../Template/modern/assets/vendor/jstree/jstree.min.js"></script>
    <script src="../Template/modern/assets/js/pages/demo.jstree.js"></script>

    <!-- Include jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
 $(document).ready(function () {
    // Array to store selected question IDs to prevent duplicates
    var selectedQuestions = [];

    // Load the initial question on page load
    loadQuestionsDropdown('#questionTreeContainer');

    // Function to load questions into a dropdown
    function loadQuestionsDropdown(container) {
        $.ajax({
            type: "POST",
            url: "QuestionsTree.aspx/GetQuestions",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (response) {
                var data = JSON.parse(response.d); // Parse the JSON string to an object

                // Create the dropdown and add the specified classes
                var dropdown = $('<select>').addClass('questionDropdown form-select form-select-sm mb-3').change(onQuestionChange);
                dropdown.append($('<option>').val('').text('Select a question'));

                // Populate the dropdown with filtered questions
                $.each(data, function (index, item) {
                    dropdown.append($('<option>', {
                        value: item.questionId,
                        text: item.questionName
                    }));
                });

                $(container).append(dropdown);
                console.log("Dropdown appended to container:", container); // Debugging
            },
            error: function (xhr, status, error) {
                console.error(xhr.responseText);
            }
        });
    }

    // Event handler for question dropdown change
    function onQuestionChange() {
        var questionId = $(this).val();
        var container = $(this).parent();

        if (questionId) {
            // Add the selected question to the list to prevent duplicates
            selectedQuestions.push(parseInt(questionId));

            // Load options for the selected question
            loadOptions(container, questionId);
        }
    }

    // Load options for the selected question
    function loadOptions(container, questionId) {
        $.ajax({
            type: "POST",
            url: "QuestionsTree.aspx/GetOptions",
            data: JSON.stringify({ questionId: questionId }), // Pass questionId directly
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (response) {
                var data = JSON.parse(response.d); // Parse the JSON string to an object
                var optionContainer = $('<ul>').addClass('optionsContainer');

                $.each(data, function (index, item) {
                    var optionElement = $('<li>')
                        .append($('<label>')
                        .append($('<input>').attr('type', 'radio').attr('name', 'option' + questionId).val(item.optionId).change(onOptionChange))
                        .append(item.optionName)
                    );

                    optionContainer.append(optionElement);
                });

                // Append the options to the container
                container.append(optionContainer);
                container.append($('<div>').addClass('followUpContainer')); // Placeholder for follow-up questions

                // DEBUGGING: Check if options are loaded
                console.log("Options loaded for question ID:", questionId, "Options container appended to:", container);
            },
            error: function (xhr, status, error) {
                console.error(xhr.responseText);
            }
        });
    }

    // Event handler for option selection change
    function onOptionChange() {
        var optionId = $(this).val();
        var followUpContainer = $(this).closest('li').find('.followUpContainer');

        // DEBUGGING: Check if option change is triggered
        console.log("Option selected, ID:", optionId, "Follow-up container found:", followUpContainer.length > 0);

        // Ensure the follow-up container exists
        if (followUpContainer.length) {
            loadQuestionsDropdown(followUpContainer);
        } else {
            console.error("Follow-up container not found for option ID:", optionId);
        }
    }

    // Function to initialize jstree after building the structure
    function initializeTreeView() {
        $('#questionTreeContainer').jstree({
            "core": {
                "themes": {
                    "variant": "large"
                }
            },
            "plugins": ["wholerow"]
        });
    }

    // Function to save the current tree structure
    $('#btnSaveStructure').click(function () {
        var optionRefList = [];

        // Collect optionId and refQuestionId pairs to update
        $('.optionsContainer input[type="radio"]:checked').each(function () {
            var optionId = $(this).val();
            var refQuestionDropdown = $(this).closest('.optionsContainer').next('.followUpContainer').find('select');
            var refQuestionId = refQuestionDropdown.val();

            // Collect data only if both optionId and refQuestionId are valid
            if (optionId && refQuestionId && refQuestionId !== '') {
                optionRefList.push({
                    OptionId: parseInt(optionId),
                    RefQuestionId: parseInt(refQuestionId)
                });
            }
        });

        // Call the WebMethod to update the database
        if (optionRefList.length > 0) {
            updateTreeStructure(optionRefList);
        }
    });

    // AJAX call to update the entire tree structure in the database
    function updateTreeStructure(optionRefList) {
        $.ajax({
            type: "POST",
            url: "QuestionsTree.aspx/UpdateTreeStructure",
            data: JSON.stringify({ optionRefList: optionRefList }),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (response) {
                alert(response.d); // Display success or error message
            },
            error: function (xhr, status, error) {
                console.error(xhr.responseText);
            }
        });
    }
});

</script>

</asp:Content>
