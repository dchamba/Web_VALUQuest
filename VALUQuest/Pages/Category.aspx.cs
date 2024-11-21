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
    public partial class Category : System.Web.UI.Page
    {
        static DataTabletoJSON js = new DataTabletoJSON();
        protected void Page_Load(object sender, EventArgs e)
        {

        }

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
        public static string GetCategoryData()
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            string query = @" select b.blockName, c.* from tbl_category c
                                inner join tbl_block b on b.blockId=c.blockId
                                where c.isActive=1 and b.isActive=1
                                order by c.categoryId desc; ";
            DataTable dt = db.ExecuteQuery(query);
            List<object> data = new List<object>();
            foreach (DataRow row in dt.Rows)
            {
                data.Add(new
                {
                    blockId = row["blockId"],
                    blockName = row["blockName"],
                    categoryId = row["categoryId"],
                    categoryName = row["categoryName"]
                });
            }

            string json = js.DataTableToJSON(dt);
            return json;
        }

        [WebMethod]
        public static string AddCategory(int blockId,string categoryName)
        {
            try
            {
                Utility.DatabaseHelper db = new Utility.DatabaseHelper();
                SqlParameter pBlockId= new SqlParameter("@blockId", blockId);
                SqlParameter pCategoryName = new SqlParameter("@categoryName", categoryName);
                SqlParameter pCreatedBy = new SqlParameter("@createdBy", HttpContext.Current.Session["userName"]);

                int rowsAffected = db.ExecuteStoredProcedure("sp_InsertCategoryData",
                    pCategoryName,
                    pBlockId,
                    pCreatedBy);

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
        public static string UpdateData(string categoryId, string blockId, string categoryName)
        {
            try
            {
                Utility.DatabaseHelper db = new Utility.DatabaseHelper();
                SqlParameter pCategoryId = new SqlParameter("@categoryId", categoryId);
                SqlParameter pBlockId = new SqlParameter("@blockId", blockId);
                SqlParameter pCategoryName = new SqlParameter("@categoryName", categoryName);
                SqlParameter pModifiedBy = new SqlParameter("@modifiedBy", HttpContext.Current.Session["userName"]);
                SqlParameter pModifiedDate = new SqlParameter("@modifiedDate", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));


                int rowsAffected = db.ExecuteStoredProcedure("sp_UpdateCategoryData",
                    pCategoryId,
                    pBlockId,
                    pCategoryName,
                    pModifiedBy,
                    pModifiedDate);

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
        public static string DeleteData(string categoryId)
        {
            try
            {
                Utility.DatabaseHelper db = new Utility.DatabaseHelper();
                SqlParameter pCategoryId = new SqlParameter("@categoryId", categoryId);
                SqlParameter pDeletedBy = new SqlParameter("@deletedBy", HttpContext.Current.Session["userName"]);
                SqlParameter pDeletedDate = new SqlParameter("@deletedDate", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));


                int rowsAffected = db.ExecuteStoredProcedure("sp_DeleteCategoryData",
                    pCategoryId,
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


    }
}