using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace VALUQuest.Utility
{
    public class DatabaseHelper
    {
        private string connectionString;
        public DatabaseHelper()
        {
            // Read connection string from web.config
            connectionString = ConfigurationManager.ConnectionStrings["valu"].ConnectionString;
        }

        public int ExecuteNonQuery(string query, params SqlParameter[] parameters)
        {
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                using (SqlCommand command = new SqlCommand(query, connection))
                {
                    if (parameters != null && parameters.Length > 0)
                    {
                        command.Parameters.AddRange(parameters);
                    }

                    try
                    {
                        connection.Open();
                        return command.ExecuteNonQuery();
                    }
                    catch (Exception ex)
                    {
                        // Handle exception appropriately (log, throw, etc.)
                        throw new Exception("Error executing non-query command.", ex);
                    }
                }
            }
        }

        public object ExecuteScalar(string query, SqlParameter[] parameters = null)
        {
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();
                using (SqlCommand command = new SqlCommand(query, connection))
                {
                    if (parameters != null)
                    {
                        command.Parameters.AddRange(parameters);
                    }
                    return command.ExecuteScalar();
                }
            }
        }

        public DataTable ExecuteQuery(string query, SqlParameter[] parameters=null)
        {
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();
                using (SqlCommand command = new SqlCommand(query, connection))
                {
                    if (parameters != null)
                    {
                        command.Parameters.AddRange(parameters);
                    }
                    using (SqlDataAdapter adapter = new SqlDataAdapter(command))
                    {
                        DataTable dataTable = new DataTable();
                        adapter.Fill(dataTable);
                        return dataTable;
                    }
                }
            }
        }

        public void ExecuteTransaction(params string[] queries)
        {
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();
                SqlTransaction transaction = connection.BeginTransaction();
                try
                {
                    foreach (string query in queries)
                    {
                        using (SqlCommand command = new SqlCommand(query, connection, transaction))
                        {
                            command.ExecuteNonQuery();
                        }
                    }
                    transaction.Commit();
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    throw new Exception("Transaction failed. Rolled back.", ex);
                }
            }

        }

        public int ExecuteStoredProcedure(string procedureName, params SqlParameter[] parameters)
        {
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                using (SqlCommand command = new SqlCommand(procedureName, connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    if (parameters != null && parameters.Length > 0)
                    {
                        command.Parameters.AddRange(parameters);
                    }

                    try
                    {
                        connection.Open();
                        return command.ExecuteNonQuery();
                    }
                    catch (Exception ex)
                    {
                        // Handle exception appropriately (log, throw, etc.)
                        throw new Exception("Error executing stored procedure.", ex);
                    }
                }
            }
        }

        public DataTable ExecuteStoredProcedureDataTable(string procedureName, params SqlParameter[] parameters)
        {
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                using (SqlCommand command = new SqlCommand(procedureName, connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    if (parameters != null && parameters.Length > 0)
                    {
                        command.Parameters.AddRange(parameters);
                    }

                    try
                    {
                        connection.Open();

                        using (SqlDataAdapter adapter = new SqlDataAdapter(command))
                        {
                            DataTable dataTable = new DataTable();
                            adapter.Fill(dataTable);
                            return dataTable;
                        }
                    }


                    catch (Exception ex)
                    {
                        // Handle exception appropriately (log, throw, etc.)
                        throw new Exception("Error executing stored procedure.", ex);
                    }
                }
            }
        }
        public List<T> ExecuteQueryReturnListObject<T>(string query) where T : new()
        {

            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand(query, connection);
                connection.Open();
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    return MapToList<T>(reader);
                }
            }
        }

        public List<T> MapToList<T>(SqlDataReader dr) where T : new()
        {
            var entityList = new List<T>();
            var props = typeof(T).GetProperties();

            while (dr.Read())
            {
                var entity = new T();
                foreach (var prop in props)
                {
                    if (HasColumn(dr, prop.Name) && !dr.IsDBNull(dr.GetOrdinal(prop.Name)))
                    {
                        prop.SetValue(entity, dr.GetValue(dr.GetOrdinal(prop.Name)), null);
                    }
                }
                entityList.Add(entity);
            }
            return entityList;
        }

        public static bool HasColumn(SqlDataReader reader, string columnName)
        {
            for (int i = 0; i < reader.FieldCount; i++)
            {
                if (reader.GetName(i).Equals(columnName, StringComparison.OrdinalIgnoreCase))
                {
                    return true;
                }
            }
            return false;
        }

        public static string getCurrentDatabaseName() {
            String connectionString = ConfigurationManager.ConnectionStrings["valu"].ConnectionString;
            SqlConnectionStringBuilder builder = new SqlConnectionStringBuilder(connectionString);
            string databaseName = builder.InitialCatalog;
            return databaseName;
        }

    }
}