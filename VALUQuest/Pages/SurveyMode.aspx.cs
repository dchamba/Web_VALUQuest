﻿using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using Newtonsoft.Json;
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
                //string query = "UPDATE [" + DatabaseHelper.getCurrentDatabaseName() + "].[tbl_survey_mode] SET surveyMode = '" + surveyMode + "'";
                string databaseName = DatabaseHelper.getCurrentDatabaseName();
                string query = "UPDATE [" + databaseName + "].[tbl_survey_mode] SET surveyMode = '"+ surveyMode + "'";
                db.ExecuteQuery(query);

                return "success";
            }
            catch (Exception ex)
            {
                // Log the exception
                return "error";
            }
        }

        // ✅ Funzione per caricare le versioni disponibili del sondaggio
        [WebMethod]
        public static string GetSurveyVersions()
        {
            try
            {
                return JsonConvert.SerializeObject(Utility.DatabaseHelper.getAllSurveyVersions());
            }
            catch (Exception ex)
            {
                return "error";
            }
        }


        [WebMethod]
        public static string GetSurveyVersion()
        {
            String currentSurveryVersion = DatabaseHelper.getCurrentVersionWorking();
            return currentSurveryVersion;
        }

        /*
        [WebMethod]
        public static string UpdateSurveyVersion(int surveyVersion)
        {
            try
            {
                Utility.DatabaseHelper db = new Utility.DatabaseHelper();
                string databaseName = DatabaseHelper.getDefaultValueDatabaseName();
                String versioneValu = "valu";
                if (surveyVersion == 1) versioneValu = "valuWork";
                string query = "UPDATE [" + databaseName + "].[config] SET value = '" + versioneValu + "' WHERE name = 'currentConnectionString'";
                db.ExecuteQuery(query);

                return "success";
            }
            catch (Exception ex)
            {
                // Log the exception
                return "error";
            }
        }
        */

        [WebMethod]
        public static string UpdateSurveyVersion(int surveyVersionId)
        {
            try
            {
                Utility.DatabaseHelper db = new Utility.DatabaseHelper();
                string query = @"UPDATE ["+ Utility.DatabaseHelper.getMasterDatabaseName() + "].[" + Utility.DatabaseHelper.getMasterDatabaseName() + "].[tbl_survey_version] " + 
                        "SET isDefault = CASE WHEN idSurvey_Version = @surveyVersionId THEN 1 ELSE 0 END";

                List<SqlParameter> parameters = new List<SqlParameter>
                {
                    new SqlParameter("@surveyVersionId", surveyVersionId)
                };

                db.ExecuteQuery(query, parameters.ToArray());
                return "success";
            }
            catch (Exception ex)
            {
                return "error";
            }
        }

    }
}