using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace VALUQuest.Pages
{
    public partial class ViewSurvey : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string GetSurveyor(int? ageFrom, int? ageTo)
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            string query = @" SELECT 
                            m.quesMasterId, 
                            CONCAT(
                            m.name, ' ', m.surname, ' ', m.email, 
                            ' (', 
                            REPLACE(CONVERT(varchar, m.createdDate, 106), ' ', '-'), 
                            ' ', 
                            CONVERT(varchar, m.createdDate, 108), 
                            ')'
                            ) AS name
                            FROM 
                            tbl_questionnaire_master m
                            where m.isActive=1 ";

            // Add age filtering conditions if provided
            if (ageFrom.HasValue)
            {
                query += " AND DATEDIFF(YEAR, m.dob, GETDATE()) - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, m.dob, GETDATE()), m.dob) > GETDATE() THEN 1 ELSE 0 END >= " + ageFrom + " ";
            }
            if (ageTo.HasValue)
            {
                query += " AND DATEDIFF(YEAR, m.dob, GETDATE()) - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, m.dob, GETDATE()), m.dob) > GETDATE() THEN 1 ELSE 0 END <= " + ageTo + " ";
            }

            query += @" ORDER BY 
                            m.createdDate DESC;";
            DataTable dt = db.ExecuteQuery(query);
            // Convert DataTable to JSON
            string json = DataTableToJSON(dt);

            return json;
        }

        [WebMethod]
        public static string GetSurveyorData(string surveyorId)
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            string query = @"select q.questionId, b.blockName, c.categoryName, q.questionName, isnull(o.optionName, CONCAT(q.minValue,'-',q.maxValue,' ',q.unit)) optionName, d.optionValue 
                            from tbl_questionnaire_master m
                            inner join tbl_questionnaire_detail d on d.quesMasterId=m.quesMasterId
                            left join tbl_questions q on q.questionId=d.questionId
                            left join tbl_options o on o.optionId=d.optionId
                            left join tbl_category c on c.categoryId=q.catId
                            left join tbl_block b on b.blockId=c.blockId
                    where m.quesMasterId=" + surveyorId + " and q.quesType=2 " +
                    " order by b.blockId,c.categoryName, q.questionName;";
            DataTable dt = db.ExecuteQuery(query);
            List<object> data = new List<object>();
            foreach (DataRow row in dt.Rows)
            {
                data.Add(new
                {
                    questionName = row["questionName"],
                    optionName = row["optionName"],
                    optionValue = row["optionValue"]
                });
            }

            // Serialize data list to JSON
            string json = DataTableToJSON(dt);
            return json;
        }

        [WebMethod]
        public static string GetSurveyorGetBlockCalculations(string surveyorId)
        {

            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            SqlParameter pQuesMasterId = new SqlParameter("@quesMasterId", surveyorId);

            DataTable dt = db.ExecuteStoredProcedureDataTable("sp_get_BlockCalculationResults",
                pQuesMasterId);

            List<object> data = new List<object>();
            foreach (DataRow row in dt.Rows)
            {
                data.Add(new
                {
                    blockName = row["blockName"],
                    result = row["result"]
                });
            }

            // Serialize data list to JSON
            string json = DataTableToJSON(dt);
            return json;
        }

        [WebMethod]
        public static string GetViewCorrectionsApplied(string surveyorId)
        {

            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            SqlParameter pQuesMasterId = new SqlParameter("@quesMasterId", surveyorId);

            DataTable dt = db.ExecuteStoredProcedureDataTable("sp_ViewCorrectionApplied",
                pQuesMasterId);

            List<object> data = new List<object>();
            foreach (DataRow row in dt.Rows)
            {
                data.Add(new
                {
                    correctionName = row["correctionName"],
                    correctionApplicationType = row["correctionApplicationType"],
                    globalValue_before = row["globalValue_before"],
                    globalValue_add = row["globalValue_add"],
                    globalValue_after = row["globalValue_after"],
                    message = row["message"],
                    notes = row["notes"],
                    conditionType = row["conditionType"],
                    blockName = row["blockName"],
                    operatr = row["operatr"],
                    conditionValue1 = row["conditionValue1"],
                    conditionValue2 = row["conditionValue2"],
                    conjunction = row["conjunction"],
                    isApplied = row["isApplied"],
                    camID = row["camID"],
                    cadID = row["cadID"],
                    correctionMasterId = row["correctionMasterId"]
                });
            }

            // Serialize data list to JSON
            string json = DataTableToJSON(dt);
            return json;
        }


        [WebMethod]
        public static string GetSurveyorGetBlockCalculationsForChart(string surveyorId)
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            SqlParameter pQuesMasterId = new SqlParameter("@quesMasterId", surveyorId);

            DataTable dt = db.ExecuteStoredProcedureDataTable("sp_get_BlockCalculationResultsForRadarChart", pQuesMasterId);

            var indicators = new List<object>();
            var values = new List<double>();
            var legendData = new List<string> { "Results" }; // Assuming one series name "Results"

            // Determine the maximum value from the results
            double maxValue = 0;
            foreach (DataRow row in dt.Rows)
            {
                double resultValue = Convert.ToDouble(row["result"]);
                if (resultValue > maxValue)
                {
                    maxValue = resultValue;
                }
            }

            // Adjust the maximum value for a more visually appealing chart
            maxValue = Math.Ceiling(maxValue * 1.1); // Increase by 10% for padding

            foreach (DataRow row in dt.Rows)
            {
                string blockName = row["blockName"].ToString();
                double resultValue = Convert.ToDouble(row["result"]);

                // Add to indicators
                indicators.Add(new
                {
                    name = blockName,
                    max = maxValue
                });

                values.Add(resultValue);
            }

            var seriesData = new List<object>
    {
        new
        {
            name = "Results",
            value = values.ToArray()
        }
    };

            var response = new
            {
                legend = legendData,
                indicators = indicators,
                seriesData = seriesData
            };

            // Serialize data to JSON
            string json = Newtonsoft.Json.JsonConvert.SerializeObject(response);
            return json;
        }

        [WebMethod]
        public static string GetSurveyorGetBlockCalculationsForLineChart(string surveyorId)
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            SqlParameter pQuesMasterId = new SqlParameter("@quesMasterId", surveyorId);

            DataTable dt = db.ExecuteStoredProcedureDataTable("sp_get_BlockCalculationResultsForRadarChart", pQuesMasterId);

            var xAxisData = new List<string>();
            var seriesData = new List<double>();
            double resultLine = 0; // This will hold the value for the mark line
            double maxValue = 0; // This will hold the maximum value

            // Loop through the data table to populate xAxisData and seriesData
            foreach (DataRow row in dt.Rows)
            {
                string blockName = row["blockNameNew"].ToString();
                double resultValue = Convert.ToDouble(row["result"]);

                xAxisData.Add(blockName);
                seriesData.Add(resultValue);

                // Determine the value for the result line (avg_result)
                resultLine = Convert.ToDouble(row["avg_result"]);

                // Determine the maximum value
                if (resultValue > maxValue)
                {
                    maxValue = resultValue;
                }
            }

            // Adjust the maximum value for a more visually appealing chart
            maxValue = Math.Ceiling(maxValue * 1.1); // Increase by 10% for padding

            var response = new
            {
                xAxisData = xAxisData,
                seriesData = seriesData,
                resultLine = resultLine,
                maxValue = maxValue
            };

            // Serialize data to JSON
            string json = Newtonsoft.Json.JsonConvert.SerializeObject(response);
            return json;
        }


        [WebMethod]
        public static string GetSurveyorGetQuestionNumbers(string surveyorId)
        {

            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            SqlParameter pQuesMasterId = new SqlParameter("@quesMasterId", surveyorId);

            DataTable dt = db.ExecuteStoredProcedureDataTable("sp_get_QuestionNumberValues",
                pQuesMasterId);

            List<object> data = new List<object>();
            foreach (DataRow row in dt.Rows)
            {
                data.Add(new
                {
                    questionName = row["questionName"],
                    optionValue = row["optionValue"]
                });
            }

            // Serialize data list to JSON
            string json = DataTableToJSON(dt);
            return json;
        }


        [WebMethod]
        public static string GetSurveyorDataDetails(string surveyorId)
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            string query = @"select m.name, m.surname, 
                        (case when gender=1 then 'Maschio' else 'Femmina' end) as gender, 
                        FORMAT(m.dob, 'dd-MMM-yyyy') AS dob, 
                        m.email , m.bmiValue, m.height, m.weight,  FORMAT(m.createdDate, 'dd-MMM-yyyy HH:mm:ss') AS createdDate
                    from tbl_questionnaire_master m
                    where m.quesMasterId=" + surveyorId + ";";

            DataTable dt = db.ExecuteQuery(query);

            if (dt.Rows.Count > 0)
            {
                DataRow row = dt.Rows[0];
                var surveyorDetails = new
                {
                    name = row["name"].ToString(),
                    surname = row["surname"].ToString(),
                    gender = row["gender"].ToString(),
                    dob = row["dob"].ToString(),
                    email = row["email"].ToString(),
                    bmiValue = row["bmiValue"].ToString(),
                    height = row["height"].ToString(),
                    weight = row["weight"].ToString(),
                    createdDate = row["createdDate"].ToString()

                };

                // Serialize surveyorDetails to JSON
                string json = JsonConvert.SerializeObject(surveyorDetails);
                return json;
            }
            else
            {
                return "{}"; // Return an empty JSON object if no data is found
            }
        }


        public static string DataTableToJSON(DataTable table)
        {
            List<Dictionary<string, object>> rows = new List<Dictionary<string, object>>();

            foreach (DataRow dr in table.Rows)
            {
                Dictionary<string, object> row = new Dictionary<string, object>();

                foreach (DataColumn col in table.Columns)
                {
                    // Convert DataRow values to string before adding to dictionary
                    row.Add(col.ColumnName, dr[col].ToString());
                }

                rows.Add(row);
            }

            return new System.Web.Script.Serialization.JavaScriptSerializer().Serialize(rows);
        }
        [WebMethod]
        public static string DeleteData(string id)
        {
            try
            {
                Utility.DatabaseHelper db = new Utility.DatabaseHelper();
                SqlParameter pQuesMasterId = new SqlParameter("@quesMasterId", id);
                SqlParameter pDeletedBy = new SqlParameter("@deletedBy", HttpContext.Current.Session["userName"]);
                SqlParameter pDeletedDate = new SqlParameter("@deletedDate", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));


                int rowsAffected = db.ExecuteStoredProcedure("sp_DeleteQuestionnaireMasterData",
                    pQuesMasterId,
                    pDeletedBy,
                    pDeletedDate);

                // Return a response
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
                // Log the exception
                return "error";
            }
        }

        [WebMethod]
        public static string GetTotalSurvey(int? ageFrom, int? ageTo)
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            string query = @"
        SELECT COUNT(*) AS totalSurvey 
        FROM tbl_questionnaire_master m 
        WHERE m.isactive = 1 ";

            // Add age filtering conditions if provided
            if (ageFrom.HasValue)
            {
                query += " AND DATEDIFF(YEAR, m.dob, GETDATE()) - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, m.dob, GETDATE()), m.dob) > GETDATE() THEN 1 ELSE 0 END >= @ageFrom ";
            }
            if (ageTo.HasValue)
            {
                query += " AND DATEDIFF(YEAR, m.dob, GETDATE()) - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, m.dob, GETDATE()), m.dob) > GETDATE() THEN 1 ELSE 0 END <= @ageTo ";
            }

            DataTable dt = db.ExecuteQuery(query, new SqlParameter[]
            {
        new SqlParameter("@ageFrom", ageFrom ?? (object)DBNull.Value),
        new SqlParameter("@ageTo", ageTo ?? (object)DBNull.Value)
            });

            int totalSurvey = 0;
            if (dt.Rows.Count > 0)
            {
                totalSurvey = Convert.ToInt32(dt.Rows[0]["totalSurvey"]);
            }

            return JsonConvert.SerializeObject(new { totalSurvey });
        }

    }
}