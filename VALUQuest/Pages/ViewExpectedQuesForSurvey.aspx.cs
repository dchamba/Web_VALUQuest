using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace VALUQuest.Pages
{
    public partial class ViewExpectedQuesForSurvey : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string GetSurveyQuestionsTree(float bmiValue)
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();

            // Fetch all questions from the stored procedure into a DataTable
            SqlParameter[] parameters1 = { new SqlParameter("@bmiValue", bmiValue) };
            DataTable dtSurveyQuestions = db.ExecuteStoredProcedureDataTable("sp_get_SurveyQuestionsWithBMINew", parameters1);

            // Convert DataTable to List<QuestionTable> in the same order as returned by the stored procedure
            List<QuestionTable> surveyQuestions = dtSurveyQuestions.AsEnumerable().Select(row => new QuestionTable
            {
                questionId = row.Field<int>("questionId"),
                catId = row.Field<int>("catId"),
                subCatId = row.Field<int?>("subCatId") ?? 0,
                questionName = row.Field<string>("questionName"),
                quesType = row.Field<int>("quesType"),
                isActive = row.Field<int>("isActive"),
            }).ToList();

            // Load all questions, options, and tree structure from the database
            var questions = db.ExecuteQueryReturnListObject<QuestionTable>("SELECT * FROM tbl_questions WHERE isActive = 1");
            var options = db.ExecuteQueryReturnListObject<OptionTable>("SELECT * FROM tbl_options WHERE isActive = 1");
            var treeStructure = db.ExecuteQueryReturnListObject<QuestionTreeTable>("SELECT * FROM tbl_question_treeNew1 WHERE isActive = 1");

            // Add a flag to mark matched questions
            foreach (var question in surveyQuestions)
            {
                question.isMatched = treeStructure.Any(t => t.questionId == question.questionId);
            }

            // Build the tree structure with matched questions
            var resultTree = TreeLoader.BuildTree(questions, options, treeStructure);

            // Maintain the order of unmatched questions as returned by the stored procedure
            var unmatchedQuestions = surveyQuestions.Where(q => !q.isMatched).ToList();
            foreach (var question in unmatchedQuestions)
            {
                // Find all options associated with the unmatched question
                var childOptions = options
                    .Where(o => o.questionId == question.questionId)
                    .Select(o => new OptionTable
                    {
                        optionID = o.optionID,
                        optionName = o.optionName,
                        questionId = o.questionId,
                        isActive = o.isActive,
                        children = new List<QuestionTable>(), // No child questions for unmatched
                treeNodeElement = null
                    }).ToList();

                // Add the unmatched question with its options to the tree
                resultTree.Add(new QuestionTable
                {
                    questionId = question.questionId,
                    catId = question.catId,
                    subCatId = question.subCatId,
                    questionName = question.questionName,
                    quesType = question.quesType,
                    isActive = question.isActive,
                    isMatched = false,
                    treeNodeElement = null,
                    children = childOptions // Attach the options as children
                });
            }

            // Combine matched and unmatched questions, maintaining the order from the stored procedure
            var orderedResultTree = surveyQuestions.Select(q =>
            {
                var matchedNode = resultTree.FirstOrDefault(t => t.questionId == q.questionId);
                if (matchedNode != null)
                {
                    return matchedNode;
                }
                else
                {
                    // Add unmatched questions
                    return new QuestionTable
                    {
                        questionId = q.questionId,
                        catId = q.catId,
                        subCatId = q.subCatId,
                        questionName = q.questionName,
                        quesType = q.quesType,
                        isActive = q.isActive,
                        isMatched = false,
                        treeNodeElement = null,
                        children = options.Where(o => o.questionId == q.questionId)
                            .Select(o => new OptionTable
                            {
                                optionID = o.optionID,
                                optionName = o.optionName,
                                questionId = o.questionId,
                                isActive = o.isActive,
                                treeNodeElement = null,
                                children = new List<QuestionTable>()
                            }).ToList()
                    };
                }
            }).ToList();

            // Convert the tree to JSON
            var jsonResult = Newtonsoft.Json.JsonConvert.SerializeObject(orderedResultTree, Newtonsoft.Json.Formatting.None,
                new Newtonsoft.Json.JsonSerializerSettings
                {
                    ReferenceLoopHandling = Newtonsoft.Json.ReferenceLoopHandling.Ignore
                });

            return jsonResult;
        }



        public class QuestionTreeTable
        {
            public int questionTreeId { get; set; }
            public int nodeLevel { get; set; }                      //can be deleted, but better to keep for debugging and data analysis
            public int? fatherQuestionTreeId { get; set; }
            public int? optionId { get; set; }                      //can be deleted
            public int questionId { get; set; }
            public int? parentOptionId { get; set; }
            public int? parentQuestionId { get; set; }
            public int? startingQuestionTreeId { get; set; }        //can be deleted, but better to keep for debugging and data analysis
            public int isActive { get; set; }
        }

        public class OptionTable
        {
            public OptionTable()
            {
                this.children = new List<QuestionTable>();
            }
            public int optionID { get; set; }
            public string optionName { get; set; }
            public int questionId { get; set; }
            public int isActive { get; set; }

            //extra field for fancyTreeDataStructure support
            public List<QuestionTable> children { get; set; }
            public QuestionTreeTable treeNodeElement { get; set; }
            public string title => optionName;
            //public string title => optionName + " (Oid " + optionID + ", Qid: " + questionId + ", Tid: " + getTreeNodeElementId() + " )";
            public string key => Guid.NewGuid().ToString().Substring(0, 8);

            public bool isOption = true, folder = false;
            public string getTreeNodeElementId()
            {
                return treeNodeElement == null ? "" : treeNodeElement.questionTreeId.ToString();
            }
        }



        public class QuestionTable
        {
            public QuestionTable()
            {
                this.children = new List<OptionTable>();
            }
            public int questionId { get; set; }
            public int catId { get; set; }
            public int subCatId { get; set; }
            public string questionName { get; set; }
            public int quesType { get; set; }
            public int isActive { get; set; }

            // Indicates if the question matches the stored procedure
            public bool isMatched { get; set; }

            // Extra field for FancyTree data structure support
            public List<OptionTable> children { get; set; }
            public QuestionTreeTable treeNodeElement { get; set; }
            public string title => questionName;
            public string key => Guid.NewGuid().ToString().Substring(0, 8);

            // Add a CSS class for matched questions
            public string cssClass => isMatched ? "highlighted-node" : "";

            public bool isOption = false, folder = true;

            public string getTreeNodeElementId()
            {
                return treeNodeElement == null ? "" : treeNodeElement.questionTreeId.ToString();
            }
        }


        public class TreeLoader
        {
            public static List<QuestionTable> BuildTree(
                List<QuestionTable> questions,
                List<OptionTable> options,
                List<QuestionTreeTable> treeStructure)
            {
                // Find root nodes (nodeLevel == 0)
                var rootNodes = treeStructure.Where(t => t.nodeLevel == 0).ToList();

                // Use a Dictionary to avoid re-processing nodes
                var processedNodes = new Dictionary<int, QuestionTable>();

                List<QuestionTable> BuildSubTree(QuestionTreeTable currentNode, int startingQuestionTreeId)
                {
                    // Avoid re-processing the same node
                    if (processedNodes.ContainsKey(currentNode.questionTreeId))
                    {
                        return new List<QuestionTable> { processedNodes[currentNode.questionTreeId] };
                    }

                    // Find the question associated with the current node
                    var question = questions.FirstOrDefault(q => q.questionId == currentNode.questionId);
                    if (question == null) return new List<QuestionTable>();

                    // Set the startingQuestionTreeId for the current node
                    currentNode.startingQuestionTreeId = startingQuestionTreeId;

                    // Create a new instance of the question for the current node
                    var newQuestion = new QuestionTable
                    {
                        questionId = question.questionId,
                        catId = question.catId,
                        subCatId = question.subCatId,
                        questionName = question.questionName,
                        quesType = question.quesType,
                        isActive = question.isActive,
                        isMatched = question.isMatched, // Carry forward matched/unmatched status
                        treeNodeElement = currentNode,
                        children = new List<OptionTable>()
                    };

                    // Cache the processed node
                    processedNodes[currentNode.questionTreeId] = newQuestion;

                    // Find all options associated with the current question
                    var childOptions = options
                        .Where(o => o.questionId == currentNode.questionId)
                        .Select(o => new OptionTable
                        {
                            optionID = o.optionID,
                            optionName = o.optionName,
                            questionId = o.questionId,
                            isActive = o.isActive,
                            treeNodeElement = currentNode
                        })
                        .ToList();

                    // For each option, find its child nodes
                    foreach (var option in childOptions)
                    {
                        var childNodes = treeStructure
                            .Where(t =>
                                t.parentOptionId == option.optionID &&
                                t.parentQuestionId == option.questionId &&
                                t.fatherQuestionTreeId == currentNode.questionTreeId)
                            .ToList();

                        foreach (var childNode in childNodes)
                        {
                            // Recursively build the subtree for child nodes
                            var childQuestions = BuildSubTree(childNode, startingQuestionTreeId);
                            foreach (var childQuestion in childQuestions)
                            {
                                option.children.Add(childQuestion);
                            }
                        }
                        newQuestion.children.Add(option); // Add the option
                    }

                    return new List<QuestionTable> { newQuestion };
                }

                // Build the tree starting from root nodes
                var resultTree = new List<QuestionTable>();
                foreach (var rootNode in rootNodes)
                {
                    resultTree.AddRange(BuildSubTree(rootNode, rootNode.questionTreeId));
                }

                return resultTree;
            }
        }

    }
}