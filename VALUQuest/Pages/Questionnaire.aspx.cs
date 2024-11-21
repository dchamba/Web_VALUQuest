using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace VALUQuest.Pages
{
    public partial class Questionnaire : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadInitialQuestion();
            }
        }

        // Load the initial question
        private void LoadInitialQuestion()
        {
            int initialQuestionId = 1; // Assume the first question has an ID of 1
            LoadQuestion(initialQuestionId);
        }

        // Load question and options
        private void LoadQuestion(int questionId)
        {
            // Initialize the database helper
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();

            // Query to get the question text
            string query = "SELECT questionText FROM tbl_questions WHERE questionId = "+questionId+";";
            // Execute the query and get the result
            DataTable dtQuestion = db.ExecuteQuery(query);

            // Check if the question exists
            if (dtQuestion.Rows.Count > 0)
            {
                lblQuestion.Text = dtQuestion.Rows[0]["questionText"].ToString();
            }

            // Query to get the options
            string optionQuery = "SELECT optionId, optionText FROM tbl_options WHERE questionId = " + questionId + ";";
            // Execute the query and get the options
            DataTable dtOptions = db.ExecuteQuery(optionQuery);

            // Clear previous options and bind new ones
            rblOptions.Items.Clear();
            foreach (DataRow row in dtOptions.Rows)
            {
                rblOptions.Items.Add(new ListItem(row["optionText"].ToString(), row["optionId"].ToString()));
            }
        }

        // Event when an option is selected
        protected void rblOptions_SelectedIndexChanged(object sender, EventArgs e)
        {
            int selectedOptionId = int.Parse(rblOptions.SelectedValue);
            // Fetch the next question ID based on the selected option
            int nextQuestionId = GetNextQuestionId(selectedOptionId);

            if (nextQuestionId > 0)
            {
                LoadQuestion(nextQuestionId);
            }
            else
            {
                lblQuestion.Text = "Thank you for completing the questionnaire.";
                rblOptions.Items.Clear();
            }
        }

        // Fetch the next question ID using a WebMethod
        [WebMethod]
        public static int GetNextQuestionId(int optionId)
        {
            int nextQuestionId = 0;
            // Initialize the database helper
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();

            // Query to get the follow-up question ID
            string query = "SELECT followUpQuestionId FROM tbl_options WHERE optionId = "+optionId+";";
            // Execute the query and get the result
            DataTable dt = db.ExecuteQuery(query);

            // Check if the result exists
            if (dt.Rows.Count > 0 && dt.Rows[0]["followUpQuestionId"] != DBNull.Value)
            {
                nextQuestionId = Convert.ToInt32(dt.Rows[0]["followUpQuestionId"]);
            }

            return nextQuestionId;
        }
    }
}