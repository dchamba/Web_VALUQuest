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
        public static object GetSurveyQuestionsTree(float bmiValue)
        {
            // Initialize database helper
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();

            // Execute stored procedures and queries
            SqlParameter[] parameters1 = { new SqlParameter("@bmiValue", bmiValue) };
            DataTable dtSurveyQuestions = db.ExecuteStoredProcedureDataTable("sp_get_SurveyQuestionsWithBMI", parameters1);
            DataTable dtSurveyQuestionsTree = db.ExecuteStoredProcedureDataTable("sp_get_SurveyQuestionsTree");
            string optionsQuery = "SELECT * FROM tbl_options WHERE isActive = 1";
            DataTable dtOptions = db.ExecuteQuery(optionsQuery);

            // Structure the data for FancyTree
            var questionsData = new List<object>();

            foreach (DataRow row in dtSurveyQuestions.Rows)
            {
                // Basic question structure
                var question = new
                {
                    title = row["questionName"].ToString(),
                    folder = true,
                    children = new List<object>()
                };

                // Fetch options for this question from tbl_options
                var questionOptions = dtOptions.AsEnumerable()
                    .Where(opt => opt.Field<int?>("questionId") == row.Field<int?>("questionId"))
                    .Select(opt => new
                    {
                        title = opt["optionName"].ToString(),
                        folder = true,
                        children = dtSurveyQuestionsTree.AsEnumerable()
                            .Where(q => q.Field<int?>("optionId") == opt.Field<int?>("optionId"))
                            .Select(q => new
                            {
                                title = q["questionName"].ToString(),
                                folder = true, // Set to true if child questions also have options
                        children = dtOptions.AsEnumerable()
                                    .Where(o => o.Field<int?>("questionId") == q.Field<int?>("questionId"))
                                    .Select(o => new
                                    {
                                        title = o["optionName"].ToString(),
                                        folder = false // Set as leaf node
                            }).ToList()
                            }).ToList()
                    }).ToList();

                // Add options as children to the question node
                question.children.AddRange(questionOptions);
                questionsData.Add(question);
            }

            return questionsData;
        }


    }
}