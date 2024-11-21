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
    public partial class SubCategory : System.Web.UI.Page
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
        public static string GetCategories(string blockId)
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            string query = @"select c.categoryId, c.categoryName from tbl_category c
                            left join tbl_block b on b.blockId=c.blockId
                            where b.blockId="+blockId+" and c.isActive=1 and b.isActive=1; ";
            DataTable dt = db.ExecuteQuery(query);
            // Convert DataTable to JSON
            string json = js.DataTableToJSON(dt);

            return json;
        }

        [WebMethod]
        public static string GetSubCategoryData()
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            string query = @" select sc.subCatId, c.categoryId, c.blockId, b.blockName, c.categoryName, sc.subCatName from tbl_subcategory sc
                                left join tbl_category c on c.categoryId=sc.catId
                                left join tbl_block b on b.blockId=c.blockId
                                where sc.isActive=1 and c.isActive=1 and b.isActive=1
                                order by sc.subCatId desc";
            DataTable dt = db.ExecuteQuery(query);
            List<object> data = new List<object>();
            foreach (DataRow row in dt.Rows)
            {
                data.Add(new
                {
                    blockId = row["blockId"],
                    blockName = row["blockName"],
                    categoryId = row["categoryId"],
                    categoryName = row["categoryName"],
                    subCatId = row["subCatId"],
                    subCatName = row["subCatName"]

                });
            }

            string json = js.DataTableToJSON(dt);
            return json;
        }

        [WebMethod]
        public static string AddSubCategory(int categoryId, string subcategoryName)
        {
            try
            {
                Utility.DatabaseHelper db = new Utility.DatabaseHelper();
                SqlParameter pSubcategoryName = new SqlParameter("@subcategoryName", subcategoryName);
                SqlParameter pCategoryId = new SqlParameter("@catId", categoryId);
                SqlParameter pCreatedBy = new SqlParameter("@createdBy", HttpContext.Current.Session["userName"]);

                int rowsAffected = db.ExecuteStoredProcedure("sp_InsertSubCategoryData",
                    pSubcategoryName,
                    pCategoryId,
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
        public static string UpdateData(string subcatId, string categoryId, string @subcategoryName)
        {
            try
            {
                Utility.DatabaseHelper db = new Utility.DatabaseHelper();
                SqlParameter pSubcatId = new SqlParameter("@subcatId", subcatId);
                SqlParameter pCategoryId = new SqlParameter("@categoryId", categoryId);
                SqlParameter pSubcategoryName = new SqlParameter("@subcategoryName", @subcategoryName);
                SqlParameter pModifiedBy = new SqlParameter("@modifiedBy", HttpContext.Current.Session["userName"]);
                SqlParameter pModifiedDate = new SqlParameter("@modifiedDate", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));


                int rowsAffected = db.ExecuteStoredProcedure("sp_UpdateSubCategoryData",
                    pSubcatId,
                    pCategoryId,
                    pSubcategoryName,
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
        public static string DeleteData(string subCatId)
        {
            try
            {
                Utility.DatabaseHelper db = new Utility.DatabaseHelper();
                SqlParameter pSubCatId = new SqlParameter("@subCatId", subCatId);
                SqlParameter pDeletedBy = new SqlParameter("@deletedBy", HttpContext.Current.Session["userName"]);
                SqlParameter pDeletedDate = new SqlParameter("@deletedDate", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));


                int rowsAffected = db.ExecuteStoredProcedure("sp_DeleteSubCategoryData",
                    pSubCatId,
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