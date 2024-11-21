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
    public partial class Config : System.Web.UI.Page
    {
       static DataTabletoJSON js = new DataTabletoJSON();
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string AddBlock(string blockName)
        {
            try
            {
                Utility.DatabaseHelper db = new Utility.DatabaseHelper();
                SqlParameter pBlockName = new SqlParameter("@blockName", blockName);
                SqlParameter pCreatedBy = new SqlParameter("@createdBy", HttpContext.Current.Session["userName"]);

                int rowsAffected = db.ExecuteStoredProcedure("sp_InsertBlocks",
                    pBlockName,
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
        public static string GetBlocksData()
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            string query = @"select b.blockId, b.blockName from tbl_block b where b.isActive=1 order by b.blockId desc;";
            DataTable dt = db.ExecuteQuery(query);
            List<object> data = new List<object>();
            foreach (DataRow row in dt.Rows)
            {
                data.Add(new
                {
                    blockId = row["blockId"],
                    blockName = row["blockName"]
                });
            }

            string json = js.DataTableToJSON(dt);
            return json;
        }


    }
}