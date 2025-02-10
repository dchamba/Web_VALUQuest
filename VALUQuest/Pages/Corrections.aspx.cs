using Microsoft.Ajax.Utilities;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Runtime.InteropServices;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using VALUQuest.Utility;

namespace VALUQuest.Pages
{
    public partial class Corrections : System.Web.UI.Page
    {
        static DataTabletoJSON js = new DataTabletoJSON();
        private static string connectionString;
        public Corrections()
        {
            connectionString = DatabaseHelper.getCurrentConnectionString();
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            //for edit -- start
            // Check if an ID is passed via the query string for edit
            string id = Request.QueryString["ID"];
            if (!string.IsNullOrEmpty(id))
            {
                int correctionId;
                if (int.TryParse(id, out correctionId))
                {
                    // Load the correction data based on the correctionId
                    //LoadCorrectionData(correctionId);

                    // Change the title to Edit Correction with correctionId
                    pageTitle.InnerHtml = "Edit Correction ID " + correctionId;
                    txtId.Value = correctionId.ToString();

                }
            }
        }

        [WebMethod]
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

        //code for edit -- end

        // code for add
        [WebMethod]
        public static string GetBlock()
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            string query = "select * from tbl_block where isActive=1";
            DataTable dt = db.ExecuteQuery(query);
            // Convert DataTable to JSON
            string json = js.DataTableToJSON(dt);

            return json;
        }


        [WebMethod]
        public static string SaveCorrection1(string correctionName, string message, string notes, string valueToAdd, List<conditions> conditions)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    // Begin transaction
                    using (SqlTransaction transaction = conn.BeginTransaction())
                    {
                        try
                        {
                            int correctionId;
                            string insertCorrectionQuery = @"
                                    INSERT INTO tbl_corrections_m (correctionName, message,valueToAdd,createdBy, createdDate, isActive, isDelete, notes)
                                    OUTPUT INSERTED.correctionId
                                    VALUES (@correctionName, @message,@valueToAdd, @createdBy, GETDATE(), 1, 0, @notes)";
                            List<SqlParameter> correctionParams = new List<SqlParameter>()
                                {
                                    new SqlParameter("@correctionName", correctionName),
                                    new SqlParameter("@message", message),
                                    new SqlParameter("@valueToAdd",Convert.ToDecimal(valueToAdd)),
                                    new SqlParameter("@createdBy", 1), // Assuming user ID is 1 for this example
                                    new SqlParameter("@notes", notes)
                                };
                            // Execute insert and get the correctionId
                            correctionId = ExecuteInsertQuery(insertCorrectionQuery, correctionParams, conn, transaction, true);

                            // SQL query to insert into tbl_correction_conditions
                            string insertConditionQuery = @"
                                INSERT INTO tbl_correction_conditions_d(correctionId, blockId, conditionType, operator, conditionValue1,conditionValue2, conjunction)
                                VALUES (@correctionId, @blockId, @conditionType, @operators, @conditionValue1,@conditionValue2, @conjunction)";

                            // Insert each condition using the ExecuteInsertQuery method
                            foreach (var condition in conditions)
                            {
                                List<SqlParameter> conditionParams = new List<SqlParameter>()
                        {
                            new SqlParameter("@correctionId", correctionId),
                            new SqlParameter("@blockId", condition.blockId),
                            new SqlParameter("@conditionType", condition.conditionType),
                            new SqlParameter("@operators", condition.operators),
                            new SqlParameter("@conditionValue1", condition.conditionValue1),
                            new SqlParameter("@conditionValue2", condition.conditionValue2),
                            new SqlParameter("@conjunction", condition.conjunction)
                        };

                                ExecuteInsertQuery(insertConditionQuery, conditionParams, conn, transaction, false);
                            }

                            // Commit transaction if everything is successful
                            transaction.Commit();

                            return "Success";
                        }
                        catch (Exception ex)
                        {
                            // Rollback transaction if any error occurs
                            transaction.Rollback();
                            return "Error: " + ex.Message;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }

        [WebMethod]
        public static string SaveCorrection2(string correctionName, string message, string notes, string valueToAdd, List<conditions> conditions, int? correctionId = null)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    //Begin transaction
                    using (SqlTransaction transaction = conn.BeginTransaction())
                    {
                        try
                        {
                            //Step 1: Call the master stored procedure
                            using (SqlCommand cmdMaster = new SqlCommand("sp_SaveOrUpdate_tbl_corrections_m", conn, transaction))
                            {
                                cmdMaster.CommandType = CommandType.StoredProcedure;
                                //Add parameters for master
                                SqlParameter paramCorrectionId = new SqlParameter("@correctionId", correctionId ?? (object)DBNull.Value)
                                {
                                    Direction = ParameterDirection.InputOutput
                                };
                                cmdMaster.Parameters.Add(paramCorrectionId);
                                cmdMaster.Parameters.AddWithValue("@correctionName", correctionName);
                                cmdMaster.Parameters.AddWithValue("@message", message);
                                cmdMaster.Parameters.AddWithValue("@valueToAdd", Convert.ToDecimal(valueToAdd));
                                cmdMaster.Parameters.AddWithValue("@createdBy", "system");  // Assume createdBy is 1 for now
                                cmdMaster.Parameters.AddWithValue("@notes", notes);
                                // Execute the master SP
                                cmdMaster.ExecuteNonQuery();
                                // Get the updated/inserting correctionId
                                //int newCorrectionId = (int)paramCorrectionId.Value;
                                int newCorrectionId = (int)paramCorrectionId.Value;
                                // Step 2: Call the details stored procedure
                                using (SqlCommand cmdDetails = new SqlCommand("sp_SaveUpdate_tbl_correction_conditions_d", conn, transaction))
                                {
                                    cmdDetails.CommandType = CommandType.StoredProcedure;
                                    // Convert conditions list to DataTable
                                    foreach (var condition in conditions)
                                    {
                                        List<SqlParameter> conditionParams = new List<SqlParameter>()
                                        {
                                            new SqlParameter("@correctionId", correctionId),
                                            new SqlParameter("@blockId", condition.blockId),
                                            new SqlParameter("@conditionType", condition.conditionType),
                                            new SqlParameter("@operators", condition.operators),
                                            new SqlParameter("@conditionValue1", condition.conditionValue1),
                                            new SqlParameter("@conditionValue2", condition.conditionValue2),
                                            new SqlParameter("@conjunction", condition.conjunction),
                                            new SqlParameter("@CreatedBy", "System")
                                        };
                                        cmdDetails.ExecuteNonQuery();
                                    }

                                    // Commit transaction if everything is successful
                                    transaction.Commit();

                                    return "Success";
                                }
                            }
                        }
                        catch (Exception ex)
                        {
                            // Rollback transaction in case of error
                            transaction.Rollback();
                            return "Error: " + ex.Message;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }

        [WebMethod]
        public static string SaveCorrection(string correctionName, string message, string notes, string valueToAdd, List<conditions> conditions, int? correctionId = null)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Begin transaction
                    using (SqlTransaction transaction = conn.BeginTransaction())
                    {
                        try
                        {
                            // Step 1: Call the master stored procedure
                            using (SqlCommand cmdMaster = new SqlCommand("sp_SaveOrUpdate_tbl_corrections_m", conn, transaction))
                            {
                                cmdMaster.CommandType = CommandType.StoredProcedure;

                                // Add parameters for master
                                SqlParameter paramCorrectionId = new SqlParameter("@correctionId", SqlDbType.Int);
                                paramCorrectionId.Direction = ParameterDirection.InputOutput;
                                if (correctionId.HasValue)
                                    paramCorrectionId.Value = correctionId.Value;
                                else
                                    paramCorrectionId.Value = DBNull.Value;

                                cmdMaster.Parameters.Add(paramCorrectionId);
                                cmdMaster.Parameters.AddWithValue("@correctionName", correctionName);
                                cmdMaster.Parameters.AddWithValue("@message", message);
                                cmdMaster.Parameters.AddWithValue("@valueToAdd", Convert.ToDecimal(valueToAdd));
                                cmdMaster.Parameters.AddWithValue("@createdBy", "system");  // Hardcoded for example purposes
                                cmdMaster.Parameters.AddWithValue("@notes", notes);

                                // Execute the master stored procedure
                                cmdMaster.ExecuteNonQuery();

                                // Get the updated/inserting correctionId
                                int newCorrectionId = (int)paramCorrectionId.Value;

                                // Step 2: Call the details stored procedure for each condition
                                using (SqlCommand cmdDetails = new SqlCommand("sp_SaveUpdate_tbl_correction_conditions_d", conn, transaction))
                                {
                                    cmdDetails.CommandType = CommandType.StoredProcedure;

                                    // Loop through each condition and execute the stored procedure for details
                                    foreach (var condition in conditions)
                                    {
                                        cmdDetails.Parameters.Clear(); // Clear previous parameters

                                        // Add parameters for details
                                        cmdDetails.Parameters.AddWithValue("@correctionId", newCorrectionId);  // Use the newCorrectionId
                                        //cmdDetails.Parameters.AddWithValue("@blockId",Convert.ToInt32(condition.blockId));
                                        cmdDetails.Parameters.AddWithValue("@blockId", condition.blockId != "" ? (object)Convert.ToInt32(condition.blockId) : 0);
                                        cmdDetails.Parameters.AddWithValue("@conditionType", condition.conditionType);
                                        cmdDetails.Parameters.AddWithValue("@operators", condition.operators);
                                        cmdDetails.Parameters.AddWithValue("@conditionValue1", condition.conditionValue1);
                                        cmdDetails.Parameters.AddWithValue("@conditionValue2", condition.conditionValue2);
                                        cmdDetails.Parameters.AddWithValue("@conjunction", condition.conjunction);
                                        cmdDetails.Parameters.AddWithValue("@CreatedBy", "System");

                                        // Execute the details stored procedure for each condition
                                        cmdDetails.ExecuteNonQuery();
                                    }
                                }

                                // Commit the transaction after both master and details operations
                                transaction.Commit();

                                return "Success";
                            }
                        }
                        catch (Exception ex)
                        {
                            // Rollback transaction in case of error
                            transaction.Rollback();
                            return "Error: " + ex.Message;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }

        private static int ExecuteInsertQuery(string query, List<SqlParameter> parameters, SqlConnection conn, SqlTransaction transaction, bool returnIdentity)
        {
            using (SqlCommand cmd = new SqlCommand(query, conn, transaction))
            {
                foreach (var param in parameters)
                {
                    cmd.Parameters.Add(param);
                }
                if (returnIdentity)
                {
                    return (int)cmd.ExecuteScalar();
                }
                else
                {
                    cmd.ExecuteNonQuery();
                    return 0;
                }
            }
        }

        private static int ExecuteInsertQuery1(string query, List<SqlParameter> parameters, bool returnIdentity)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    // Add parameters to the command
                    foreach (var param in parameters)
                    {
                        cmd.Parameters.Add(param);
                    }

                    // If returnIdentity is true, execute scalar and return the inserted ID
                    if (returnIdentity)
                    {
                        return (int)cmd.ExecuteScalar();
                    }
                    else
                    {
                        cmd.ExecuteNonQuery();
                        return 0; // For non-identity inserts
                    }
                }
            }
        }

        [WebMethod]
        public static bool UpdateCorrectionStatus(int conditionId, bool? isActive, bool? isDelete)
        {
            if (!isActive.HasValue && !isDelete.HasValue)
            {
                throw new ArgumentException("Either isActive or isDelete must be provided.");
            }
            bool result = false;
            string query = "EXEC sp_UpdateCorrectionStatus @conditionId, @isActive, @isDeleted, @updatedBy";
            try
            {
                // Initialize the database helper
                Utility.DatabaseHelper db = new Utility.DatabaseHelper();
                SqlParameter[] parameters = new SqlParameter[]
                {
                    new SqlParameter("@conditionId", conditionId),
                    new SqlParameter("@updatedBy", 1),
                    new SqlParameter("@isActive", isActive),
                    new SqlParameter("@isDeleted", isDelete),
                };
                // Execute the query
                int rowsAffected = db.ExecuteNonQuery(query, parameters.ToArray());
                // If any rows were affected, set result to true
                result = rowsAffected > 0;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error updating correction status: {ex.Message}");
            }

            return result;
        }


    }

    public class conditions
    {
        public string conditionType { get; set; }
        public string blockId { get; set; }
        public string blockText { get; set; }
        public string operators { get; set; }
        public string conditionValue1 { get; set; }
        public string conditionValue2 { get; set; }
        public string conjunction { get; set; }
    }
}
