using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using VALUQuest.Utility;

namespace VALUQuest.Pages
{
    public partial class QuestionsTree : System.Web.UI.Page
    {
        // Assuming you already have this static instance elsewhere in your project
        static DataTabletoJSON js = new DataTabletoJSON();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Initialization logic, removed TreeView and related code
            }
        }

        // WebMethod to get questions for the dropdown
        [WebMethod]
        public static string GetQuestions()
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            string query = "SELECT questionId, questionName FROM tbl_questions WHERE isActive = 1";
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

        // WebMethod to update the refQuestionId for multiple options at once
        [WebMethod]
        public static string UpdateTreeStructure(List<OptionRefQuestion> optionRefList)
        {
            try
            {
                Utility.DatabaseHelper db = new Utility.DatabaseHelper();
                foreach (var item in optionRefList)
                {
                    // Update query to set refQuestionId for each optionId
                    string query = "UPDATE tbl_options SET refQuestionId = " + item.RefQuestionId + " WHERE optionId = " + item.OptionId;

                    // Execute the query
                    db.ExecuteNonQuery(query);
                }

                // Return success message
                return "Tree structure updated successfully.";
            }
            catch (Exception ex)
            {
                // Log the exception if needed
                return "Error: " + ex.Message;
            }
        }

        // Class to represent the optionId and refQuestionId pair
        public class OptionRefQuestion
        {
            public int OptionId { get; set; }
            public int RefQuestionId { get; set; }
        }
    }
}