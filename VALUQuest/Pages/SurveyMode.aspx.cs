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
    public partial class SurveyMode : System.Web.UI.Page
    {
        static DataTabletoJSON js = new DataTabletoJSON();

        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string GetSurveyStatus()
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            string query = @"   select (case when surveyMode=1 then 'Mostra domande figlie in sequenza nel questionario' 
                                else 'Mostra domande figlie in questionario modalità random' end) as surveyModeName, surveyMode  from tbl_survey_mode; ";
            DataTable dt = db.ExecuteQuery(query);
            List<object> data = new List<object>();
            foreach (DataRow row in dt.Rows)
            {
                data.Add(new
                {
                    surveyModeName = row["surveyModeName"],
                    surveyMode = row["surveyMode"]
                });
            }

            string json = js.DataTableToJSON(dt);
            return json;
        }


        [WebMethod]
        public static string UpdateSurveyMode(int surveyMode)
        {
            try
            {
                Utility.DatabaseHelper db = new Utility.DatabaseHelper();
                string query = $@"UPDATE [tcp_org_pk_questionnaire].[tbl_survey_mode]
                          SET surveyMode = {surveyMode}";
                db.ExecuteQuery(query);

                return "success";
            }
            catch (Exception ex)
            {
                // Log the exception
                return "error";
            }
        }



    }
}