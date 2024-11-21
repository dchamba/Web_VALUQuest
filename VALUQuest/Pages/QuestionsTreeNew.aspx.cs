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
    public partial class QuestionsTreeNew : System.Web.UI.Page
    {
        static DataTabletoJSON js = new DataTabletoJSON();

        protected void Page_Load(object sender, EventArgs e)
        {


        }
        [WebMethod]
        public static List<object> GetQuestionTreeData()
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();

            // Step 1: Query to retrieve hierarchical data with blocks, categories, questions, and options
            string questionTreeQuery = @"
            SELECT 
                b.blockName, 
                c.categoryName, 
                qOrg.questionName AS questionName, 
                o.optionName AS optionName, 
                qTag.questionName AS childQuestionName,
                qTag.questionId AS childQuestionId,
                q.parentOptionId,
                q.parentQuestionId,
                q.optionId,
                q.questionId
            FROM 
                tbl_question_tree q
            LEFT JOIN 
                tbl_options o ON o.optionId = q.optionId
            LEFT JOIN 
                tbl_questions qTag ON qTag.questionId = q.questionId
            LEFT JOIN 
                tbl_questions qOrg ON qOrg.questionId = o.questionId
            LEFT JOIN 
                tbl_category c ON c.categoryId = qOrg.catId
            LEFT JOIN 
                tbl_block b ON b.blockId = c.blockId
            WHERE 
                q.isActive = 1
            ORDER BY 
                b.blockName, c.categoryName, qOrg.questionName, o.optionName, qTag.questionName;
            ";
            DataTable dtQuestions = db.ExecuteQuery(questionTreeQuery);

            // Step 2: Create a dictionary to hold the tree structure
            var data = new Dictionary<string, Dictionary<string, Dictionary<string, Dictionary<string, List<object>>>>>();

            // Process each row and build a multi-level structure based on parent relationships
            foreach (DataRow row in dtQuestions.Rows)
            {
                string blockName = row["blockName"]?.ToString() ?? "No Block Name";
                string categoryName = row["categoryName"]?.ToString() ?? "No Category Name";
                string questionName = row["questionName"]?.ToString() ?? "No Question Name";
                string optionName = row["optionName"]?.ToString() ?? "No Option Name";
                string childQuestionName = row["childQuestionName"]?.ToString() ?? "No Child Question";
                int childQuestionId = row["childQuestionId"] != DBNull.Value ? Convert.ToInt32(row["childQuestionId"]) : 0;
                int optionId = row["optionId"] != DBNull.Value ? Convert.ToInt32(row["optionId"]) : 0;
                int questionId = row["questionId"] != DBNull.Value ? Convert.ToInt32(row["questionId"]) : 0;
                int? parentOptionId = row["parentOptionId"] != DBNull.Value ? Convert.ToInt32(row["parentOptionId"]) : (int?)null;
                int? parentQuestionId = row["parentQuestionId"] != DBNull.Value ? Convert.ToInt32(row["parentQuestionId"]) : (int?)null;

                // Build hierarchy with blocks, categories, questions, and options
                if (!data.ContainsKey(blockName))
                    data[blockName] = new Dictionary<string, Dictionary<string, Dictionary<string, List<object>>>>();

                if (!data[blockName].ContainsKey(categoryName))
                    data[blockName][categoryName] = new Dictionary<string, Dictionary<string, List<object>>>();

                if (!data[blockName][categoryName].ContainsKey(questionName))
                    data[blockName][categoryName][questionName] = new Dictionary<string, List<object>>();

                if (!data[blockName][categoryName][questionName].ContainsKey(optionName))
                    data[blockName][categoryName][questionName][optionName] = new List<object>();

                // Step 3: Add child questions with options if they exist
                if (parentOptionId == null && parentQuestionId == null)
                {
                    // Top-level question with no parent
                    data[blockName][categoryName][questionName][optionName].Add(new
                    {
                        title = childQuestionName,
                        questionId = childQuestionId,
                        folder = true,
                        children = GetChildOptions(childQuestionId, dtQuestions) // Recursively get child options
                    });
                }
            }

            // Step 4: Convert the structure into FancyTree format
            var treeData = data.Select(block => new
            {
                title = block.Key,
                folder = true,
                children = block.Value.Select(category => new
                {
                    title = category.Key,
                    folder = true,
                    children = category.Value.Select(question => new
                    {
                        title = question.Key,
                        folder = true,
                        children = question.Value.Select(option => new
                        {
                            title = option.Key,
                            folder = true,
                            children = option.Value.ToList()
                        }).ToList()
                    }).ToList()
                }).ToList()
            }).ToList<object>();

            return treeData;
        }

        private static List<object> GetChildOptions(int parentQuestionId, DataTable dtQuestions)
        {
            // Recursively fetch child options and questions
            var children = dtQuestions.AsEnumerable()
                .Where(row => row.Field<int?>("parentQuestionId") == parentQuestionId)
                .Select(row => new
                {
                    title = row["childQuestionName"]?.ToString() ?? "Unnamed Child Question",
                    questionId = row["childQuestionId"] != DBNull.Value ? row.Field<int>("childQuestionId") : 0,
                    folder = true,
                    children = GetChildOptions(row.Field<int>("childQuestionId"), dtQuestions) // Recursively get sub-children
                })
                .ToList<object>();

            return children;
        }
    


    [WebMethod]
        public static string GetQuestionsByCategory(int categoryId)
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();

            // Query to get questions filtered by categoryId
            string query = @"SELECT questionId, questionName, c.categoryName 
                     FROM tbl_questions q
                     LEFT JOIN tbl_category c ON c.categoryId = q.catId
                     WHERE q.isActive = 1 AND q.catId = "+categoryId+"; ";

            // Create the parameter for categoryId
      
            // Execute the query with the parameter
            DataTable dt = db.ExecuteQuery(query);

            // Convert the DataTable to JSON
            string json = js.DataTableToJSON(dt);

            return json;
        }



        [WebMethod]
        public static string GetQuestions()
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            string query = @"SELECT questionId, questionName, c.categoryName 
                                FROM tbl_questions q
                                left join tbl_category c on c.categoryId = q.catId
                                WHERE q.isActive = 1";
            DataTable dt = db.ExecuteQuery(query);

            // Use the existing DataTabletoJSON class to convert to JSON
            string json = js.DataTableToJSON(dt);

            return json;
        }

        // WebMethod to get options for a selected question (without using parameters)
        [WebMethod]
        public static string GetOptions(int questionId)
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            // Inline the questionId directly into the query (Risky: Ensure questionId is safe)
            string query = "SELECT optionId, optionName FROM tbl_options WHERE questionId = " + questionId + " AND isActive = 1";
            DataTable dt = db.ExecuteQuery(query);

            // Use the existing DataTabletoJSON class to convert to JSON
            string json = js.DataTableToJSON(dt);

            return json;
        }

        [WebMethod]
        public static string DeleteAllQuestionsForOption(int optionId)
        {
            try
            {
                Utility.DatabaseHelper db = new Utility.DatabaseHelper();

                SqlParameter pOptionIdNew = new SqlParameter("@optionId", optionId);
                SqlParameter pDeletedBy = new SqlParameter("@deletedBy", HttpContext.Current.Session["userName"]);
                SqlParameter pDeletedDate = new SqlParameter("@deletedDate", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));

                // Call the stored procedure to delete all questions for this option
                int rowsAffectedNew = db.ExecuteStoredProcedure("sp_DeleteQuestionTree",
                    pOptionIdNew,
                    pDeletedBy,
                    pDeletedDate);

                // Return success if rows were affected
                return rowsAffectedNew > 0 ? "success" : "error";
            }
            catch (Exception ex)
            {
                // Log the exception if needed
                return "error: " + ex.Message;
            }
        }


        [WebMethod]
        public static string InsertIntoQuestionTree(int optionId, List<int> questionIds, int questionIdOrg)
        {
            try
            {
                Utility.DatabaseHelper db = new Utility.DatabaseHelper();

                SqlParameter pOptionIdNew = new SqlParameter("@optionId", optionId);
                SqlParameter pDeletedBy = new SqlParameter("@deletedBy", HttpContext.Current.Session["userName"]);
                SqlParameter pDeletedDate = new SqlParameter("@deletedDate", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));

                // Delete existing records for the optionId before inserting new ones
                int rowsAffectedNew = db.ExecuteStoredProcedure("sp_DeleteQuestionTree",
                    pOptionIdNew,
                    pDeletedBy,
                    pDeletedDate);

                int totalRowsInserted = 0;
                foreach (int questionId in questionIds)
                {
                    SqlParameter pOptionId = new SqlParameter("@optionId", optionId);
                    SqlParameter pQuestionId = new SqlParameter("@questionId", questionId);
                    SqlParameter pQuestionIdOrg = new SqlParameter("@questionIdOrg", questionIdOrg); // New parameter for questionId_org
                    SqlParameter pIsActive = new SqlParameter("@isActive", 1); // Assuming all should be active
                    SqlParameter pCreatedBy = new SqlParameter("@createdBy", HttpContext.Current.Session["userName"]);

                    // Execute the stored procedure for each questionId with questionIdOrg
                    int rowsAffected = db.ExecuteStoredProcedure("sp_InsertQuestionTreeData",
                        pOptionId,
                        pQuestionId,
                        pQuestionIdOrg,
                        pIsActive,
                        pCreatedBy);

                    // Keep track of how many rows were inserted
                    totalRowsInserted += rowsAffected;
                }

                // Return success if all rows are inserted
                if (totalRowsInserted == questionIds.Count)
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
                // Log the exception if needed
                return "error: " + ex.Message;
            }
        }

        [WebMethod]
        public static List<int> GetQuestionIdsByOptionId(int optionId)
        {
            List<int> questionIds = new List<int>();

            try
            {
                Utility.DatabaseHelper db = new Utility.DatabaseHelper();

                // Query to get questionIds from tbl_question_tree based on optionId
                string query = @"
            SELECT questionId
            FROM tbl_question_tree
            WHERE optionId = "+optionId+" and isActive=1; ";

             
                DataTable dt = db.ExecuteQuery(query);

                foreach (DataRow row in dt.Rows)
                {
                    questionIds.Add(Convert.ToInt32(row["questionId"]));
                }
            }
            catch (Exception ex)
            {
                // Handle exception if needed
                Console.WriteLine(ex.Message);
            }

            return questionIds;
        }

        public class Question
        {
            public int QuestionId { get; set; }
            public string QuestionName { get; set; }
        }
    }
}