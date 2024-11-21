using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using VALUQuest.Utility;

namespace VALUQuest.Pages
{
    public partial class CorrectionsList : System.Web.UI.Page
    {
        private static string connectionString;
        static DataTabletoJSON js;
        public CorrectionsList()
        {
            connectionString = ConfigurationManager.ConnectionStrings["valu"].ConnectionString;
            js = new DataTabletoJSON();
        }
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void EditButton_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            string correctionId = btn.CommandArgument;
            Response.Redirect($"Corrections.aspx?ID={correctionId}");
        }
        [WebMethod]
        public static List<CorrectionWithConditions> GetCorrectionsWithConditions1()
        {
            List<CorrectionWithConditions> correctionsList = new List<CorrectionWithConditions>();

            //string query = " SELECT " +
            //    " m.correctionId, m.correctionName, m.message, m.valueToAdd, m.notes, m.createdBy, m.createdDate," +
            //    " d.conditionId, d.blockId, d.conditionType, d.operator, d.conditionValue1, d.conditionValue2, d.conjunction, b.blockName" +
            //    " FROM " +
            //    " tbl_corrections_m m" +
            //    " INNER JOIN " +
            //    " tbl_correction_conditions_d d ON m.correctionId = d.correctionId" +
            //    " LEFT JOIN " +
            //    " tbl_block b ON d.blockId = b.blockId" +
            //    " WHERE " +
            //    " m.isDelete = 0 " +
            //    " AND m.isActive = 1" +
            //    " AND b.isActive = 1;";
            string query = "SELECT * FROM vw_CorrectionsWithConditions;";

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                SqlCommand cmd = new SqlCommand(query, conn);
                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    CorrectionWithConditions correction = new CorrectionWithConditions
                    {
                        CorrectionId = reader.GetInt32(0),
                        CorrectionName = reader.GetString(1),
                        Message = reader.GetString(3),
                        ValueToAdd = reader.GetDecimal(2),
                        Notes = reader.GetString(5),
                        CreatedDate = reader.GetDateTime(4),
                        ConditionId = reader.GetInt32(7),
                        BlockId = reader.GetInt32(8),
                        ConditionType = reader.GetString(9),
                        Operator = reader.GetString(10),
                        ConditionValue1 = reader.GetString(11),
                        ConditionValue2 = reader.GetString(12),
                        Conjunction = reader.GetString(13),
                        BlockName = reader.GetString(14)
                    };
                    correctionsList.Add(correction);
                }
            }
            return correctionsList;
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
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
                    createdDate=row["createdDate"],
                    isActive = row["isActive"],
                    isDelete = row["isDelete"],
                    notes = row["notes"],
                    Conditions = row["Conditions"]
                });
            }

            string json = js.DataTableToJSON(dt);
            return json;
        }

        // Method to update the isActive status based on correctionId
        [WebMethod]
        public static bool UpdateCorrectionStatus(int correctionId, bool isActive)
        {
            bool result = false;  // Default result to false
            string query = @"
                        UPDATE [tcp_org_pk_questionnaire].[tcp_org_pk_questionnaire].[tbl_corrections_m]
                        SET [isActive] = @IsActive
                        WHERE [correctionId] = @CorrectionId";
            try
            {
                Utility.DatabaseHelper db = new Utility.DatabaseHelper();
                List<SqlParameter> parameters = new List<SqlParameter>
                {
                    new SqlParameter("@IsActive", SqlDbType.Bit) { Value = isActive },
                    new SqlParameter("@CorrectionId", SqlDbType.Int) { Value = correctionId }
                };
                int rowsAffected = db.ExecuteNonQuery(query, parameters.ToArray());
                if (rowsAffected > 0)
                {
                    result = true;
                }
            }
            catch (Exception ex)
            {
                result = false;
                Console.WriteLine($"Error updating correction status: {ex.Message}");
            }

            return result;
        }

        public class CorrectionWithConditions
        {
            public int CorrectionId { get; set; }
            public string CorrectionName { get; set; }
            public string Message { get; set; }
            public decimal ValueToAdd { get; set; }
            public string Notes { get; set; }
            public int CreatedBy { get; set; }
            public DateTime CreatedDate { get; set; }
            public int ConditionId { get; set; }
            public int BlockId { get; set; }
            public string ConditionType { get; set; }
            public string Operator { get; set; }
            public string ConditionValue1 { get; set; }
            public string ConditionValue2 { get; set; }
            public string Conjunction { get; set; }
            public string BlockName { get; set; }
        }

    }
}