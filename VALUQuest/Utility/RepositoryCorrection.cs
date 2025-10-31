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
            object masterData = null;
            object conditions = null;
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            string query = "exec sp_get_Corrections @correctionId";

            SqlParameter[] parameters = new SqlParameter[]
            {
                new SqlParameter("@correctionId", _corretionId)
            };
            DataTable correctionData = db.ExecuteQuery(query, parameters);
            if (correctionData.Rows.Count > 0)
            {
                masterData = new
                {
                    correctionId = correctionData.Rows[0]["correctionId"],
                    correctionName = correctionData.Rows[0]["correctionName"],
                    valueToAdd = correctionData.Rows[0]["valueToAdd"],
                    message = correctionData.Rows[0]["message"],
                    notes = correctionData.Rows[0]["notes"]
                };

                conditions = correctionData.AsEnumerable().Select(row => new
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
            //return new { masterData = (object)null, conditions = new List<object>() };

            string qMaster = @"
                    SELECT TOP 1 correctionId, correctionName, valueToAdd, message, notes
                    FROM tbl_corrections_m
                    WHERE correctionId = @correctionId AND ISNULL(isDelete,0)=0";

            SqlParameter[] parameters1 = new SqlParameter[] { new SqlParameter("@correctionId", _corretionId) };
            DataTable dtMaster = db.ExecuteQuery(qMaster, parameters1);

            if (dtMaster.Rows.Count == 0)
            {
                // correzione inesistente
                return new { masterData = (object)null, conditions = new List<object>() };
            }

            masterData = new
            {
                correctionId = dtMaster.Rows[0]["correctionId"],
                correctionName = dtMaster.Rows[0]["correctionName"],
                valueToAdd = dtMaster.Rows[0]["valueToAdd"],
                message = dtMaster.Rows[0]["message"],
                notes = dtMaster.Rows[0]["notes"]
            };

            // Condizioni (LEFT JOIN per avere anche il nome blocco, ma saranno 0 righe per ID=34)
            string qConds = @"
                            SELECT  d.conditionId,
                                    d.conditionType,
                                    ISNULL(b.blockName, '-')   AS BlockInfo,
                                    d.blockId                  AS BlockId,
                                    d.[operator]               AS [operator],
                                    d.conditionValue1,
                                    d.conditionValue2,
                                    d.conjunction,
                                    ISNULL(d.isActive,1)       AS conditionActive
                            FROM tbl_correction_conditions_d d
                            LEFT JOIN tbl_block b ON b.blockId = d.blockId
                            WHERE d.correctionId = @correctionId AND ISNULL(d.isDeleted,0)=0
                            ORDER BY d.conditionId";
            SqlParameter[] parameters2 = new SqlParameter[] { new SqlParameter("@correctionId", _corretionId) };
            DataTable dtConds = db.ExecuteQuery(qConds, parameters2);

            conditions = dtConds.AsEnumerable().Select(row => new
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