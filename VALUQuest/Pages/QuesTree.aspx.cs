using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using VALUQuest.Utility;

namespace VALUQuest.Pages
{
    public partial class QuesTree : System.Web.UI.Page
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
                SqlParameter pCreatedBy = new SqlParameter("@createdBy", HttpContext.Current.Session["userName"]);

                int rowsAffected = db.ExecuteStoredProcedure("sp_InsertQuestionTreeData",
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
        public static string InsertChildQuestions(int parentOptionId, int parentQuestionId, List<int> questionIds)
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
                    SqlParameter pIsActive = new SqlParameter("@isActive", 1);
                    SqlParameter pCreatedBy = new SqlParameter("@createdBy", HttpContext.Current.Session["userName"]);

                    int rowsAffected = db.ExecuteStoredProcedure("sp_InsertQuestionTreeData",
                        pQuestionId,
                        pParentOptionId,
                        pParentQuestionId,
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
        public static string GetQuestionTreeData()
        {
            try
            {
                Utility.DatabaseHelper db = new Utility.DatabaseHelper();

                // Load questions and build tree
                string questionQuery = @"exec sp_get_ramification";

                DataTable questionTable = db.ExecuteQuery(questionQuery);

                // Load options
                string optionQuery = @"
            SELECT 
                o.optionId,
                o.optionName,
                o.questionId
            FROM 
                tbl_options o
            WHERE 
                o.isActive = 1;";
                DataTable optionTable = db.ExecuteQuery(optionQuery);

                // Create dictionaries for easier lookup
                Dictionary<int, dynamic> nodes = new Dictionary<int, dynamic>();
                List<dynamic> treeData = new List<dynamic>();

                // Create the static "Ramification" node
                var ramificationNode = new
                {
                    title = "Ramification",
                    key = "root_0",
                    folder = true,
                    expanded = true,
                    children = new List<dynamic>()
                };
                treeData.Add(ramificationNode);

                // Create option dictionary for lookup
                Dictionary<int, List<dynamic>> optionNodes = new Dictionary<int, List<dynamic>>();
                foreach (DataRow row in optionTable.Rows)
                {
                    int questionId = row.Field<int>("questionId");
                    int optionId = row.Field<int>("optionId");
                    string optionName = row.Field<string>("optionName");

                    var optionNode = new
                    {
                        title = optionName,
                        key = $"o_{optionId}",
                        folder = false,
                        isOption = true,
                        optionId = optionId, // Add optionId for reference
                        questionId = questionId, // Add questionId for reference
                        children = new List<dynamic>()
                    };

                    if (!optionNodes.ContainsKey(questionId))
                    {
                        optionNodes[questionId] = new List<dynamic>();
                    }
                    optionNodes[questionId].Add(optionNode);
                }

                // Iterate over the question data and build the tree structure
                foreach (DataRow questionRow in questionTable.Rows)
                {
                    int questionTreeId = questionRow.Field<int>("questionTreeId"); // Ensure questionTreeId is retrieved
                    int questionId = questionRow.Field<int>("questionId");
                    int? parentOptionId = questionRow.Field<int?>("parentOptionId");
                    int? parentQuestionId = questionRow.Field<int?>("parentQuestionId");
                    string questionTitle = questionRow.Field<string>("questionTitle");

                    var questionNode = new
                    {
                        title = questionTitle,
                        key = $"q_{questionId}",
                        folder = true,
                        isOption = false,
                        questionId = questionId, // Add questionId for reference
                        questionTreeId = questionTreeId, // Add questionTreeId for reference
                        parentOptionId = parentOptionId, // Add parentOptionId for reference
                        parentQuestionId = parentQuestionId, // Add parentQuestionId for reference
                        children = new List<dynamic>()
                    };

                    nodes[questionId] = questionNode;

                    // Add options under the question if available
                    if (optionNodes.ContainsKey(questionId))
                    {
                        foreach (var optionNode in optionNodes[questionId])
                        {
                            questionNode.children.Add(optionNode);
                        }
                    }

                    if (parentQuestionId == null && parentOptionId == null)
                    {
                        // This is a root-level question, add it to the "Ramification" node
                        ramificationNode.children.Add(questionNode);
                    }
                    else if (parentOptionId != null && nodes.ContainsKey(parentQuestionId.Value))
                    {
                        // Add question as a child of the parent option
                        var parentNode = nodes[parentQuestionId.Value];

                        // Ensure parentNode.children is initialized
                        if (parentNode.children == null)
                        {
                            parentNode.children = new List<dynamic>();
                        }

                        var parentOptionNode = ((List<dynamic>)parentNode.children)
                            .FirstOrDefault(o => o.key == $"o_{parentOptionId.Value}");

                        if (parentOptionNode != null)
                        {
                            // Ensure parentOptionNode.children is initialized
                            if (parentOptionNode.children == null)
                            {
                                parentOptionNode.children = new List<dynamic>();
                            }

                            parentOptionNode.children.Add(questionNode);
                        }
                    }
                }


                string jsonData = Newtonsoft.Json.JsonConvert.SerializeObject(treeData, Newtonsoft.Json.Formatting.None,
                   new Newtonsoft.Json.JsonSerializerSettings
                   {
                       ReferenceLoopHandling = Newtonsoft.Json.ReferenceLoopHandling.Ignore
                   });

                // Output JSON to debug
                System.Diagnostics.Debug.WriteLine("Tree Data JSON: " + jsonData);

                return jsonData;

               
            }
            catch (Exception ex)
            {
                return $"error: {ex.Message}";
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
                SqlParameter pDeletedBy = new SqlParameter("@deletedBy", HttpContext.Current.Session["userName"]);
                SqlParameter pDeletedDate = new SqlParameter("@deletedDate", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));

                // Execute stored procedure
                int rowsAffected = db.ExecuteStoredProcedure("sp_DeleteQuestionTree",
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

    }
}