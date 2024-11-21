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

namespace VALUQuest.Pages
{
    public partial class QuesRamification : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string GetBlock()
        {
            try
            {
                Utility.DatabaseHelper db = new Utility.DatabaseHelper();
                string query = "SELECT blockId, blockName FROM tbl_block WHERE isActive = 1";

                DataTable dt = db.ExecuteQuery(query);

                if (dt.Rows.Count == 0)
                    throw new Exception("No blocks found.");

                List<object> blocks = new List<object>();
                foreach (DataRow row in dt.Rows)
                {
                    blocks.Add(new
                    {
                        blockId = row["blockId"],
                        blockName = row["blockName"]
                    });
                }

                return Newtonsoft.Json.JsonConvert.SerializeObject(blocks);
            }
            catch (Exception ex)
            {
                return Newtonsoft.Json.JsonConvert.SerializeObject(new { error = ex.Message });
            }
        }

        [WebMethod]
        public static List<object> GetCategories(int blockId)
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            string query = "SELECT categoryId, categoryName FROM tbl_category WHERE blockId = @blockId AND isActive = 1";
            var parameters = new List<SqlParameter>
            {
                new SqlParameter("@blockId", blockId)
            };
            DataTable dt = db.ExecuteQuery(query, parameters.ToArray());

            var categories = new List<object>();
            foreach (DataRow row in dt.Rows)
            {
                categories.Add(new
                {
                    categoryId = row["categoryId"],
                    categoryName = row["categoryName"].ToString()
                });
            }
            return categories;
        }

        [WebMethod]
        public static string InsertHierarchicalQuestion( int questionId, int? parentOptionId, int? parentQuestionId)
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
        public static string GetQuestionsByCategory(int categoryId)
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            string query = "SELECT questionId, questionName FROM tbl_questions WHERE catId = @catId AND isActive = 1";
            SqlParameter[] parameters = { new SqlParameter("@catId", categoryId) };
            DataTable dt = db.ExecuteQuery(query, parameters);
            return JsonConvert.SerializeObject(dt);
        }

        [WebMethod]
        public static string GetOptions(int questionId)
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            string query = "SELECT optionId, optionName FROM tbl_options WHERE questionId = @questionId AND isActive = 1";
            SqlParameter[] parameters = { new SqlParameter("@questionId", questionId) };
            DataTable dt = db.ExecuteQuery(query, parameters);
            return JsonConvert.SerializeObject(dt);
        }


        [WebMethod]
        public static List<object> GetQuestionTreeData()
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();

            // Query to retrieve all relevant data for building the hierarchy
            string questionTreeQuery = @"
        SELECT 
            q.questionTreeId,
            q.questionId,
            q.parentOptionId,
            q.parentQuestionId,
            q.isActive,
            q.createdBy,
            q.createdDate,
            o.optionName,
            qOrg.questionName AS questionName
        FROM 
            tbl_question_tree q
        LEFT JOIN 
            tbl_options o ON o.optionId = q.parentOptionId
        LEFT JOIN 
            tbl_questions qOrg ON qOrg.questionId = q.questionId
        WHERE 
            q.isActive = 1
        ORDER BY 
            q.questionTreeId;
    ";
            DataTable dtQuestions = db.ExecuteQuery(questionTreeQuery);

            // Convert DataTable rows to a dictionary for quick access
            var questionTreeData = dtQuestions.AsEnumerable().Select(row => new
            {
                QuestionTreeId = row.Field<int>("questionTreeId"),
                QuestionId = row.Field<int>("questionId"),
                ParentOptionId = row.Field<int?>("parentOptionId"),
                ParentQuestionId = row.Field<int?>("parentQuestionId"),
                OptionName = row.Field<string>("optionName") ?? "No Option",
                QuestionName = row.Field<string>("questionName") ?? "No Question"
            }).ToList();

            // Step 1: Build a lookup dictionary for questions by their IDs
            var questionLookup = questionTreeData.ToLookup(q => q.ParentQuestionId);

            // Step 2: Recursive function to build the tree structure
            List<object> BuildTree(int? parentQuestionId)
            {
                var children = new List<object>();

                foreach (var item in questionLookup[parentQuestionId])
                {
                    // Get child nodes recursively
                    var childNodes = BuildTree(item.QuestionId);

                    // Build current node
                    var node = new
                    {
                        title = item.QuestionName,
                        questionId = item.QuestionId,
                        optionName = item.OptionName,
                        folder = childNodes.Any(),
                        children = childNodes
                    };

                    children.Add(node);
                }

                return children;
            }

            // Step 3: Generate the root tree structure
            var treeData = BuildTree(null); // Starting with null to get the root level

            return treeData;
        }


    }
}