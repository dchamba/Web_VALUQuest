using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;
using Newtonsoft.Json;
using VALUQuest.Utility;

namespace VALUQuest.Pages
{
	public partial class CorrectionsPriorityLists : System.Web.UI.Page
    {
        private static string connectionString;
        public CorrectionsPriorityLists()
        {
            connectionString = DatabaseHelper.getCurrentConnectionString();
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            // Caricamento iniziale se necessario
        }

        [System.Web.Services.WebMethod]
        public static object getCorrectionsWithConditions()
        {
            return RepositoryCorrection.GetCorrectionsWithConditions();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string json = hiddenJsonData.Value;
            if (string.IsNullOrEmpty(json)) return;

            try
            {
                var model = JsonConvert.DeserializeObject<PriorityListDTO>(json);

                string connStr = DatabaseHelper.getCurrentConnectionString();

                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();
                    SqlTransaction tran = conn.BeginTransaction();

                    try
                    {
                        int listId;

                        if (model.ListId.HasValue && model.ListId > 0)
                        {
                            listId = model.ListId.Value;

                            // ✅ 1. Aggiorna nome lista
                            string updateSql = "UPDATE tbl_priority_lists_master SET description = @desc WHERE priorityListMasterId = @id";
                            using (SqlCommand cmd = new SqlCommand(updateSql, conn, tran))
                            {
                                cmd.Parameters.AddWithValue("@desc", model.ListName);
                                cmd.Parameters.AddWithValue("@id", listId);
                                cmd.ExecuteNonQuery();
                            }

                            // ✅ 2. Elimina righe e correzioni precedenti (soft delete)
                            string deleteCorr = @"
                                UPDATE tbl_priority_lists_row_correction 
                                SET isDeleted = 1 
                                WHERE priorityListRowId IN 
                                priorityListRowId FROM tbl_priority_lists_row WHERE priorityListMasterId = @listId)";
                            using (SqlCommand cmd = new SqlCommand(deleteCorr, conn, tran))
                            {
                                cmd.Parameters.AddWithValue("@listId", listId);
                                cmd.ExecuteNonQuery();
                            }

                            string deleteRows = "UPDATE tbl_priority_lists_row SET isDeleted = 1 WHERE priorityListMasterId = @listId";
                            using (SqlCommand cmd = new SqlCommand(deleteRows, conn, tran))
                            {
                                cmd.Parameters.AddWithValue("@listId", listId);
                                cmd.ExecuteNonQuery();
                            }
                        }
                        else
                        {
                            // ✅ 3. Inserisci nuova lista
                            listId = InsertPriorityList(model.ListName, conn, tran);
                        }

                        // ✅ 4. Inserisci righe e correzioni nuove
                        foreach (var row in model.Rows)
                        {
                            int rowId = InsertRow(listId, row.Order, conn, tran);

                            foreach (var corr in row.Corrections)
                            {
                                InsertCorrection(rowId, corr.CorrectionId, corr.Position, corr.ConnectorToNext, conn, tran);
                            }
                        }

                        tran.Commit();
                        // eventualmente: mostra messaggio di successo
                    }
                    catch (Exception ex)
                    {
                        tran.Rollback();
                        throw new Exception("Errore durante il salvataggio: " + ex.Message);
                    }
                }
            }
            catch (Exception ex)
            {
                // gestione errore parsing JSON o altro
                throw new Exception("Errore nel parsing JSON: " + ex.Message);
            }
        }
        
        private static void DeletePriorityList(int listId, SqlConnection conn, SqlTransaction tran)
        {
            string deleteMaster = "UPDATE tbl_priority_lists_master SET isDeleted = 1, deletedDateTime = GETDATE() WHERE priorityListMasterId = @listId";
            string deleteRows = "UPDATE tbl_priority_lists_row SET isDeleted = 1 WHERE priorityListMasterId = @listId";
            string deleteCorr = @"UPDATE tbl_priority_lists_row_correction 
                          SET isDeleted = 1 
                          WHERE priorityListRowId IN 
                            (SELECT priorityListRowId FROM tbl_priority_lists_row WHERE priorityListMasterId = @listId)";

            using (SqlCommand cmd = new SqlCommand(deleteCorr, conn, tran))
            {
                cmd.Parameters.AddWithValue("@listId", listId);
                cmd.ExecuteNonQuery();
            }
            using (SqlCommand cmd = new SqlCommand(deleteRows, conn, tran))
            {
                cmd.Parameters.AddWithValue("@listId", listId);
                cmd.ExecuteNonQuery();
            }
            using (SqlCommand cmd = new SqlCommand(deleteMaster, conn, tran))
            {
                cmd.Parameters.AddWithValue("@listId", listId);
                cmd.ExecuteNonQuery();
            }
        }
        
        [System.Web.Services.WebMethod]
        public static string DeleteList(int listId)
        {
            try
            {
                string connStr = DatabaseHelper.getCurrentConnectionString();
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();
                    SqlTransaction tran = conn.BeginTransaction();

                    DeletePriorityList(listId, conn, tran);

                    tran.Commit();
                    return "OK";
                }
            }
            catch (Exception ex)
            {
                return "Errore eliminazione: " + ex.Message;
            }
        }

        [System.Web.Services.WebMethod]
        public static string SaveList(string json)
        {
            try
            {
                var model = JsonConvert.DeserializeObject<PriorityListDTO>(json);
                string connStr = DatabaseHelper.getCurrentConnectionString();

                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();
                    SqlTransaction tran = conn.BeginTransaction();

                    int listId;

                    if (model.ListId.HasValue && model.ListId > 0)
                    {
                        listId = model.ListId.Value;

                        // 1. Aggiorna nome lista
                        string updateSql = "UPDATE tbl_priority_lists_master SET description = @desc WHERE priorityListMasterId = @id";
                        using (SqlCommand cmd = new SqlCommand(updateSql, conn, tran))
                        {
                            cmd.Parameters.AddWithValue("@desc", model.ListName);
                            cmd.Parameters.AddWithValue("@id", listId);
                            cmd.ExecuteNonQuery();
                        }

                        // 2. Rimuovi righe e correzioni vecchie
                        string deleteCorr = @"UPDATE tbl_priority_lists_row_correction 
                                      SET isDeleted = 1 
                                      WHERE priorityListRowId IN 
                                          (SELECT priorityListRowId FROM tbl_priority_lists_row WHERE priorityListMasterId = @listId)";
                        using (SqlCommand cmd = new SqlCommand(deleteCorr, conn, tran))
                        {
                            cmd.Parameters.AddWithValue("@listId", listId);
                            cmd.ExecuteNonQuery();
                        }

                        string deleteRows = "UPDATE tbl_priority_lists_row SET isDeleted = 1 WHERE priorityListMasterId = @listId";
                        using (SqlCommand cmd = new SqlCommand(deleteRows, conn, tran))
                        {
                            cmd.Parameters.AddWithValue("@listId", listId);
                            cmd.ExecuteNonQuery();
                        }
                    }
                    else
                    {
                        // 3. Inserisci nuova lista
                        listId = InsertPriorityList(model.ListName, conn, tran);
                    }

                    // 4. Inserisci righe nuove
                    foreach (var row in model.Rows)
                    {
                        int rowId = InsertRow(listId, row.Order, conn, tran);

                        foreach (var corr in row.Corrections)
                        {
                            InsertCorrection(rowId, corr.CorrectionId, corr.Position, corr.ConnectorToNext, conn, tran);
                        }
                    }

                    tran.Commit();
                    return "OK";
                }
            }
            catch (Exception ex)
            {
                return "Errore salvataggio: " + ex.Message;
            }

        }

        private static int InsertPriorityList(string description, SqlConnection conn, SqlTransaction tran)
        {
            string sql = @"INSERT INTO [" + DatabaseHelper.getCurrentDatabaseName() + @"].[tbl_priority_lists_master] 
                           (description, createdAt, isActive, isDeleted)
                           OUTPUT INSERTED.priorityListMasterId
                           VALUES (@desc, GETDATE(), 1, 0)";

            using (SqlCommand cmd = new SqlCommand(sql, conn, tran))
            {
                cmd.Parameters.AddWithValue("@desc", description);
                return (int)cmd.ExecuteScalar();
            }
        }

        private static int InsertRow(int listId, int orderInList, SqlConnection conn, SqlTransaction tran)
        {
            string sql = @"INSERT INTO [" + DatabaseHelper.getCurrentDatabaseName() + @"].[tbl_priority_lists_row]
                           (priorityListMasterId, orderInList, isDeleted)
                           OUTPUT INSERTED.priorityListRowId
                           VALUES (@listId, @order, 0)";

            using (SqlCommand cmd = new SqlCommand(sql, conn, tran))
            {
                cmd.Parameters.AddWithValue("@listId", listId);
                cmd.Parameters.AddWithValue("@order", orderInList);
                return (int)cmd.ExecuteScalar();
            }
        }

        private static void InsertCorrection(int rowId, int correctionId, int position, string connector, SqlConnection conn, SqlTransaction tran)
        {
            string sql = @"INSERT INTO " + DatabaseHelper.getCurrentDatabaseName() + @".[tbl_priority_lists_row_correction]
                           (priorityListRowId, correctionId, position, connectorToNext, isDeleted)
                           VALUES (@rowId, @corrId, @pos, @conn, 0)";

            using (SqlCommand cmd = new SqlCommand(sql, conn, tran))
            {
                cmd.Parameters.AddWithValue("@rowId", rowId);
                cmd.Parameters.AddWithValue("@corrId", correctionId);
                cmd.Parameters.AddWithValue("@pos", position);
                cmd.Parameters.AddWithValue("@conn", (object)connector ?? DBNull.Value);
                cmd.ExecuteNonQuery();
            }
        }
       
        [System.Web.Services.WebMethod]
        public static object LoadAllPriorityLists()
        {
            string connStr = DatabaseHelper.getCurrentConnectionString();
            string dbName = DatabaseHelper.getCurrentDatabaseName();

            var lists = new List<PriorityListDTO>();

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                string sqlLists = $@"
                    SELECT priorityListMasterId, description, isActive 
                    FROM [{dbName}].[tbl_priority_lists_master]
                    WHERE isDeleted = 0";

                using (SqlCommand cmdList = new SqlCommand(sqlLists, conn))
                using (SqlDataReader rdrList = cmdList.ExecuteReader())
                {
                    while (rdrList.Read())
                    {
                        lists.Add(new PriorityListDTO()
                        {
                            ListId = (int)rdrList["priorityListMasterId"],
                            ListName = rdrList["description"].ToString(),
                            IsActive = Convert.ToBoolean(rdrList["isActive"]),
                            Rows = new List<RowDTO>()
                        });
                    }
                }

                // 2. Per ogni lista carica righe + correzioni
                foreach (var list in lists)
                {
                    var rowsTemp = new List<(int RowId, int Order)>();

                    string sqlRows = $@"
                    SELECT priorityListRowId, orderInList 
                    FROM [{dbName}].[tbl_priority_lists_row]
                    WHERE priorityListMasterId = @listId AND isDeleted = 0
                    ORDER BY orderInList";

                    using (SqlCommand cmdRows = new SqlCommand(sqlRows, conn))
                    {
                        cmdRows.Parameters.AddWithValue("@listId", list.ListId);
                        using (SqlDataReader rdrRow = cmdRows.ExecuteReader())
                        {
                            while (rdrRow.Read())
                            {
                                rowsTemp.Add(((int)rdrRow["priorityListRowId"], (int)rdrRow["orderInList"]));
                            }
                        }
                    }

                    foreach (var (rowId, order) in rowsTemp)
                    {
                        var corrections = new List<CorrectionDTO>();

                        string sqlCorr = $@"
                        SELECT correctionId, position, connectorToNext 
                        FROM [{dbName}].[tbl_priority_lists_row_correction]
                        WHERE priorityListRowId = @rowId AND isDeleted = 0
                        ORDER BY position";

                        using (SqlCommand cmdCorr = new SqlCommand(sqlCorr, conn))
                        {
                            cmdCorr.Parameters.AddWithValue("@rowId", rowId);
                            using (SqlDataReader rdrCorr = cmdCorr.ExecuteReader())
                            {
                                while (rdrCorr.Read())
                                {
                                    corrections.Add(new CorrectionDTO
                                    {
                                        CorrectionId = (int)rdrCorr["correctionId"],
                                        Position = (int)rdrCorr["position"],
                                        ConnectorToNext = rdrCorr["connectorToNext"]?.ToString()
                                    });
                                }
                            }
                        }

                        list.Rows.Add(new RowDTO
                        {
                            Order = order,
                            Corrections = corrections
                        });
                    }
                }
            }
            return lists;
        }

        // DTO usati per deserializzare il JSON
        public class PriorityListDTO
        {
            public int? ListId { get; set; }
            public bool IsActive { get; set; }
            public string ListName { get; set; }
            public List<RowDTO> Rows { get; set; }
        }

        public class RowDTO
        {
            public int Order { get; set; }
            public List<CorrectionDTO> Corrections { get; set; }
        }

        public class CorrectionDTO
        {
            public int CorrectionId { get; set; }
            public int Position { get; set; }
            public string ConnectorToNext { get; set; }
        }
        
    }
}
