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
    public partial class SurveyType : System.Web.UI.Page
    {
        static DataTabletoJSON js = new DataTabletoJSON();

        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string GetSurveyType()
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            string query = @"   select p.surveyQuesTypeId, p.surveyQuesTypeName from tbl_surveyQuesType p ";
            DataTable dt = db.ExecuteQuery(query);
            List<object> data = new List<object>();
            foreach (DataRow row in dt.Rows)
            {
                data.Add(new
                {
                    surveyQuesTypeId = row["surveyQuesTypeId"],
                    surveyQuesTypeName = row["surveyQuesTypeName"]
                });
            }

            string json = js.DataTableToJSON(dt);
            return json;
        }

        [WebMethod]
        public static string GetSurveyStatus()
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            string query = @"   select p.surveyQuesTypeName, concat('Last updated on : ',p.modifiedDate) as surveyStatus from tbl_surveyQuesType p where isActive=1 ";
            DataTable dt = db.ExecuteQuery(query);
            List<object> data = new List<object>();
            foreach (DataRow row in dt.Rows)
            {
                data.Add(new
                {
                    surveyQuesTypeName = row["surveyQuesTypeName"],
                    surveyStatus = row["surveyStatus"]
                });
            }

            string json = js.DataTableToJSON(dt);
            return json;
        }

        [WebMethod]
        public static string UpdateSurveyType(string surveyQuesTypeId)
        {
            try
            {
                Utility.DatabaseHelper db = new Utility.DatabaseHelper();
               
                string query = @" UPDATE ["+ DatabaseHelper.getCurrentDatabaseName() + @"].[tbl_surveyQuesType]
                                SET isActive=-1;

                                UPDATE [""+ DatabaseHelper.getCurrentDatabaseName() + @""].[tbl_surveyQuesType]
                                SET isActive=1,
                                    modifiedBy = '" + HttpContext.Current.Session["userName"] + @"',
                                    modifiedDate = '" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + @"'
                                WHERE surveyQuesTypeId = " + surveyQuesTypeId + "; ";
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