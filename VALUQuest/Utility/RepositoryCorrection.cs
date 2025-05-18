using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Web;
using static VALUQuest.Pages.CorrectionsList;

namespace VALUQuest.Utility
{
	public class RepositoryCorrection
	{
        public static object getCorrectionsById(int _corretionId)
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            string query = "exec sp_get_Corrections @correctionId";

            SqlParameter[] parameters = new SqlParameter[]
            {
                new SqlParameter("@correctionId", _corretionId)
            };

            DataTable correctionData = db.ExecuteQuery(query, parameters);
            if (correctionData.Rows.Count > 0)
            {
                var masterData = new
                {
                    correctionId = correctionData.Rows[0]["correctionId"],
                    correctionName = correctionData.Rows[0]["correctionName"],
                    valueToAdd = correctionData.Rows[0]["valueToAdd"],
                    message = correctionData.Rows[0]["message"],
                    notes = correctionData.Rows[0]["notes"]
                };

                var conditions = correctionData.AsEnumerable().Select(row => new
                {
                    conditionId = row["conditionId"],
                    conditionType = row["conditionType"],
                    block = row["BlockInfo"],
                    blockId = row["BlockId"],
                    operators = row["operator"],
                    conditionValue1 = row["conditionValue1"],
                    conditionValue2 = row["conditionValue2"],
                    conjunction = row["conjunction"],
                    conditionActive = row["conditionActive"]
                }).ToList();

                return new { masterData, conditions };
            }

            // If no data is found, return null or an empty response
            return new { masterData = (object)null, conditions = new List<object>() };
        }

        public static string GetCorrectionsWithConditions()
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            //string query = @" exec sp_get_Corrections";
            string query = @"SELECT * FROM vw_CorrectionsWithConditions;";
            DataTable dt = db.ExecuteQuery(query, null);
            List<object> data = new List<object>();
            foreach (DataRow row in dt.Rows)
            {
                data.Add(new
                {
                    correctionId = row["correctionId"],
                    correctionName = row["correctionName"],
                    valueToAdd = row["valueToAdd"],
                    message = row["message"],
                    createdDate = row["createdDate"],
                    isActive = row["isActive"],
                    isDelete = row["isDelete"],
                    notes = row["notes"],
                    Conditions = row["Conditions"]
                });
            }

            DataTabletoJSON js = new DataTabletoJSON();
            string json = js.DataTableToJSON(dt);
            return json;
        }
    }
}