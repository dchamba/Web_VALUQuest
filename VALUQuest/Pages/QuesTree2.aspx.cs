using Microsoft.Ajax.Utilities;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using VALUQuest.Pages;
using VALUQuest.Utility;
using static VALUQuest.Pages.QuestionsTreeNew;

namespace VALUQuest.Pages
{
    public partial class QuesTree2 : System.Web.UI.Page
    {
        static DataTabletoJSON js = new DataTabletoJSON();
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string GetQuestionsByCategory(int categoryId)
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            string query = @"SELECT questionId, questionName, c.categoryName 
                     FROM tbl_questions q
                     LEFT JOIN tbl_category c ON c.categoryId = q.catId
                     WHERE q.isActive = 1 AND q.catId = " + categoryId + "";

            DataTable dt = db.ExecuteQuery(query);

            // Convert DataTable to JSON
            string json = js.DataTableToJSON(dt);
            return json;
        }

        [WebMethod]
        public static string GetQuestions()
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            string query = @"SELECT questionId, questionName, c.categoryName 
                     FROM tbl_questions q
                     LEFT JOIN tbl_category c ON c.categoryId = q.catId
                     WHERE q.isActive = 1";
            DataTable dt = db.ExecuteQuery(query);

            // Convert DataTable to JSON
            string json = js.DataTableToJSON(dt);
            return json;
        }

        [WebMethod]
        public static string InsertHierarchicalQuestion(int questionId, int? parentOptionId, int? parentQuestionId)
        {
            try
            {
                Utility.DatabaseHelper db = new Utility.DatabaseHelper();

                SqlParameter pQuestionId = new SqlParameter("@questionId", questionId);
                SqlParameter pParentOptionId = new SqlParameter("@parentOptionId", (object)parentOptionId ?? DBNull.Value);
                SqlParameter pParentQuestionId = new SqlParameter("@parentQuestionId", (object)parentQuestionId ?? DBNull.Value);
                SqlParameter pIsActive = new SqlParameter("@isActive", 1);
                SqlParameter pCreatedBy = new SqlParameter("@createdBy", "system");

                int rowsAffected = db.ExecuteStoredProcedure("sp_InsertQuestionTreeDataNewTest",
                    pQuestionId,
                    pParentOptionId,
                    pParentQuestionId,
                    pIsActive,
                    pCreatedBy);

                return rowsAffected > 0 ? "success" : "error";
            }
            catch (Exception ex)
            {
                // Log or display detailed error message
                Console.WriteLine("Error: " + ex.Message);
                return "error: " + ex.Message;
            }
        }

        [WebMethod]
        public static string InsertChildQuestions(int parentOptionId, int parentQuestionId, int QuestionTreeId, int NodeLevel, int StartingQuestionTreeId, int HasChildNodes, List<int> questionIds)
        {
            try
            {
                Utility.DatabaseHelper db = new Utility.DatabaseHelper();
                int totalRowsInserted = 0;

                foreach (int questionId in questionIds)
                {
                    SqlParameter pQuestionId = new SqlParameter("@questionId", questionId);
                    SqlParameter pParentOptionId = new SqlParameter("@parentOptionId", (object)parentOptionId ?? DBNull.Value);
                    SqlParameter pParentQuestionId = new SqlParameter("@parentQuestionId", (object)parentQuestionId ?? DBNull.Value);
                    SqlParameter pQuestionTreeId = new SqlParameter("@fatherQuestionTreeId", (object)QuestionTreeId ?? DBNull.Value);
                    // Adjust NodeLevel based on HasChildNodes
                    SqlParameter pNodeLevel = new SqlParameter("@nodeLevel",
                        HasChildNodes == 0 ? (object)(NodeLevel + 10) : (object)NodeLevel);

                    SqlParameter pStartingQuestionTreeId = new SqlParameter("@startingQuestionTreeId", (object)StartingQuestionTreeId ?? DBNull.Value);

                    SqlParameter pIsActive = new SqlParameter("@isActive", 1);
                    SqlParameter pCreatedBy = new SqlParameter("@createdBy", "system");

                    int rowsAffected = db.ExecuteStoredProcedure("sp_InsertQuestionTreeDataNewTest",
                        pQuestionId,
                        pParentOptionId,
                        pParentQuestionId,
                        pQuestionTreeId,
                        pNodeLevel,
                        pStartingQuestionTreeId,
                        pIsActive,
                        pCreatedBy);

                    totalRowsInserted += rowsAffected;
                }

                return totalRowsInserted == questionIds.Count ? "success" : "partial_success";
            }
            catch (Exception ex)
            {
                return "error: " + ex.Message;
            }
        }

        [WebMethod]
        public static string DeleteQuestionNode(int questionTreeId)
        {
            try
            {
                Utility.DatabaseHelper db = new Utility.DatabaseHelper();

                // Create parameters
                SqlParameter pQuestionTreeId = new SqlParameter("@questionTreeId", questionTreeId);
                SqlParameter pDeletedBy = new SqlParameter("@deletedBy", "system");
                SqlParameter pDeletedDate = new SqlParameter("@deletedDate", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));

                // Execute stored procedure
                int rowsAffected = db.ExecuteStoredProcedure("sp_DeleteQuestionTreeTest1",
                    pQuestionTreeId,
                    pDeletedBy,
                    pDeletedDate);

                // Return a response based on the result
                if (rowsAffected > 0)
                {
                    return "success";
                }
                else
                {
                    return "error";
                }
            }
            catch (Exception ex)
            {
                return $"error: {ex.Message}";
            }
        }

        [WebMethod]
        public static string GetCategories()
        {
            // Query to fetch active categories
            string query = @"
        SELECT 
            c.categoryId, 
            c.categoryName 
        FROM 
            tbl_category c
        WHERE 
            c.isActive = 1
        ORDER BY 
            c.categoryId DESC;
    ";

            // Execute the query
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            DataTable dt = db.ExecuteQuery(query);

            // Convert the DataTable to a list of objects
            List<object> data = new List<object>();
            foreach (DataRow row in dt.Rows)
            {
                data.Add(new
                {
                    categoryId = Convert.ToInt32(row["categoryId"]),
                    categoryName = row["categoryName"].ToString()
                });
            }

            // Serialize the data to JSON and return it
            return JsonConvert.SerializeObject(data);
        }


        [WebMethod]
        public static string GetQuestionsByCategories(List<int> categoryIds)
        {
            if (categoryIds == null || categoryIds.Count == 0)
            {
                return JsonConvert.SerializeObject(new List<object>()); // Return an empty result if no categoryIds are passed
            }

            // Join the category IDs into a comma-separated string
            string categoryIdList = string.Join(",", categoryIds);

            // Use a parameterized query to prevent SQL injection
            string query = @"
        SELECT 
            q.questionId, 
            q.questionName, 
            c.categoryName 
        FROM 
            tbl_questions q
        LEFT JOIN 
            tbl_category c ON c.categoryId = q.catId
        WHERE 
            q.isActive = 1 
            AND q.catId IN (" + categoryIdList + ")";

            // Execute the query
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            DataTable dt = db.ExecuteQuery(query);

            // Convert the result to JSON and return it
            var result = dt.AsEnumerable().Select(row => new
            {
                questionId = row.Field<int>("questionId"),
                questionName = row.Field<string>("questionName"),
                categoryName = row.Field<string>("categoryName")
            }).ToList();

            return JsonConvert.SerializeObject(result);
        }



        [WebMethod]
        public static string GetQuestionTreeData()
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();

            // Simula il caricamento dal database
            var questions = db.ExecuteQueryReturnListObject<QuestionTable>("SELECT * FROM tbl_questions WHERE isActive = 1");
            var options = db.ExecuteQueryReturnListObject<OptionTable>("SELECT * FROM tbl_options WHERE isActive = 1");
            var treeStructure = db.ExecuteQueryReturnListObject<QuestionTreeTable>("SELECT * FROM tbl_question_treeNew2 WHERE isActive = 1");

            // Costruisce l'albero
            var resultTree = TreeLoader.BuildTree(questions, options, treeStructure);

            // Converte l'albero in JSON
            var jsonResult = Newtonsoft.Json.JsonConvert.SerializeObject(resultTree, Newtonsoft.Json.Formatting.None,
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
            public string title => optionName ;
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

            //extra field for fancyTreeDataStructure support
            public List<OptionTable> children { get; set; }
            public QuestionTreeTable treeNodeElement { get; set; }
            public string title => questionName +"";
           // public string title => questionName + " (Qid" + questionId + ", Tid: " + getTreeNodeElementId() + " )";
           
		   public string key => Guid.NewGuid().ToString().Substring(0, 8);

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

                // Recursive function to build the tree
                List<QuestionTable> BuildSubTree(QuestionTreeTable currentNode, int startingQuestionTreeId)
                {
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
                        treeNodeElement = currentNode,
                        children = new List<OptionTable>()
                    };

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
                                option.treeNodeElement = childNode;
                                option.children.Add(childQuestion);
                            }
                        }
                        newQuestion.children.Add(option); // Add the option
                    }

                    // Return the constructed question node
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

